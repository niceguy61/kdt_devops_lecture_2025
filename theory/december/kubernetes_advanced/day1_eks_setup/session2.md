# Session 2: 노드 그룹 + 접근 설정 (50분)

## 🎯 세션 목표
- 생성된 EKS 클러스터 상태 확인
- AWS 리소스 및 IAM 역할 이해
- 기본 kubectl 명령어로 클러스터 테스트

## ⏰ 시간 배분
- **실습** (40분): 클러스터 상태 확인 및 설정
- **정리** (10분): 체크포인트 확인

---

## 🛠️ 실습: 클러스터 상태 확인 및 설정 (40분)

### 1. 클러스터 연결 확인 (10분)

#### kubeconfig 자동 설정 확인
```bash
# 현재 컨텍스트 확인
kubectl config current-context

# 클러스터 정보 확인
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes -o wide
```

**예상 출력:**
```
NAME                                               STATUS   ROLES    AGE   VERSION
ip-10-0-1-100.ap-northeast-2.compute.internal    Ready    <none>   5m    v1.28.3-eks-4f4795d
ip-10-0-2-200.ap-northeast-2.compute.internal    Ready    <none>   5m    v1.28.3-eks-4f4795d
```

### 2. AWS 리소스 확인 (10분)

#### EKS 클러스터 상세 정보
```bash
# 클러스터 상세 정보
aws eks describe-cluster --name my-eks-cluster --region ap-northeast-2

# 노드 그룹 정보
aws eks describe-nodegroup \
  --cluster-name my-eks-cluster \
  --nodegroup-name worker-nodes \
  --region ap-northeast-2
```

#### VPC 및 네트워킹 확인
```bash
# VPC 정보 확인
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=eksctl-my-eks-cluster-cluster/VPC"

# 서브넷 확인
aws ec2 describe-subnets \
  --filters "Name=tag:kubernetes.io/cluster/my-eks-cluster,Values=shared"
```

### 3. IAM 역할 및 정책 확인 (10분)

#### 클러스터 서비스 역할
```bash
# 클러스터 서비스 역할 확인
aws iam get-role --role-name eksctl-my-eks-cluster-cluster-ServiceRole

# 연결된 정책 확인
aws iam list-attached-role-policies \
  --role-name eksctl-my-eks-cluster-cluster-ServiceRole
```

#### 노드 그룹 인스턴스 역할
```bash
# 노드 그룹 인스턴스 역할 확인
aws iam get-role --role-name eksctl-my-eks-cluster-nodegroup-worker-nodes-NodeInstanceRole

# 연결된 정책 확인
aws iam list-attached-role-policies \
  --role-name eksctl-my-eks-cluster-nodegroup-worker-nodes-NodeInstanceRole
```

**주요 정책들:**
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`

### 4. 시스템 컴포넌트 확인 (5분)

#### EKS 시스템 Pod 상태 확인
```bash
# kube-system 네임스페이스 전체 확인
kubectl get all -n kube-system

# VPC CNI (네트워킹) 확인
kubectl get pods -n kube-system -l k8s-app=aws-node
kubectl describe daemonset aws-node -n kube-system

# CoreDNS (DNS) 확인  
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl describe deployment coredns -n kube-system

# kube-proxy (서비스 프록시) 확인
kubectl get pods -n kube-system -l k8s-app=kube-proxy
kubectl describe daemonset kube-proxy -n kube-system
```

### 5. 기본 테스트 Pod 배포 (5분)

#### 테스트 Pod 생성 및 확인
```bash
# 테스트 Pod 생성
kubectl run test-pod --image=nginx --port=80

# Pod 상태 확인
kubectl get pods -o wide

# Pod 상세 정보
kubectl describe pod test-pod

# Pod 로그 확인
kubectl logs test-pod
```

#### 네트워킹 테스트
```bash
# Pod IP 확인
kubectl get pod test-pod -o jsonpath='{.status.podIP}'

# 다른 Pod에서 접근 테스트
kubectl run test-client --image=busybox --rm -it --restart=Never \
  -- wget -qO- http://[POD-IP]
```

#### 정리
```bash
# 테스트 Pod 삭제
kubectl delete pod test-pod
```

---

## ✅ 체크포인트 (10분)

### 완료 확인 사항
- [ ] EKS 클러스터가 **Active** 상태
- [ ] 워커 노드 **2개**가 **Ready** 상태
- [ ] kubectl 명령어가 정상 작동
- [ ] 테스트 Pod 배포 및 삭제 성공
- [ ] AWS 콘솔에서 생성된 리소스 확인

### 클러스터 상태 최종 확인
```bash
# 전체 리소스 확인
kubectl get all --all-namespaces

# 노드 리소스 사용량 확인
kubectl top nodes  # metrics-server 설치 후 사용 가능

# 클러스터 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp
```

### AWS 콘솔 확인 사항
1. **EKS 콘솔**: 클러스터 상태 Active
2. **EC2 콘솔**: 워커 노드 인스턴스 2개 Running
3. **VPC 콘솔**: 새로 생성된 VPC 및 서브넷
4. **IAM 콘솔**: 생성된 역할 및 정책

---

## 🎯 세션 완료 후 상태

### 생성된 AWS 리소스
```
EKS Cluster: my-eks-cluster
├── Control Plane (AWS 관리)
├── Worker Nodes (2개 EC2 인스턴스)
├── VPC (10.0.0.0/16)
│   ├── Public Subnets (2개)
│   ├── Private Subnets (2개)
│   └── NAT Gateway (1개)
└── IAM Roles & Policies
```

### kubectl 컨텍스트
```bash
# 현재 설정된 컨텍스트
kubectl config current-context
# arn:aws:eks:ap-northeast-2:ACCOUNT-ID:cluster/my-eks-cluster
```

---

## 🔄 다음 세션 준비

### Day 2 예습 내용
- kubectl 기본 명령어 복습
- Kubernetes 기본 오브젝트 (Pod, Service, Deployment) 개념
- 네임스페이스 관리

### 숙제
1. AWS 콘솔에서 생성된 모든 리소스 확인
2. kubectl 치트시트 숙지
3. 클러스터 비용 계산해보기 (EC2 + EKS 요금)

---

## 🛠️ 추가: EKS 관리 도구 설치 (보너스)

### 필수 관리 도구 설치
```bash
# k9s 설치 (Kubernetes CLI 대시보드)
curl -sS https://webinstall.dev/k9s | bash

# kubectl 플러그인 관리자 (Krew) 설치
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# 유용한 kubectl 플러그인 설치
kubectl krew install ctx ns tree get-all stern

# 사용법
k9s                    # Kubernetes 대시보드 실행
kubectl ctx            # 컨텍스트 목록
kubectl ns             # 네임스페이스 목록
kubectl tree deploy    # Deployment 트리 보기
```

### Metrics Server 설치 (리소스 모니터링용)
```bash
# Metrics Server 설치
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 설치 확인 (몇 분 후)
kubectl get deployment metrics-server -n kube-system

# 사용법 (설치 완료 후)
kubectl top nodes      # 노드 리소스 사용량
kubectl top pods       # Pod 리소스 사용량
```

### 클러스터 상태 모니터링
```bash
# k9s로 실시간 모니터링
k9s

# 주요 k9s 단축키:
# :pods    - Pod 보기
# :svc     - Service 보기  
# :deploy  - Deployment 보기
# :logs    - 로그 보기
# :shell   - Pod 쉘 접근
# s        - 쉘 접근
# l        - 로그 보기
# d        - 상세 정보
```
