# 🎨 Kubernetes 클러스터 모니터링 GUI 도구 가이드

<div align="center">

**🖥️ CLI 기반 시각화** • **📊 실시간 모니터링** • **🔍 클러스터 탐험**

*터미널에서 Kubernetes 클러스터를 시각적으로 관리하고 모니터링하는 도구들*

</div>

---

## 🎯 도구 개요

### 📊 추천 도구 비교

| 도구 | 타입 | 난이도 | 주요 기능 | 교육 적합도 |
|------|------|--------|-----------|-------------|
| **k9s** | TUI | ⭐⭐ | 실시간 대시보드, 로그 확인 | ⭐⭐⭐⭐⭐ |
| **kubectl tree** | CLI | ⭐ | 리소스 관계 트리 | ⭐⭐⭐⭐ |
| **kubectx/kubens** | CLI | ⭐ | 컨텍스트/네임스페이스 전환 | ⭐⭐⭐⭐ |
| **stern** | CLI | ⭐⭐ | 멀티 Pod 로그 스트리밍 | ⭐⭐⭐ |
| **dive** | TUI | ⭐⭐ | 컨테이너 이미지 분석 | ⭐⭐⭐ |
| **kubecost** | Web UI | ⭐⭐⭐ | 비용 분석 및 최적화 | ⭐⭐⭐⭐ |

---

## 🚀 1. k9s - 최고의 Kubernetes TUI

### 📦 설치 방법

**macOS:**
```bash
# Homebrew 사용
brew install k9s

# 또는 직접 다운로드
curl -sS https://webinstall.dev/k9s | bash
```

**Linux:**
```bash
# 최신 릴리스 다운로드
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -sL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz | tar xz
sudo mv k9s /usr/local/bin/
```

**Windows:**
```powershell
# Chocolatey 사용
choco install k9s

# 또는 Scoop 사용
scoop install k9s
```

### 🎮 기본 사용법

```bash
# k9s 실행
k9s

# 특정 네임스페이스로 시작
k9s -n kube-system

# 특정 컨텍스트로 시작
k9s --context my-cluster
```

### ⌨️ 핵심 단축키

| 키 | 기능 | 설명 |
|----|------|------|
| `:pods` | Pod 뷰 | 모든 Pod 확인 |
| `:svc` | Service 뷰 | 서비스 목록 |
| `:deploy` | Deployment 뷰 | 배포 상태 |
| `:nodes` | Node 뷰 | 노드 상태 |
| `Enter` | 상세 보기 | 선택한 리소스 상세 정보 |
| `l` | 로그 보기 | Pod 로그 실시간 확인 |
| `d` | Describe | kubectl describe 실행 |
| `e` | 편집 | 리소스 편집 |
| `Ctrl+d` | 삭제 | 리소스 삭제 |
| `/` | 검색 | 리소스 검색 |
| `?` | 도움말 | 전체 단축키 확인 |

### 🎯 실습 시나리오

**시나리오 1: 클러스터 전체 상태 확인**
```bash
# k9s 실행
k9s

# 1. 노드 상태 확인
:nodes

# 2. 시스템 Pod 확인
:pods
# 네임스페이스를 kube-system으로 변경 (Ctrl+n)

# 3. 전체 네임스페이스 리소스 확인
:all
```

**시나리오 2: 애플리케이션 디버깅**
```bash
# 문제가 있는 Pod 찾기
:pods
# 상태가 Error나 CrashLoopBackOff인 Pod 선택

# 로그 확인 (l 키)
# Describe 확인 (d 키)
# 이벤트 확인 (:events)
```

---

## 🌳 2. kubectl tree - 리소스 관계 시각화

### 📦 설치 방법

```bash
# kubectl krew 플러그인 매니저 설치
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# PATH에 추가
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# tree 플러그인 설치
kubectl krew install tree
```

### 🎮 사용법

```bash
# Deployment와 관련된 모든 리소스 트리
kubectl tree deployment nginx-deployment

# 네임스페이스 전체 리소스 트리
kubectl tree namespace default

# 특정 리소스 타입 트리
kubectl tree service my-service
```

### 📊 출력 예시

```
NAMESPACE/default
└── Deployment/nginx-deployment
    └── ReplicaSet/nginx-deployment-7d6b7d4f8c
        ├── Pod/nginx-deployment-7d6b7d4f8c-abc12
        ├── Pod/nginx-deployment-7d6b7d4f8c-def34
        └── Pod/nginx-deployment-7d6b7d4f8c-ghi56
```

---

## 🔄 3. kubectx & kubens - 컨텍스트 관리

### 📦 설치 방법

```bash
# macOS
brew install kubectx

# Linux
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
```

### 🎮 사용법

```bash
# 현재 컨텍스트 확인
kubectx

# 컨텍스트 전환
kubectx my-cluster

# 이전 컨텍스트로 돌아가기
kubectx -

# 현재 네임스페이스 확인
kubens

# 네임스페이스 전환
kubens kube-system

# 이전 네임스페이스로 돌아가기
kubens -
```

