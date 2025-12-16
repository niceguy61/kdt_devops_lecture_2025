# EKS 관리 도구 및 유틸리티

## 🎯 목적
EKS 클러스터를 효율적으로 관리하고 모니터링하기 위한 필수 도구들을 소개합니다.

---

## 🛠️ 필수 CLI 도구

### 1. kubectl 플러그인 관리자 (Krew)
```bash
# Krew 설치
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# PATH 추가
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
```

### 2. 유용한 kubectl 플러그인들
```bash
# 필수 플러그인 설치
kubectl krew install ctx          # 컨텍스트 전환
kubectl krew install ns           # 네임스페이스 전환
kubectl krew install tree         # 리소스 트리 보기
kubectl krew install get-all      # 모든 리소스 조회
kubectl krew install whoami       # 현재 사용자 확인
kubectl krew install resource-capacity  # 리소스 용량 확인
kubectl krew install outdated     # 오래된 이미지 확인
kubectl krew install stern        # 멀티 Pod 로그 보기

# 사용 예시
kubectl ctx                       # 컨텍스트 목록
kubectl ctx my-cluster           # 컨텍스트 전환
kubectl ns production            # 네임스페이스 전환
kubectl tree deployment my-app   # Deployment 트리 보기
```

### 3. k9s - Kubernetes CLI 대시보드
```bash
# k9s 설치
curl -sS https://webinstall.dev/k9s | bash

# 또는 직접 다운로드
wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/

# k9s 실행
k9s

# 주요 단축키
# :pods        - Pod 보기
# :svc         - Service 보기
# :deploy      - Deployment 보기
# :logs        - 로그 보기
# :describe    - 리소스 상세 정보
# :edit        - 리소스 편집
# :shell       - Pod 쉘 접근
```

### 4. kubectx & kubens
```bash
# kubectx/kubens 설치 (컨텍스트/네임스페이스 빠른 전환)
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# 사용법
kubectx                          # 컨텍스트 목록
kubectx my-cluster              # 컨텍스트 전환
kubectx -                       # 이전 컨텍스트로 전환

kubens                          # 네임스페이스 목록
kubens production               # 네임스페이스 전환
kubens -                        # 이전 네임스페이스로 전환
```

---

## 📊 모니터링 및 관측성 도구

### 1. Metrics Server 설치
```bash
# Metrics Server 설치 (CPU/Memory 메트릭용)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 설치 확인
kubectl get deployment metrics-server -n kube-system

# 사용법
kubectl top nodes               # 노드 리소스 사용량
kubectl top pods               # Pod 리소스 사용량
kubectl top pods --sort-by=cpu # CPU 사용량 순 정렬
```

### 2. Prometheus & Grafana (간단 설치)
```bash
# Helm으로 Prometheus 스택 설치
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# kube-prometheus-stack 설치 (Prometheus + Grafana + AlertManager)
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin123

# 설치 확인
kubectl get pods -n monitoring

# Grafana 접근
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
# 브라우저: http://localhost:3000 (admin/admin123)

# Prometheus 접근
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
# 브라우저: http://localhost:9090
```

### 3. 로그 수집 (Fluent Bit)
```bash
# Fluent Bit 설치 (로그 수집용)
helm repo add fluent https://fluent.github.io/helm-charts
helm install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --create-namespace

# 로그 확인
kubectl logs -n logging -l app.kubernetes.io/name=fluent-bit
```

---

## 🔧 개발 및 디버깅 도구

### 1. kubectl 별칭 및 함수
```bash
# ~/.bashrc에 추가할 유용한 별칭들
cat >> ~/.bashrc << 'EOF'
# kubectl 별칭
alias k=kubectl
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'
alias kdd='kubectl describe deploy'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias klog='kubectl logs'
alias kexec='kubectl exec -it'

# 유용한 함수들
kshell() {
    kubectl exec -it $1 -- /bin/bash 2>/dev/null || kubectl exec -it $1 -- /bin/sh
}

kwatch() {
    watch -n 2 "kubectl get $1"
}

klogs() {
    kubectl logs -f deployment/$1
}

# 네임스페이스 관련
alias kgns='kubectl get namespaces'
alias kcn='kubectl config set-context --current --namespace'

# 컨텍스트 관련
alias kcc='kubectl config current-context'
alias kgc='kubectl config get-contexts'
EOF

source ~/.bashrc
```

### 2. 디버깅용 Pod 템플릿
```bash
# 디버깅용 Pod 생성 함수
debug_pod() {
    kubectl run debug-pod-$(date +%s) \
        --image=nicolaka/netshoot \
        --rm -it --restart=Never \
        -- /bin/bash
}

# 네트워크 디버깅용 Pod
network_debug() {
    kubectl run network-debug \
        --image=nicolaka/netshoot \
        --rm -it --restart=Never \
        -- /bin/bash
}

# 간단한 테스트 Pod
test_pod() {
    kubectl run test-pod \
        --image=busybox \
        --rm -it --restart=Never \
        -- /bin/sh
}
```

