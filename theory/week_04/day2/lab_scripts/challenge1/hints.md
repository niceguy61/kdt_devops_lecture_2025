# Challenge 1 힌트

## 🚨 시나리오 1: Gateway 설정 오류 (20분)

### 증상
```bash
curl http://localhost:9090/users
# curl: (7) Failed to connect to localhost port 9090: Connection refused
# 또는
# 404 page not found
```

### 힌트 1: Gateway 상태 확인
```bash
kubectl get gateway
kubectl describe gateway api-gateway
```
**질문**: Gateway의 selector가 올바른가요?

### 힌트 2: Ingress Gateway Pod 라벨 확인
```bash
kubectl get pods -n istio-system -l app=istio-ingressgateway --show-labels
```
**질문**: Gateway selector와 Pod 라벨이 일치하나요?

### 힌트 3: Service NodePort 확인
```bash
kubectl get svc -n istio-system istio-ingressgateway
```
**질문**: NodePort가 30090인가요?

### 힌트 4: 클러스터 포트 매핑 확인
```bash
docker ps | grep w4d2-challenge
```
**질문**: 호스트 포트 9090이 컨테이너 포트 30090에 매핑되어 있나요?

### 💡 해결 방향
1. Gateway의 selector를 `istio: ingressgateway`로 수정
2. Ingress Gateway Service의 NodePort를 30090으로 수정

---

## 🚨 시나리오 2: VirtualService 라우팅 오류 (25분)

### 증상
```bash
curl http://localhost:9090/users
# 200 OK (정상)

curl http://localhost:9090/products
# 404 Not Found

curl http://localhost:9090/orders
# 503 Service Unavailable
```

### 힌트 1: VirtualService 설정 확인
```bash
kubectl get virtualservice api-routes -o yaml
```
**질문**: match 조건의 prefix가 올바른가요?

### 힌트 2: 경로 확인
```bash
kubectl get virtualservice api-routes -o yaml | grep prefix
```
**질문**: `/product`와 `/products` 중 어느 것이 맞나요?

### 힌트 3: Destination Host 확인
```bash
kubectl get svc
kubectl get virtualservice api-routes -o yaml | grep host
```
**질문**: destination host가 실제 Service 이름과 일치하나요?

### 힌트 4: 포트 확인
```bash
kubectl get svc order-service
kubectl get virtualservice api-routes -o yaml | grep -A 5 orders
```
**질문**: Service의 port와 destination port가 일치하나요?

### 💡 해결 방향
1. `/product` → `/products`
2. `wrong-product-service` → `product-service`
3. order-service의 destination port를 80으로 수정

---

## 🚨 시나리오 3: Traffic Splitting 오작동 (20분)

### 증상
```bash
for i in {1..100}; do curl -s http://localhost:9090/users; done | grep v2
# (결과 없음 - v2가 전혀 나오지 않음)
```

### 힌트 1: v2 Pod 상태 확인
```bash
kubectl get pods -l app=user-service
```
**질문**: v2 Pod가 Running 상태인가요?

### 힌트 2: v2 Pod 라벨 확인
```bash
kubectl get pods -l app=user-service --show-labels
```
**질문**: v2 Pod의 version 라벨이 무엇인가요?

### 힌트 3: DestinationRule subset 확인
```bash
kubectl get destinationrule user-service -o yaml
```
**질문**: subset v2의 labels가 실제 Pod 라벨과 일치하나요?

### 힌트 4: Deployment 템플릿 확인
```bash
kubectl get deployment user-service-v2 -o yaml | grep -A 10 "template:"
```
**질문**: template의 labels에 `version: v2`가 있나요, 아니면 `ver: v2`인가요?

### 💡 해결 방향
1. v2 Deployment의 template labels를 `version: v2`로 수정
2. 또는 DestinationRule의 subset을 `ver: v2`로 수정
3. Pod 재시작 필요

---

## 🚨 시나리오 4: Fault Injection 미작동 (20분)

### 증상
```bash
# 지연이 발생하지 않음
time curl http://localhost:9090/products
# 즉시 응답 (3초 지연 없음)

# 오류가 발생하지 않음
for i in {1..20}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9090/products
done
# 모두 200 (503 없음)
```

### 힌트 1: VirtualService 구조 확인
```bash
kubectl get virtualservice api-routes -o yaml
```
**질문**: fault 블록이 어디에 위치하나요?

### 힌트 2: Fault 위치 확인
```yaml
# 잘못된 예
- match:
  - uri:
      prefix: /products
  route:
  - destination: ...
  fault:  # ❌ route 뒤에 있으면 적용 안됨
    ...

# 올바른 예
- match:
  - uri:
      prefix: /products
  fault:  # ✅ route 앞에 있어야 함
    ...
  route:
  - destination: ...
```

### 힌트 3: Percentage 필드 확인
```bash
kubectl get virtualservice api-routes -o yaml | grep -A 5 fault
```
**질문**: `percent`인가요, `percentage`인가요?

### 힌트 4: 올바른 형식 확인
```yaml
# 잘못된 예
fault:
  delay:
    percent: 50  # ❌

# 올바른 예
fault:
  delay:
    percentage:  # ✅
      value: 50
```

### 힌트 5: Match 조건 확인
**질문**: 시나리오 2를 해결했나요? `/product`가 `/products`로 수정되었나요?

### 💡 해결 방향
1. fault 블록을 route 앞으로 이동
2. `percent` → `percentage.value`로 수정
3. `/product` → `/products` 확인 (시나리오 2)

---

## 🔍 일반적인 디버깅 팁

### 1. 로그 확인
```bash
# Ingress Gateway 로그
kubectl logs -n istio-system -l app=istio-ingressgateway --tail=50

# 애플리케이션 Pod 로그
kubectl logs -l app=user-service
```

### 2. 상태 확인
```bash
# 모든 리소스 상태
kubectl get all

# Istio 리소스 상태
kubectl get gateway,virtualservice,destinationrule
```

### 3. 상세 정보 확인
```bash
# describe로 이벤트 확인
kubectl describe gateway api-gateway
kubectl describe virtualservice api-routes

# YAML로 전체 설정 확인
kubectl get virtualservice api-routes -o yaml
```

### 4. Istio 분석 도구
```bash
# Istio 설정 검증
istioctl analyze

# Proxy 상태 확인
istioctl proxy-status
```

---

## 💡 문제 해결 순서

1. **증상 파악**: 어떤 오류가 발생하는가?
2. **로그 확인**: 관련 로그에서 단서 찾기
3. **설정 검증**: YAML 설정 확인
4. **비교 분석**: 정상 설정과 비교
5. **수정 적용**: 문제 해결
6. **검증**: 정상 동작 확인

---

## ⏰ 시간 관리 팁

- **시나리오 1**: 15분 이내 해결 목표
- **시나리오 2**: 20분 이내 해결 목표
- **시나리오 3**: 15분 이내 해결 목표
- **시나리오 4**: 20분 이내 해결 목표
- **여유 시간**: 20분 (회고 및 문서화)

막히면 힌트를 순서대로 확인하세요!