---

## 📋 4. stern - 멀티 Pod 로그 스트리밍

### 📦 설치 방법

```bash
# macOS
brew install stern

# Linux
curl -LO https://github.com/stern/stern/releases/latest/download/stern_linux_amd64.tar.gz
tar -xzf stern_linux_amd64.tar.gz
sudo mv stern /usr/local/bin/
```

### 🎮 사용법

```bash
# 특정 라벨의 모든 Pod 로그
stern -l app=nginx

# 네임스페이스의 모든 Pod 로그
stern . -n kube-system

# 패턴 매칭으로 Pod 로그
stern "nginx-.*"

# 컨테이너별 색상 구분
stern -l app=nginx --color always
```

---

## 🔍 5. dive - 컨테이너 이미지 분석

### 📦 설치 방법

```bash
# macOS
brew install dive

# Linux
wget https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb
sudo apt install ./dive_0.10.0_linux_amd64.deb
```

### 🎮 사용법

```bash
# 이미지 레이어 분석
dive nginx:latest

# Kubernetes Pod의 이미지 분석
kubectl get pod nginx-pod -o jsonpath='{.spec.containers[0].image}' | xargs dive
```

---

## 💰 6. Kubecost - 비용 분석 및 최적화

### 📦 설치 방법

**Helm을 이용한 설치:**
```bash
# Helm 설치 확인
helm version

# Kubecost Helm 저장소 추가
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo update

# Kubecost 설치 (로컬 클러스터용)
helm install kubecost kubecost/cost-analyzer \
  --namespace kubecost --create-namespace \
  --set global.grafana.enabled=false \
  --set global.prometheus.enabled=true \
  --set prometheus.server.persistentVolume.enabled=false
```

**간단 설치 (개발/학습용):**
```bash
# 빠른 설치
kubectl apply -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/kubecost.yaml
```

### 🎮 사용법

```bash
# 포트 포워딩으로 접근
kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090

# 브라우저에서 접근
# http://localhost:9090
```

### 📊 주요 기능

**1. 네임스페이스별 비용 분석**
- CPU, 메모리, 스토리지 사용량
- 시간대별 비용 추이
- 리소스 효율성 점수

**2. Pod별 상세 분석**
- 개별 Pod 비용 계산
- 리소스 요청 vs 실제 사용량
- 최적화 권장사항

**3. 클러스터 전체 인사이트**
- 전체 클러스터 비용 개요
- 가장 비용이 많이 드는 워크로드
- 유휴 리소스 식별

### 🎯 교육적 활용

**시나리오 1: 리소스 낭비 찾기**
```bash
# 1. 과도한 리소스 요청 Pod 배포
kubectl run resource-waste --image=nginx \
  --requests=cpu=2,memory=4Gi \
  --limits=cpu=2,memory=4Gi

# 2. Kubecost에서 비용 확인
# http://localhost:9090 → Allocations 탭

# 3. 실제 사용량과 요청량 비교 분석
```

**시나리오 2: 네임스페이스별 비용 비교**
```bash
# 개발/스테이징/프로덕션 네임스페이스 생성
kubectl create namespace development
kubectl create namespace staging
kubectl create namespace production

# 각 네임스페이스에 다른 규모의 워크로드 배포
kubectl run dev-app --image=nginx --replicas=1 -n development
kubectl run staging-app --image=nginx --replicas=3 -n staging
kubectl run prod-app --image=nginx --replicas=5 -n production

# Kubecost에서 네임스페이스별 비용 비교
```

### 💡 로컬 환경에서의 한계와 활용

**한계점:**
- 실제 클라우드 비용 데이터 없음
- 가상의 비용 계산 (교육용)
- 네트워크 비용 등 일부 비용 미반영

**교육적 가치:**
- 리소스 사용 패턴 시각화
- 비용 최적화 개념 학습
- FinOps 기초 이해
- 실제 클라우드 환경 준비

### 🔧 설정 최적화

**로컬 클러스터용 values.yaml**
```yaml
# kubecost-values.yaml
global:
  prometheus:
    enabled: true
  grafana:
    enabled: false

prometheus:
  server:
    persistentVolume:
      enabled: false
    retention: "2d"

kubecostFrontend:
  image:
    tag: "latest"

kubecostModel:
  image:
    tag: "latest"
```

**설치 시 적용:**
```bash
helm install kubecost kubecost/cost-analyzer \
  --namespace kubecost --create-namespace \
  -f kubecost-values.yaml
```

---

## 🛠️ 통합 설치 스크립트

