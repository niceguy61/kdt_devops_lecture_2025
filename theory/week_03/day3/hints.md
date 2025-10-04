# Week 3 Day 3 Challenge 1: 힌트 가이드

<div align="center">

**💡 단계별 힌트** • **🔍 진단 방향** • **🛠️ 해결 실마리**

*막힐 때 참고하세요 - 스스로 해결하는 것이 최고의 학습입니다!*

</div>

---

## 🎯 힌트 사용 가이드

### 📋 힌트 레벨
- **Level 1**: 문제 영역 힌트 (어디를 봐야 하는가)
- **Level 2**: 진단 방법 힌트 (어떻게 확인하는가)
- **Level 3**: 해결 방향 힌트 (무엇을 수정해야 하는가)

### ⚠️ 권장 사항
1. **먼저 스스로 시도**: 최소 10분은 직접 시도
2. **Level 1부터**: 낮은 레벨부터 순차적으로 확인
3. **팀과 상의**: 힌트를 보기 전에 팀원과 토론
4. **이해 후 진행**: 힌트를 이해한 후 직접 해결

---

## 🚨 시나리오 1: DNS 해결 실패 (25분)

### 💡 Level 1: 문제 영역
<details>
<summary>클릭하여 힌트 보기</summary>

**문제 영역**: Service와 DNS 관련
- Service가 제대로 생성되었는지 확인
- Endpoint가 올바르게 연결되었는지 확인
- CoreDNS가 정상 동작하는지 확인

**확인 명령어**:
```bash
kubectl get svc -n day3-challenge
kubectl get endpoints -n day3-challenge
kubectl get pods -n kube-system -l k8s-app=kube-dns
```
</details>

### 🔍 Level 2: 진단 방법
<details>
<summary>클릭하여 힌트 보기</summary>

**진단 포인트**:
1. **Service 이름 확인**: Service 이름이 애플리케이션에서 사용하는 이름과 일치하는가?
2. **Selector 확인**: Service의 selector가 Pod의 label과 일치하는가?
3. **DNS 테스트**: Pod 내부에서 nslookup으로 DNS 해결 테스트

**진단 명령어**:
```bash
# Service 상세 정보
kubectl describe svc backend-service -n day3-challenge

# Pod 라벨 확인
kubectl get pods -n day3-challenge --show-labels

# DNS 테스트
kubectl run dns-test --image=busybox:1.35 --rm -it --restart=Never -n day3-challenge -- nslookup backend-service
```
</details>

### 🛠️ Level 3: 해결 방향
<details>
<summary>클릭하여 힌트 보기</summary>

**해결 방향**:
- Service의 **selector**가 잘못되어 있을 가능성
- Pod의 실제 label과 Service selector를 비교
- `kubectl edit svc backend-service -n day3-challenge`으로 수정

**체크 포인트**:
```yaml
# Service selector 확인
spec:
  selector:
    app: ???  # Pod의 label과 일치해야 함
```
</details>

---

## 🚨 시나리오 2: Ingress 라우팅 오류 (25분)

### 💡 Level 1: 문제 영역
<details>
<summary>클릭하여 힌트 보기</summary>

**문제 영역**: Ingress 설정과 Service 연결
- Ingress 리소스가 제대로 생성되었는지 확인
- Ingress Controller가 정상 동작하는지 확인
- 백엔드 Service가 존재하는지 확인

**확인 명령어**:
```bash
kubectl get ingress -n day3-challenge
kubectl describe ingress eshop-ingress -n day3-challenge
kubectl get svc -n day3-challenge
```
</details>

### 🔍 Level 2: 진단 방법
<details>
<summary>클릭하여 힌트 보기</summary>

**진단 포인트**:
1. **Ingress 백엔드**: Ingress가 참조하는 Service 이름이 올바른가?
2. **Service 포트**: Ingress에서 지정한 포트가 Service 포트와 일치하는가?
3. **Ingress 상태**: Ingress에 ADDRESS가 할당되었는가?

**진단 명령어**:
```bash
# Ingress 상세 정보
kubectl describe ingress eshop-ingress -n day3-challenge

# Service 포트 확인
kubectl get svc -n day3-challenge -o wide

# Ingress Controller 로그
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```
</details>

### 🛠️ Level 3: 해결 방향
<details>
<summary>클릭하여 힌트 보기</summary>

**해결 방향**:
- Ingress의 **backend service 이름**이 잘못되어 있을 가능성
- Service 이름과 포트 번호를 정확히 확인
- `kubectl edit ingress eshop-ingress -n day3-challenge`으로 수정

**체크 포인트**:
```yaml
# Ingress backend 확인
spec:
  rules:
  - host: shop.local
    http:
      paths:
      - path: /
        backend:
          service:
            name: ???  # 실제 Service 이름
            port:
              number: ???  # 실제 Service 포트
```
</details>

---

## 🚨 시나리오 3: PVC 바인딩 실패 (20분)

### 💡 Level 1: 문제 영역
<details>
<summary>클릭하여 힌트 보기</summary>

**문제 영역**: PVC와 PV 바인딩
- PVC 상태 확인 (Pending인가?)
- PV가 존재하는지 확인
- StorageClass 확인

**확인 명령어**:
```bash
kubectl get pvc -n day3-challenge
kubectl get pv
kubectl get storageclass
```
</details>

### 🔍 Level 2: 진단 방법
<details>
<summary>클릭하여 힌트 보기</summary>

**진단 포인트**:
1. **PVC 요청 크기**: 요청한 스토리지 크기가 현실적인가?
2. **StorageClass**: PVC가 참조하는 StorageClass가 존재하는가?
3. **PV 가용성**: 사용 가능한 PV가 있는가?

