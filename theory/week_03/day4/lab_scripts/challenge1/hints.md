# Week 3 Day 4 Challenge 1 - 힌트

## 🚨 문제 1: RBAC 권한 오류 (25분)

### 💡 힌트 1 (5분 후)
```bash
# ServiceAccount와 RoleBinding 확인
kubectl get sa -n securebank
kubectl get rolebinding developer-binding -n securebank -o yaml
```

### 💡 힌트 2 (10분 후)
- RoleBinding의 `subjects` 섹션을 확인하세요
- ServiceAccount 이름이 실제로 존재하는지 확인하세요

### 💡 힌트 3 (15분 후)
- Role의 `verbs`를 확인하세요
- Pod를 생성하려면 어떤 권한이 필요할까요?
- 로그를 보려면 `list`가 아닌 다른 권한이 필요합니다

### 🔍 확인 명령어
```bash
# 권한 테스트
kubectl auth can-i create pods --as=system:serviceaccount:securebank:developer-sa -n securebank
kubectl auth can-i get pods/log --as=system:serviceaccount:securebank:developer-sa -n securebank
```

---

## 🔐 문제 2: 인증서 갱신 테스트 (25분)

### 💡 힌트 1 (5분 후)
```bash
# cert-checker Pod 접속
kubectl exec -it cert-checker -n securebank -- /bin/sh
```

### 💡 힌트 2 (10분 후)
- Kind 클러스터에서는 실제 인증서 만료를 시뮬레이션하기 어렵습니다
- ServiceAccount 토큰의 만료 시간을 확인하세요
- ConfigMap의 스크립트를 실행해보세요

### 💡 힌트 3 (15분 후)
```bash
# 실제 환경에서 사용할 명령어들
# kubeadm certs check-expiration
# kubeadm certs renew all

# Kind 환경에서는 이론적 이해에 집중
```

### 🔍 확인 명령어
```bash
# ServiceAccount 토큰 확인
kubectl get secret -n securebank
kubectl describe sa developer-sa -n securebank
```

---

## 🌐 문제 3: Network Policy 차단 (20분)

### 💡 힌트 1 (5분 후)
```bash
# Network Policy 확인
kubectl get networkpolicy -n securebank
kubectl describe networkpolicy backend-policy -n securebank
```

### 💡 힌트 2 (10분 후)
- `podSelector`의 라벨이 실제 Pod의 라벨과 일치하는지 확인하세요
- Backend Pod의 실제 라벨을 확인하세요: `kubectl get pod -n securebank --show-labels`

### 💡 힌트 3 (15분 후)
- Backend 서비스는 8080 포트를 사용합니다
- Database Policy에 ingress 규칙이 없으면 모든 트래픽이 차단됩니다

### 🔍 확인 명령어
```bash
# Pod 라벨 확인
kubectl get pods -n securebank --show-labels

# 네트워크 연결 테스트
kubectl run test-pod --rm -it --image=busybox -n securebank -- wget -O- backend-service:8080
```

---

## 🔓 문제 4: Secret 노출 (20분)

### 💡 힌트 1 (5분 후)
```bash
# ConfigMap 확인
kubectl get configmap app-config -n securebank -o yaml

# Deployment 환경변수 확인
kubectl get deployment backend -n securebank -o yaml | grep -A 10 env
```

### 💡 힌트 2 (10분 후)
- ConfigMap은 민감하지 않은 설정 데이터용입니다
- 비밀번호, API 키 등은 Secret을 사용해야 합니다
- 환경변수에 평문 비밀번호를 직접 넣으면 안 됩니다

### 💡 힌트 3 (15분 후)
```bash
# Secret 생성 예시
kubectl create secret generic db-secret \
  --from-literal=password=supersecret123 \
  -n securebank
```

### 🔍 확인 명령어
```bash
# Secret 확인
kubectl get secrets -n securebank
kubectl describe secret db-secret -n securebank

# Pod에서 Secret 사용 확인
kubectl get pod -n securebank -l app=backend -o yaml | grep -A 5 secretKeyRef
```

---

## 🎯 전체 진행 상황 확인

```bash
# 모든 리소스 상태
kubectl get all -n securebank

# 이벤트 확인
kubectl get events -n securebank --sort-by='.lastTimestamp'

# Pod 로그 확인
kubectl logs -n securebank -l app=backend
```

---

## 💡 일반적인 디버깅 팁

1. **RBAC 문제**:
   - `kubectl auth can-i` 명령어로 권한 확인
   - `kubectl describe` 로 상세 정보 확인

2. **Network Policy 문제**:
   - 라벨 셀렉터가 정확한지 확인
   - 포트 번호가 올바른지 확인
   - 기본 정책은 deny-all입니다

3. **Secret 관리**:
   - ConfigMap vs Secret 용도 구분
   - Secret은 base64 인코딩됨 (암호화 아님)
   - 환경변수보다 볼륨 마운트 권장

4. **인증서 관리**:
   - 만료 전 갱신 필요
   - 자동 갱신 설정 권장
   - 모니터링 및 알림 설정
