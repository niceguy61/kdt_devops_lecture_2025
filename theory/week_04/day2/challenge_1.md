# Week 4 Day 2 Challenge 1: Istio 장애 복구 미션

<div align="center">

**🚨 장애 대응** • **🔍 문제 진단** • **🛠️ 신속 복구**

*실제 운영 환경의 Istio 장애 상황 해결*

</div>

---

## 🕘 Challenge 정보
**시간**: 15:00-16:30 (90분)
**목표**: 의도적으로 망가진 Istio 환경 복구
**방식**: 4개 시나리오 순차 해결
**작업 위치**: `theory/week_04/day2/lab_scripts/challenge1`

## 🎯 Challenge 목표

### 📚 학습 목표
- **장애 진단**: 로그와 상태로 문제 파악
- **근본 원인 분석**: 표면이 아닌 근본 원인 찾기
- **신속 복구**: 최소 시간 내 서비스 복구
- **예방 대책**: 재발 방지 방안 수립

### 🛠️ 실무 역량
- **체계적 디버깅**: 단계별 문제 해결
- **Istio 트러블슈팅**: 실무 장애 대응
- **팀 협업**: 역할 분담 및 소통
- **문서화**: 장애 보고서 작성

---

## 🛠️ Step 1: Challenge 환경 배포 (5분)

### Step 1-1: 작업 디렉토리 이동

```bash
cd theory/week_04/day2/lab_scripts/challenge1
```

### Step 1-2: 망가진 환경 배포

```bash
./deploy-broken-system.sh
```

**배포 내용:**
- 새로운 클러스터 생성 (w4d2-challenge, 포트 9090)
- Istio 설치
- 의도적으로 잘못된 설정 배포
- 4개 장애 시나리오 주입

---

## 🚨 시나리오 1: Gateway 접근 불가 (20분)

### 문제 상황
```bash
curl http://localhost:9090/users
# 연결 실패 또는 404 오류
```

### 🔍 확인해야 할 사항
1. Gateway 리소스가 정상적으로 생성되었는가?
2. Ingress Gateway Service가 올바른 포트로 노출되어 있는가?
3. Gateway와 Ingress Gateway 간 연결이 정상인가?

### 📋 문제 파일
- `broken-gateway.yaml`
- Ingress Gateway Service 설정

### ✅ 해결 확인
```bash
curl http://localhost:9090/users
# User Service v1 (정상 응답)
```

---

## 🚨 시나리오 2: 일부 경로 접근 불가 (25분)

### 문제 상황
```bash
curl http://localhost:9090/users
# 200 OK (정상)

curl http://localhost:9090/products
# 404 Not Found (오류)

curl http://localhost:9090/orders
# 503 Service Unavailable (오류)
```

### 🔍 확인해야 할 사항
1. VirtualService의 라우팅 규칙이 올바른가?
2. 경로(path) 설정이 정확한가?
3. Destination host가 실제 Service와 일치하는가?
4. 포트 설정이 올바른가?

### 📋 문제 파일
- `broken-virtualservice.yaml`

### ✅ 해결 확인
```bash
curl http://localhost:9090/users     # 200 OK
curl http://localhost:9090/products  # 200 OK
curl http://localhost:9090/orders    # 200 OK
```

---

## 🚨 시나리오 3: Traffic Splitting 미작동 (20분)

### 문제 상황
```bash
# 100번 호출해도 v2가 나오지 않음
for i in {1..100}; do 
  curl -s http://localhost:9090/users
done | grep "v2"
# (결과 없음)
```

### 🔍 확인해야 할 사항
1. User Service v2 Deployment가 정상 실행 중인가?
2. Pod의 라벨이 올바르게 설정되어 있는가?
3. DestinationRule의 subset 정의가 올바른가?
4. VirtualService의 weight 설정이 적용되고 있는가?

### 📋 문제 파일
- `broken-deployment-v2.yaml`
- `broken-destinationrule.yaml`

### ✅ 해결 확인
```bash
for i in {1..100}; do 
  curl -s http://localhost:9090/users
done | sort | uniq -c
# 약 90개 v1, 10개 v2 🚀
```

---

## 🚨 시나리오 4: Fault Injection 미작동 (20분)

### 문제 상황
```bash
# 지연이 발생하지 않음
for i in {1..10}; do
  time curl -s http://localhost:9090/products
done
# 모두 즉시 응답 (3초 지연 없음)

# 오류가 발생하지 않음
for i in {1..20}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9090/products
done
# 모두 200 (503 없음)
```