**진단 명령어**:
```bash
# PVC 상세 정보
kubectl describe pvc postgres-data -n day3-challenge

# PV 상태 확인
kubectl get pv -o wide

# StorageClass 확인
kubectl get storageclass
```
</details>

### 🛠️ Level 3: 해결 방향
<details>
<summary>클릭하여 힌트 보기</summary>

**해결 방향**:
- PVC의 **스토리지 크기**가 너무 크거나 **StorageClass**가 잘못되었을 가능성
- 현실적인 크기로 수정하거나 올바른 StorageClass 지정
- PVC를 삭제하고 재생성

**체크 포인트**:
```yaml
# PVC 스토리지 요청 확인
spec:
  resources:
    requests:
      storage: ???  # 현실적인 크기 (예: 1Gi, 5Gi)
  storageClassName: ???  # 존재하는 StorageClass
```
</details>

---

## 🚨 시나리오 4: Network Policy 차단 (20분)

### 💡 Level 1: 문제 영역
<details>
<summary>클릭하여 힌트 보기</summary>

**문제 영역**: Network Policy 설정
- Network Policy가 존재하는지 확인
- 정책이 어떤 트래픽을 차단하는지 확인
- Pod 간 통신이 허용되어야 하는지 확인

**확인 명령어**:
```bash
kubectl get networkpolicy -n day3-challenge
kubectl describe networkpolicy -n day3-challenge
```
</details>

### 🔍 Level 2: 진단 방법
<details>
<summary>클릭하여 힌트 보기</summary>

**진단 포인트**:
1. **Ingress 규칙**: 어떤 Pod에서 들어오는 트래픽을 허용하는가?
2. **Egress 규칙**: 어떤 Pod로 나가는 트래픽을 허용하는가?
3. **기본 정책**: 규칙이 없으면 모든 트래픽이 차단됨

**진단 명령어**:
```bash
# Network Policy 상세 정보
kubectl describe networkpolicy -n day3-challenge

# Pod 간 연결 테스트
kubectl exec -it deployment/frontend -n day3-challenge -- nc -zv backend-service 3000
```
</details>

### 🛠️ Level 3: 해결 방향
<details>
<summary>클릭하여 힌트 보기</summary>

**해결 방향**:
- Network Policy의 **ingress/egress 규칙**이 너무 제한적일 가능성
- 필요한 트래픽을 허용하도록 규칙 추가
- 또는 테스트 중에는 Network Policy를 임시로 삭제

**해결 옵션**:
```bash
# 옵션 1: Network Policy 수정
kubectl edit networkpolicy <policy-name> -n day3-challenge

# 옵션 2: 임시 삭제 (테스트용)
kubectl delete networkpolicy --all -n day3-challenge
```

**체크 포인트**:
```yaml
# Network Policy 규칙 확인
spec:
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: ???  # 허용할 Pod의 label
```
</details>

---

## 🎯 일반적인 디버깅 팁

### 🔍 체계적 진단 순서
1. **상태 확인**: `kubectl get` 명령어로 리소스 상태 확인
2. **상세 정보**: `kubectl describe` 명령어로 이벤트 및 상세 정보 확인
3. **로그 확인**: `kubectl logs` 명령어로 애플리케이션 로그 확인
4. **연결 테스트**: `kubectl exec`로 Pod 내부에서 연결 테스트
5. **설정 검증**: YAML 파일의 오타나 잘못된 참조 확인

### 🛠️ 유용한 디버깅 명령어
```bash
# 전체 리소스 상태 확인
kubectl get all -n day3-challenge

# 이벤트 확인
kubectl get events -n day3-challenge --sort-by='.lastTimestamp'

# Pod 로그 확인
kubectl logs <pod-name> -n day3-challenge

# Pod 내부 접속
kubectl exec -it <pod-name> -n day3-challenge -- /bin/sh

# 네트워크 연결 테스트
kubectl exec -it <pod-name> -n day3-challenge -- nc -zv <service-name> <port>

# DNS 테스트
kubectl exec -it <pod-name> -n day3-challenge -- nslookup <service-name>
```

### 💡 문제 해결 체크리스트
- [ ] **이름 확인**: Service, Pod, Ingress 이름이 올바른가?
- [ ] **Label 확인**: Selector와 Label이 일치하는가?
- [ ] **포트 확인**: 포트 번호가 정확한가?
- [ ] **네임스페이스**: 모든 리소스가 같은 네임스페이스에 있는가?
- [ ] **리소스 존재**: 참조하는 리소스가 실제로 존재하는가?

---

## 🤝 팀 협업 팁

### 역할 분담
- **진단 담당**: 문제 영역 파악 및 로그 분석
- **해결 담당**: 설정 수정 및 리소스 재배포
- **검증 담당**: 수정 후 동작 확인 및 테스트
- **문서 담당**: 해결 과정 기록 및 공유

### 효과적인 협업
1. **정보 공유**: 발견한 내용을 즉시 팀원과 공유
2. **역할 교대**: 막히면 역할을 바꿔서 새로운 시각 확보
3. **페어 디버깅**: 두 명이 함께 문제를 분석
4. **타임박스**: 한 가지 접근법에 너무 오래 매달리지 않기

---

<div align="center">

**💡 힌트는 학습 도구** • **🔍 스스로 해결이 최고** • **🤝 팀과 함께 성장**

*막힐 때는 힌트를 참고하되, 스스로 해결하는 경험이 가장 중요합니다!*

</div>