### 3. 리소스 모니터링 스크립트
```bash
# 클러스터 상태 모니터링 스크립트
cat > cluster-status.sh << 'EOF'
#!/bin/bash

echo "🔍 EKS 클러스터 상태 확인"
echo "=========================="

echo "📊 노드 상태:"
kubectl get nodes -o wide

echo -e "\n📊 네임스페이스별 Pod 수:"
kubectl get pods --all-namespaces | awk '{print $1}' | sort | uniq -c | sort -nr

echo -e "\n📊 리소스 사용량 (Top 5):"
if kubectl top nodes >/dev/null 2>&1; then
    echo "노드 CPU 사용량:"
    kubectl top nodes --sort-by=cpu | head -6
    echo -e "\n노드 메모리 사용량:"
    kubectl top nodes --sort-by=memory | head -6
    echo -e "\nPod CPU 사용량 (Top 5):"
    kubectl top pods --all-namespaces --sort-by=cpu | head -6
    echo -e "\nPod 메모리 사용량 (Top 5):"
    kubectl top pods --all-namespaces --sort-by=memory | head -6
else
    echo "Metrics Server가 설치되지 않았습니다"
fi

echo -e "\n🚨 문제가 있는 Pod:"
kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded

echo -e "\n📈 최근 이벤트:"
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -10
EOF

chmod +x cluster-status.sh
```

---

## 🎛️ 고급 관리 도구

### 1. Lens - Kubernetes IDE
```bash
# Lens 설치 (GUI 도구)
# https://k8slens.dev/ 에서 다운로드

# 주요 기능:
# - 클러스터 시각화
# - 리소스 관리
# - 로그 및 메트릭 통합 보기
# - 터미널 통합
```

### 2. Octant - 웹 기반 대시보드
```bash
# Octant 설치
wget https://github.com/vmware-tanzu/octant/releases/latest/download/octant_0.25.1_Linux-64bit.tar.gz
tar -xzf octant_0.25.1_Linux-64bit.tar.gz
sudo mv octant_0.25.1_Linux-64bit/octant /usr/local/bin/

# Octant 실행
octant --disable-open-browser
# 브라우저: http://localhost:7777
```

### 3. Popeye - 클러스터 스캐너
```bash
# Popeye 설치 (클러스터 문제 스캔)
wget https://github.com/derailed/popeye/releases/latest/download/popeye_Linux_x86_64.tar.gz
tar -xzf popeye_Linux_x86_64.tar.gz
sudo mv popeye /usr/local/bin/

# 클러스터 스캔
popeye

# 특정 네임스페이스 스캔
popeye -n production

# 리포트 저장
popeye -o html > cluster-report.html
```

---

## 🔐 보안 및 정책 도구

### 1. Falco - 런타임 보안
```bash
# Falco 설치 (보안 모니터링)
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm install falco falcosecurity/falco \
  --namespace falco-system \
  --create-namespace

# Falco 로그 확인
kubectl logs -n falco-system -l app.kubernetes.io/name=falco
```

### 2. OPA Gatekeeper - 정책 엔진
```bash
# Gatekeeper 설치
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml

# 설치 확인
kubectl get pods -n gatekeeper-system
```

---

## 📱 모바일 앱

### 1. Kubernetes 모바일 앱들
- **Cabin**: iOS/Android Kubernetes 관리 앱
- **Kubenav**: 크로스 플랫폼 Kubernetes 네비게이터
- **Kubernetes Dashboard**: 웹 기반 (모바일 친화적)

---

## 🚀 자동화 스크립트

### 1. 도구 일괄 설치 스크립트
```bash
# tools-installer.sh
cat > install-k8s-tools.sh << 'EOF'
#!/bin/bash

echo "🛠️ Kubernetes 관리 도구 설치 시작..."

# Krew 설치
echo "📦 Krew 설치 중..."
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

# kubectl 플러그인 설치
echo "🔌 kubectl 플러그인 설치 중..."
kubectl krew install ctx ns tree get-all whoami resource-capacity stern

# k9s 설치
echo "📊 k9s 설치 중..."
curl -sS https://webinstall.dev/k9s | bash

# kubectx/kubens 설치
echo "🔄 kubectx/kubens 설치 중..."
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx 2>/dev/null || true
sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens

# Popeye 설치
echo "🔍 Popeye 설치 중..."
wget -q https://github.com/derailed/popeye/releases/latest/download/popeye_Linux_x86_64.tar.gz
tar -xzf popeye_Linux_x86_64.tar.gz
sudo mv popeye /usr/local/bin/
rm popeye_Linux_x86_64.tar.gz

echo "✅ 모든 도구 설치 완료!"
echo "사용법:"
echo "  k9s              # Kubernetes 대시보드"
echo "  kubectx          # 컨텍스트 전환"
echo "  kubens           # 네임스페이스 전환"
echo "  popeye           # 클러스터 스캔"
echo "  kubectl tree     # 리소스 트리 보기"
EOF

chmod +x install-k8s-tools.sh
```

### 2. 모니터링 스택 설치 스크립트
```bash
# monitoring-stack.sh
cat > install-monitoring.sh << 'EOF'
#!/bin/bash

echo "📊 모니터링 스택 설치 시작..."

# Helm 저장소 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

# Metrics Server 설치
echo "📈 Metrics Server 설치 중..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Prometheus + Grafana 설치
echo "📊 Prometheus + Grafana 설치 중..."
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.retention=7d

# Fluent Bit 설치
echo "📝 Fluent Bit 설치 중..."
helm install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --create-namespace

echo "✅ 모니터링 스택 설치 완료!"
echo "접근 방법:"
echo "  Grafana: kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80"
echo "  Prometheus: kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090"
EOF

chmod +x install-monitoring.sh
```

이 도구들을 Day 1에 소개하면 챌린저들이 EKS 클러스터를 훨씬 효율적으로 관리할 수 있을 것입니다!
