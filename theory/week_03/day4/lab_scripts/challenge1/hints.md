# Challenge 1 힌트

## 🚨 문제 1: RBAC 권한 오류

### 힌트 1
RoleBinding의 subjects를 확인해보세요. ServiceAccount 이름이 정확한가요?

### 힌트 2
Role의 verbs를 확인해보세요. Pod를 생성하려면 어떤 verb가 필요할까요?

### 힌트 3
로그를 조회하려면 `pods/log` 리소스에 `get` verb가 필요합니다.

### 해결 방법
```bash
# RoleBinding 수정
kubectl edit rolebinding developer-binding -n securebank
# subjects.name을 developer-sa로 수정

# Role 수정
kubectl edit role developer-role -n securebank
# verbs에 "create" 추가
# pods/log에 "get" 추가
```

---

## 🚨 문제 2: 인증서 만료

### 힌트 1
`kubeadm certs check-expiration` 명령어로 인증서 상태를 확인하세요.

### 힌트 2
`kubeadm certs renew all` 명령어로 모든 인증서를 갱신할 수 있습니다.

### 힌트 3
인증서 갱신 후 kubelet을 재시작해야 합니다.

### 해결 방법
```bash
# 인증서 확인
kubeadm certs check-expiration

# 인증서 갱신
sudo kubeadm certs renew all

# kubelet 재시작
sudo systemctl restart kubelet

# 확인
kubectl get nodes
```

---

## 🚨 문제 3: Network Policy 차단

### 힌트 1
Network Policy의 podSelector 라벨이 실제 Pod 라벨과 일치하나요?

### 힌트 2
backend Pod의 실제 라벨을 확인해보세요: `kubectl get pods -n securebank --show-labels`

### 힌트 3
포트 번호가 올바른가요? backend 서비스는 8080 포트를 사용합니다.

### 해결 방법
```bash
# Pod 라벨 확인
kubectl get pods -n securebank --show-labels

# Network Policy 수정
kubectl edit networkpolicy backend-policy -n securebank
# podSelector.matchLabels.tier를 "api"로 수정
# port를 8080으로 수정

kubectl edit networkpolicy database-policy -n securebank
# ingress 규칙 추가
```

---

## 🚨 문제 4: Secret 노출

### 힌트 1
환경변수에 평문으로 비밀번호가 노출되어 있습니다.

### 힌트 2
Secret 리소스를 생성하고 Deployment에서 참조해야 합니다.

### 힌트 3
`secretKeyRef`를 사용하여 Secret을 환경변수로 주입하세요.

### 해결 방법
```bash
# Secret 생성
kubectl create secret generic database-credentials \
  --from-literal=password=supersecret123 \
  -n securebank

# Deployment 수정
kubectl edit deployment backend -n securebank
# env 섹션을 다음과 같이 수정:
# - name: DATABASE_PASSWORD
#   valueFrom:
#     secretKeyRef:
#       name: database-credentials
#       key: password
```

---

## 💡 추가 팁

### RBAC 디버깅
```bash
# 권한 확인
kubectl auth can-i <verb> <resource> --as=<user> -n <namespace>

# 상세 권한 목록
kubectl auth can-i --list --as=<user> -n <namespace>
```

### Network Policy 디버깅
```bash
# 연결 테스트
kubectl exec -it <pod> -n <namespace> -- nc -zv <service> <port>

# Pod 라벨 확인
kubectl get pods --show-labels -n <namespace>
```

### Secret 디버깅
```bash
# Secret 확인
kubectl get secret <secret-name> -n <namespace> -o yaml

# Deployment 환경변수 확인
kubectl get deployment <deployment-name> -n <namespace> -o yaml | grep -A 10 env:
```
