# Week 3 Day 1 Lab 1: kubeadm 클러스터 구축

<div align="center">
**🛠️ kubeadm 설치** • **🏗️ 클러스터 구축** • **✅ 기본 검증**
*Kubernetes 구성요소를 직접 설치하며 아키텍처 이해*
</div>

---

## 🕘 실습 정보
**시간**: 12:00-12:50 (50분)
**목표**: kubeadm을 이용한 로컬 Kubernetes 클러스터 구축
**방식**: 단계별 가이드 + 페어 프로그래밍

## 🎯 실습 목표
### 📚 당일 이론 적용
- Session 1-3에서 배운 Kubernetes 구성요소 직접 설치
- Control Plane과 Worker Node의 실제 동작 확인
- kubectl을 통한 클러스터 상태 모니터링

### 🤝 협업 학습
- 페어 프로그래밍으로 설치 과정 공유
- 문제 발생 시 함께 트러블슈팅
- 설치 결과 비교 및 경험 공유

---

## 📋 실습 준비 (5분)

### 환경 설정
- **운영체제**: Ubuntu 20.04 LTS 또는 CentOS 8
- **최소 사양**: CPU 2코어, RAM 4GB, 디스크 20GB
- **네트워크**: 인터넷 연결 및 방화벽 설정 확인
- **권한**: sudo 권한 보유 확인

### 페어 구성
- 👥 **페어 매칭**: 경험 수준이 다른 사람끼리 매칭
- 🔄 **역할 분담**: Driver(실행자) / Navigator(가이드) 역할 교대
- 📝 **진행 기록**: 각 단계별 결과와 문제점 기록

---

## 🔧 실습 단계 (40분)

### Step 1: 환경 준비 (15분)

#### 1-1. Docker 설치 및 설정
```bash
# Docker 설치 (Ubuntu)
sudo apt-get update
sudo apt-get install -y docker.io

# Docker 서비스 시작 및 활성화
sudo systemctl enable docker
sudo systemctl start docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# Docker 설치 확인
docker --version
sudo docker run hello-world
```

#### 1-2. Kubernetes 패키지 저장소 추가
```bash
# 필요한 패키지 설치
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Google Cloud 공개 서명 키 추가
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

# Kubernetes apt 저장소 추가
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

#### 1-3. kubeadm, kubelet, kubectl 설치
```bash
# 패키지 목록 업데이트
sudo apt-get update

# Kubernetes 도구 설치
sudo apt-get install -y kubelet kubeadm kubectl

# 패키지 자동 업데이트 방지
sudo apt-mark hold kubelet kubeadm kubectl

# 설치 확인
kubeadm version
kubelet --version
kubectl version --client
```

### Step 2: 클러스터 초기화 (15분)

#### 2-1. 시스템 설정
```bash
# swap 비활성화 (Kubernetes 요구사항)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 브리지 네트워크 설정
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system
```

#### 2-2. kubeadm으로 클러스터 초기화
```bash
# 클러스터 초기화 (Pod 네트워크 CIDR 지정)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# 초기화 성공 시 출력되는 join 명령어 저장
# 예: kubeadm join 192.168.1.100:6443 --token abc123.xyz789 --discovery-token-ca-cert-hash sha256:...
```

#### 2-3. kubectl 설정
```bash
# kubectl 설정 디렉토리 생성
mkdir -p $HOME/.kube

# admin.conf 파일 복사
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# 파일 소유권 변경
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubectl 자동완성 설정
echo 'source <(kubectl completion bash)' >>~/.bashrc
source ~/.bashrc
```

### Step 3: 검증 및 테스트 (10분)

#### 3-1. 클러스터 상태 확인
```bash
# 노드 상태 확인
kubectl get nodes

# 시스템 Pod 상태 확인
kubectl get pods -A

# 클러스터 정보 확인
kubectl cluster-info

# Control Plane 구성요소 확인
kubectl get pods -n kube-system
```

#### 3-2. 네트워크 플러그인 설치 (Flannel)
```bash
# Flannel CNI 플러그인 설치
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# 설치 확인
kubectl get pods -n kube-flannel

# 노드 Ready 상태 확인
kubectl get nodes
```

#### 3-3. 테스트 Pod 배포
```bash
# 테스트 Pod 생성
kubectl run test-pod --image=nginx --port=80

# Pod 상태 확인
kubectl get pods

# Pod 세부 정보 확인
kubectl describe pod test-pod

# Pod 로그 확인
kubectl logs test-pod
```

---

## ✅ 실습 체크포인트

### 필수 확인 사항
- [ ] **Docker 설치 완료**: `docker --version` 명령어 실행 성공
- [ ] **kubeadm 설치 완료**: `kubeadm version` 명령어 실행 성공
- [ ] **클러스터 초기화 성공**: `kubectl get nodes` 에서 Master 노드 확인
- [ ] **네트워크 플러그인 설치**: 노드 상태가 Ready로 변경
- [ ] **테스트 Pod 실행**: nginx Pod가 Running 상태

### 상태 확인 명령어
```bash
# 전체 상태 종합 확인
echo "=== 노드 상태 ==="
kubectl get nodes

echo "=== 시스템 Pod 상태 ==="
kubectl get pods -A

echo "=== 테스트 Pod 상태 ==="
kubectl get pods

echo "=== 클러스터 정보 ==="
kubectl cluster-info
```

---

## 🔄 실습 마무리 (5분)

### 결과 공유
**페어별 발표** (각 2분):
- 설치 과정에서 가장 어려웠던 부분
- kubeadm init 실행 시 출력된 주요 정보
- kubectl get pods -A 결과 화면 공유
- Session 1에서 배운 구성요소들이 실제로 어떻게 보이는지

### 질문 해결
**공통 문제 해결**:
- swap 비활성화 관련 이슈
- 네트워크 플러그인 설치 문제
- kubectl 권한 설정 문제
- 방화벽 설정 관련 이슈

### 다음 연결
**Lab 2 준비**:
- 로컬 클러스터와 EKS의 차이점 예상해보기
- AWS CLI 설치 및 자격 증명 설정 확인
- EKS에서 확인하고 싶은 기능들 정리

---

## 🎯 학습 성과 확인

### 이론-실습 연결
- **Session 1 연결**: API Server, etcd, kubelet 등이 실제 Pod로 실행되는 것 확인
- **Session 2 연결**: kubeadm 설치의 복잡성과 수동 설정의 필요성 체험
- **Session 3 연결**: 다음 Lab에서 EKS의 간편함과 비교할 기준점 마련

### 실무 인사이트
- **설치 복잡성**: 프로덕션 환경에서 kubeadm 사용 시 고려사항
- **구성요소 이해**: 각 구성요소의 실제 역할과 상호작용 방식
- **트러블슈팅**: 설치 과정에서 발생하는 일반적인 문제들

---

<div align="center">

**🎉 Lab 1 완료!**

*kubeadm으로 Kubernetes의 내부 구조를 직접 체험했습니다*

</div>