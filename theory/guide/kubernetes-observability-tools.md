# Kubernetes Dashboard 및 Observability 도구 설치 가이드

<div align="center">

**📊 Dashboard** • **🔍 Monitoring** • **📈 Observability**

*Kubernetes 클러스터 모니터링 및 관리 도구 설치 가이드*

</div>

---

## 📋 목차

1. [Kubernetes Dashboard](#1-kubernetes-dashboard)
2. [Prometheus + Grafana](#2-prometheus--grafana)
3. [Metrics Server](#3-metrics-server)
4. [Lens (Desktop App)](#4-lens-desktop-app)

---

## 1. Kubernetes Dashboard

### 📊 개요
Kubernetes 공식 웹 UI로 클러스터 리소스를 시각적으로 관리할 수 있습니다.

### 🚀 설치 방법

#### Step 1: Dashboard 설치
```bash
# Kubernetes Dashboard 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# 설치 확인
kubectl get pods -n kubernetes-dashboard
```

#### Step 2: Admin 사용자 생성
```bash
# ServiceAccount 및 ClusterRoleBinding 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

#### Step 3: NodePort로 외부 노출 (Kind 클러스터용)
```bash
# Dashboard를 NodePort 30081로 변경
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard \
  -p '{"spec":{"type":"NodePort","ports":[{"port":443,"nodePort":30081,"protocol":"TCP","targetPort":8443}]}}'

# 서비스 확인
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard
```

#### Step 4: 접근 토큰 생성
```bash
# 토큰 생성 (1시간 유효)
kubectl create token admin-user -n kubernetes-dashboard

# 토큰 복사 (로그인 시 사용)
```

### 🌐 접근 방법

**브라우저 접속**:
```
https://localhost:30081
```

**로그인**:
1. 브라우저에서 보안 경고 발생 → "고급" → "계속 진행"
2. "Token" 선택
3. 위에서 생성한 토큰 붙여넣기
4. "Sign in" 클릭

### 💡 유용한 기능
- **Workloads**: Pod, Deployment, StatefulSet 등 확인
- **Services**: Service, Ingress 관리
- **Config**: ConfigMap, Secret 관리
- **Storage**: PV, PVC 확인
- **Logs**: Pod 로그 실시간 확인
- **Shell**: Pod 내부 터미널 접속

---

## 2. Prometheus + Grafana

### 📊 개요
Prometheus는 메트릭 수집 및 저장, Grafana는 시각화를 담당하는 모니터링 스택입니다.

### 🚀 설치 방법 (Helm 사용)

#### Step 1: Helm 설치 (없는 경우)
```bash
# Helm 설치 확인
helm version

# 없으면 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

#### Step 2: Prometheus Stack 설치
```bash
# Helm Repository 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Namespace 생성
kubectl create namespace monitoring

# Prometheus + Grafana 설치
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=30090 \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30091 \
  --set alertmanager.service.type=NodePort \
  --set alertmanager.service.nodePort=30092
```

#### Step 3: 설치 확인
```bash
# Pod 상태 확인
kubectl get pods -n monitoring

# Service 확인
kubectl get svc -n monitoring
```

### 🌐 접근 방법

**Prometheus**:
```
http://localhost:30090
```

**Grafana**:
```
http://localhost:30091
```
- **Username**: `admin`
- **Password**: `prom-operator` (기본값)

**Grafana 비밀번호 확인**:
```bash
kubectl get secret -n monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

### 📊 Grafana 대시보드 추천
- **Kubernetes Cluster Monitoring**: ID `7249`
- **Node Exporter Full**: ID `1860`
- **Kubernetes Pod Monitoring**: ID `6417`

**대시보드 Import 방법**:
1. Grafana 접속
2. 좌측 메뉴 "+" → "Import"
3. Dashboard ID 입력 (예: 7249)
4. "Load" → "Import"

---

## 3. Metrics Server

### 📊 개요
Kubernetes 클러스터의 리소스 사용량(CPU, Memory)을 수집하는 경량 모니터링 도구입니다.

### 🚀 설치 방법

```bash
# Metrics Server 설치
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Kind 클러스터용 패치 (TLS 검증 비활성화)
kubectl patch deployment metrics-server -n kube-system \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# 설치 확인
kubectl get pods -n kube-system | grep metrics-server
```

### 📊 사용 방법

```bash
# 노드 리소스 사용량 확인
kubectl top nodes

# Pod 리소스 사용량 확인
kubectl top pods -A

# 특정 네임스페이스의 Pod 확인
kubectl top pods -n ecommerce-advanced
```

---

## 4. Lens (Desktop App)

### 📊 개요
Kubernetes IDE로 불리는 강력한 데스크톱 애플리케이션입니다.

### 🚀 설치 방법

#### Windows
```powershell
# Chocolatey 사용
choco install lens

# 또는 공식 사이트에서 다운로드
# https://k8slens.dev/
```

#### macOS
```bash
# Homebrew 사용
brew install --cask lens
```

#### Linux
```bash
# Snap 사용
sudo snap install kontena-lens --classic

# 또는 AppImage 다운로드
# https://k8slens.dev/
```

### 🌐 사용 방법

1. **Lens 실행**
2. **Catalog** → **Clusters** → **Add Cluster**
3. **kubeconfig 파일 선택** 또는 **자동 감지**
4. 클러스터 연결 완료

### 💡 주요 기능
- **실시간 모니터링**: CPU, Memory, Network 사용량
- **로그 스트리밍**: 실시간 Pod 로그 확인
- **터미널**: Pod 내부 Shell 접속
- **Helm 관리**: Helm Chart 설치 및 관리
- **리소스 편집**: YAML 직접 편집
- **멀티 클러스터**: 여러 클러스터 동시 관리

---

## 📊 도구 비교

| 도구 | 용도 | 장점 | 단점 |
|------|------|------|------|
| **Dashboard** | 웹 UI 관리 | 공식 도구, 가볍고 간단 | 기능 제한적 |
| **Prometheus + Grafana** | 모니터링 | 강력한 메트릭 수집 및 시각화 | 설정 복잡, 리소스 많이 사용 |
| **Metrics Server** | 리소스 확인 | 매우 가볍고 빠름 | 기본 메트릭만 제공 |
| **Lens** | 데스크톱 IDE | 직관적 UI, 강력한 기능 | 데스크톱 앱 설치 필요 |

---

## 🎯 추천 조합

### 개발 환경
```
Lens (데스크톱) + Metrics Server
```
- 빠르고 직관적인 개발 경험
- 리소스 사용량 최소화

### 학습 환경
```
Dashboard + Metrics Server
```
- 웹 브라우저만으로 모든 작업 가능
- Kubernetes 기본 개념 학습에 적합

### 프로덕션 환경
```
Prometheus + Grafana + Metrics Server
```
- 완전한 모니터링 및 알림 시스템
- 장기 메트릭 저장 및 분석

---

## 🧹 정리 방법

### Dashboard 삭제
```bash
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl delete clusterrolebinding admin-user
kubectl delete serviceaccount admin-user -n kubernetes-dashboard
```

### Prometheus + Grafana 삭제
```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```

### Metrics Server 삭제
```bash
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

## 💡 문제 해결

### Dashboard 접속 안 됨
```bash
# Pod 상태 확인
kubectl get pods -n kubernetes-dashboard

# 로그 확인
kubectl logs -n kubernetes-dashboard deployment/kubernetes-dashboard

# Service 확인
kubectl get svc -n kubernetes-dashboard
```

### Metrics Server 동작 안 함
```bash
# Pod 로그 확인
kubectl logs -n kube-system deployment/metrics-server

# TLS 검증 비활성화 확인
kubectl get deployment metrics-server -n kube-system -o yaml | grep kubelet-insecure-tls
```

### Grafana 비밀번호 분실
```bash
# 비밀번호 재설정
kubectl get secret -n monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

---

<div align="center">

**📊 시각화** • **🔍 모니터링** • **📈 분석**

*Kubernetes 클러스터를 효과적으로 관리하고 모니터링하세요*

</div>