### 🔍 확인해야 할 사항
1. VirtualService에 fault 설정이 있는가?
2. Fault 설정의 위치가 올바른가?
3. Fault 설정의 문법이 올바른가?
4. Match 조건이 올바르게 설정되어 있는가?

### 📋 문제 파일
- `broken-fault-injection.yaml`

### ✅ 해결 확인
```bash
# 지연 테스트
for i in {1..10}; do
  echo -n "요청 $i: "
  time curl -s http://localhost:9090/products
done
# 약 50%는 3초 지연

# 오류 테스트
for i in {1..20}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9090/products
done | grep 503 | wc -l
# 약 4개 (20%)
```

---

## ✅ 최종 검증

### 자동 검증
```bash
./verify-solution.sh
```

### 수동 검증
```bash
# 1. 모든 경로 접근 확인
curl http://localhost:9090/users
curl http://localhost:9090/products
curl http://localhost:9090/orders

# 2. Traffic Splitting 확인
for i in {1..100}; do 
  curl -s http://localhost:9090/users
done | sort | uniq -c

# 3. Fault Injection 확인
for i in {1..20}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9090/products
done
```

---

## ✅ Challenge 체크포인트

### ✅ 시나리오 1: Gateway 설정
- [ ] Gateway 리소스 수정 완료
- [ ] Ingress Gateway Service 확인
- [ ] curl 테스트 성공

### ✅ 시나리오 2: VirtualService 라우팅
- [ ] 경로 설정 수정
- [ ] Destination host 수정
- [ ] 포트 설정 수정
- [ ] 모든 경로 정상 응답

### ✅ 시나리오 3: Traffic Splitting
- [ ] v2 Deployment 확인
- [ ] Pod 라벨 수정
- [ ] DestinationRule 수정
- [ ] 90/10 비율 확인

### ✅ 시나리오 4: Fault Injection
- [ ] Fault 설정 위치 수정
- [ ] Fault 문법 수정
- [ ] 지연 발생 확인
- [ ] 오류 발생 확인

---

## 🔍 유용한 디버깅 명령어

```bash
# 리소스 상태 확인
kubectl get gateway,virtualservice,destinationrule
kubectl get pods --show-labels
kubectl get svc

# 상세 정보 확인
kubectl describe gateway api-gateway
kubectl describe virtualservice api-routes
kubectl get virtualservice api-routes -o yaml

# 로그 확인
kubectl logs -n istio-system -l app=istio-ingressgateway --tail=50

# Istio 분석
istioctl analyze
```

---

## 🏆 도전 과제 (보너스)

### 추가 미션 1: 성능 최적화 (+10점)
- Circuit Breaker 설정
- Connection Pool 최적화
- Timeout 설정

### 추가 미션 2: 보안 강화 (+10점)
- mTLS 활성화
- Authorization Policy 설정
- Rate Limiting 구현

---

## 🧹 Challenge 정리

```bash
./cleanup.sh
```

---

## 💡 Challenge 회고

### 🤝 팀 회고 (15분)

**장애 대응 프로세스:**
1. 가장 어려웠던 시나리오는?
2. 효과적이었던 디버깅 방법은?
3. 팀워크에서 배운 점은?
4. 실무에 적용할 수 있는 교훈은?

**개선 방안:**
1. 더 빠르게 해결하려면?
2. 예방할 수 있었던 문제는?
3. 모니터링으로 조기 발견 가능한가?
4. 자동화할 수 있는 부분은?

### 📊 학습 성과
- **장애 진단**: 체계적인 문제 해결 프로세스 습득
- **Istio 전문성**: 실무 트러블슈팅 능력 향상
- **팀 협업**: 역할 분담 및 효율적 소통
- **문서화**: 장애 보고서 작성 능력

---

## 📝 장애 보고서 템플릿

```markdown
# 장애 보고서

## 기본 정보
- 발생 시간: YYYY-MM-DD HH:MM
- 영향 범위: [서비스명]
- 심각도: Critical / High / Medium / Low

## 증상
- [구체적인 증상 설명]

## 근본 원인
- [근본 원인 분석]

## 해결 방법
- [적용한 해결책]

## 재발 방지
- [예방 대책]

## 교훈
- [배운 점]
```

---

<div align="center">

**🚨 신속한 장애 대응** • **🔍 정확한 원인 분석** • **🛠️ 효과적인 해결**

*실무 장애 대응 능력 완벽 마스터*

</div>