### install-k8s-tools.sh
```bash
#!/bin/bash

echo "🚀 Kubernetes 모니터링 도구 설치 시작..."

# OS 감지
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "📋 감지된 OS: ${MACHINE}"

# k9s 설치
echo "📦 k9s 설치 중..."
if [[ "$MACHINE" == "Mac" ]]; then
    brew install k9s
elif [[ "$MACHINE" == "Linux" ]]; then
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -sL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz | tar xz
    sudo mv k9s /usr/local/bin/
fi

# kubectx/kubens 설치
echo "📦 kubectx/kubens 설치 중..."
if [[ "$MACHINE" == "Mac" ]]; then
    brew install kubectx
elif [[ "$MACHINE" == "Linux" ]]; then
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
fi

# stern 설치
echo "📦 stern 설치 중..."
if [[ "$MACHINE" == "Mac" ]]; then
    brew install stern
elif [[ "$MACHINE" == "Linux" ]]; then
    curl -LO https://github.com/stern/stern/releases/latest/download/stern_linux_amd64.tar.gz
    tar -xzf stern_linux_amd64.tar.gz
    sudo mv stern /usr/local/bin/
    rm stern_linux_amd64.tar.gz
fi

# kubectl krew 설치
echo "📦 kubectl krew 설치 중..."
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# PATH 설정
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# kubectl tree 설치
echo "📦 kubectl tree 설치 중..."
kubectl krew install tree

# Kubecost 설치 (선택사항)
echo "📦 Kubecost 설치 중..."
if command -v helm &> /dev/null; then
    helm repo add kubecost https://kubecost.github.io/cost-analyzer/ 2>/dev/null || true
    helm repo update
    echo "✅ Kubecost Helm 저장소 추가 완료"
    echo "💡 Kubecost 설치: helm install kubecost kubecost/cost-analyzer --namespace kubecost --create-namespace"
else
    echo "⚠️  Helm이 설치되지 않음. Kubecost는 수동 설치 필요"
fi

echo "✅ 모든 도구 설치 완료!"
echo ""
echo "🎯 설치된 도구들:"
echo "  - k9s: 실시간 클러스터 대시보드"
echo "  - kubectx/kubens: 컨텍스트/네임스페이스 관리"
echo "  - stern: 멀티 Pod 로그 스트리밍"
echo "  - kubectl tree: 리소스 관계 시각화"
echo "  - kubecost: 비용 분석 및 최적화 (Helm 필요)"
echo ""
echo "🚀 사용 시작:"
echo "  k9s              # 클러스터 대시보드 실행"
echo "  kubectx          # 컨텍스트 목록 확인"
echo "  kubens           # 네임스페이스 목록 확인"
echo "  stern -l app=nginx  # nginx 앱 로그 스트리밍"
echo "  kubectl tree deployment nginx  # nginx 배포 트리 확인"
echo ""
echo "💰 Kubecost 사용 (Helm 설치 후):"
echo "  helm install kubecost kubecost/cost-analyzer --namespace kubecost --create-namespace"
echo "  kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090"
echo "  # http://localhost:9090 접속"
```

---

## 🎯 실습 가이드

### 📚 Week 3 Day 1 통합 실습

**Step 1: 도구 설치**
```bash
# 통합 설치 스크립트 실행
chmod +x install-k8s-tools.sh
./install-k8s-tools.sh
```

**Step 2: 클러스터 탐험**
```bash
# 1. k9s로 전체 클러스터 상태 확인
k9s

# 2. 리소스 관계 확인
kubectl tree namespace default

# 3. 시스템 Pod 로그 확인
stern . -n kube-system
```

**Step 3: 실시간 모니터링 + 비용 분석**
```bash
# 터미널 1: k9s 대시보드
k9s

# 터미널 2: 로그 스트리밍
stern -l app=nginx

# 터미널 3: 이벤트 모니터링
kubectl get events --watch

# 터미널 4: Kubecost 비용 분석 (선택사항)
helm install kubecost kubecost/cost-analyzer --namespace kubecost --create-namespace
kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090
# http://localhost:9090 접속
```

### 🎓 교육 활용 팁

1. **k9s 데모**: 강사가 k9s로 클러스터 전체를 보여주며 설명
2. **실시간 디버깅**: 의도적으로 오류를 만들고 k9s로 문제 해결 과정 시연
3. **로그 분석**: stern으로 여러 Pod의 로그를 동시에 보며 패턴 분석
4. **리소스 관계**: kubectl tree로 Kubernetes 오브젝트 간 관계 시각화
5. **비용 인식**: Kubecost로 리소스 사용량과 비용 관계 학습
6. **FinOps 기초**: 개발자도 알아야 할 클라우드 비용 최적화 개념

---

## 🔧 문제 해결

### 자주 발생하는 문제들

**k9s 실행 안됨:**
```bash
# 권한 확인
ls -la $(which k9s)

# kubeconfig 확인
kubectl cluster-info

# 다시 설치
brew reinstall k9s  # macOS
```

**kubectl tree 플러그인 없음:**
```bash
# krew 재설치
kubectl krew install tree

# PATH 확인
echo $PATH | grep krew
```

**stern 로그 안보임:**
```bash
# Pod 존재 확인
kubectl get pods -l app=nginx

# 네임스페이스 확인
stern -l app=nginx -n default
```

---

<div align="center">

**🎨 시각적 모니터링** • **🔍 실시간 디버깅** • **📊 클러스터 인사이트**

*터미널에서 Kubernetes를 마스터하는 필수 도구들*

</div>
