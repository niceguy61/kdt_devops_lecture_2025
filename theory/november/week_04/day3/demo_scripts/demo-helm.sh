#!/bin/bash

# November Week 4 Day 3: Helm Demo Script
# 설명: Helm Chart 작성부터 배포까지 전체 과정 시연
# 사용법: ./demo-helm.sh

set -e

echo "=== November Week 4 Day 3: Helm Demo 시작 ==="
echo ""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 함수: 단계 출력
print_step() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

# 함수: 경고 출력
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 함수: 에러 출력
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 함수: 성공 출력
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 함수: 사용자 입력 대기
wait_for_user() {
    echo ""
    read -p "계속하려면 Enter를 누르세요..." -r
    echo ""
}

# 1. 환경 확인
print_step "1/4 환경 확인"

# kubectl 확인
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl이 설치되어 있지 않습니다."
    exit 1
fi

# Helm 확인
if ! command -v helm &> /dev/null; then
    print_error "Helm이 설치되어 있지 않습니다."
    exit 1
fi

# 클러스터 연결 확인
if ! kubectl cluster-info &> /dev/null; then
    print_error "Kubernetes 클러스터에 연결할 수 없습니다."
    exit 1
fi

print_success "환경 확인 완료"
echo "Helm 버전: $(helm version --short)"
echo "Kubernetes 버전: $(kubectl version --short 2>/dev/null | grep Server)"
wait_for_user

# 2. Demo 1: Chart 작성
print_step "2/4 Demo 1: Chart 작성 (15분)"

# 작업 디렉토리 생성
DEMO_DIR=~/helm-demo
mkdir -p $DEMO_DIR
cd $DEMO_DIR

# 기존 Chart 삭제
if [ -d "myapp" ]; then
    print_warning "기존 myapp Chart 삭제 중..."
    rm -rf myapp
fi

# Chart 생성
print_step "Chart 생성"
helm create myapp
print_success "Chart 생성 완료"

# Chart 구조 확인
print_step "Chart 구조"
tree myapp/ || ls -R myapp/
wait_for_user

# Chart.yaml 확인
print_step "Chart 메타데이터"
cat myapp/Chart.yaml
wait_for_user

# Values 파일 커스터마이징
print_step "Values 파일 커스터마이징"
cat > myapp/values.yaml <<'EOF'
replicaCount: 2

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
EOF

print_success "Values 파일 커스터마이징 완료"
cat myapp/values.yaml
wait_for_user

# 템플릿 렌더링 테스트
print_step "템플릿 렌더링 테스트"
helm template myapp ./myapp | head -50
wait_for_user

# Chart 검증
print_step "Chart 검증"
helm lint ./myapp
print_success "Chart 검증 완료"
wait_for_user

# 3. Demo 2: Prometheus Stack 설치
print_step "3/4 Demo 2: Prometheus Stack 설치 (15분)"

# Repository 추가
print_step "Helm Repository 추가"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo add stable https://charts.helm.sh/stable 2>/dev/null || true
helm repo update
print_success "Repository 추가 완료"

# Repository 목록
print_step "Repository 목록"
helm repo list
wait_for_user

# Chart 검색
print_step "Prometheus Chart 검색"
helm search repo prometheus | head -10
wait_for_user

# Values 파일 준비
print_step "Prometheus Values 파일 작성"
cat > values-prometheus.yaml <<'EOF'
# Prometheus 설정
prometheus:
  prometheusSpec:
    retention: 30d
    resources:
      requests:
        cpu: 200m
        memory: 512Mi
      limits:
        cpu: 500m
        memory: 1Gi
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi

# Grafana 설정
grafana:
  enabled: true
  adminPassword: "demo-password"
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 200m
      memory: 512Mi
  persistence:
    enabled: true
    size: 10Gi

# Alertmanager 설정
alertmanager:
  enabled: true
  alertmanagerSpec:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
EOF

print_success "Values 파일 작성 완료"
cat values-prometheus.yaml
wait_for_user

# Namespace 생성
print_step "Namespace 생성"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
print_success "Namespace 생성 완료"
wait_for_user

# Prometheus Stack 설치
print_step "Prometheus Stack 설치 (5-10분 소요)"
print_warning "이 작업은 시간이 걸립니다. 잠시만 기다려주세요..."

helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f values-prometheus.yaml \
  --wait \
  --timeout 10m

print_success "Prometheus Stack 설치 완료"
wait_for_user

# 설치 확인
print_step "설치 상태 확인"
helm list -n monitoring
echo ""
kubectl get pods -n monitoring
echo ""
kubectl get svc -n monitoring
wait_for_user

# Grafana 접속 정보
print_step "Grafana 접속 정보"
echo "Username: admin"
echo "Password: demo-password"
echo ""
print_warning "포트 포워딩을 시작합니다..."
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 > /dev/null 2>&1 &
GRAFANA_PID=$!
sleep 3
echo "Grafana URL: http://localhost:3000"
echo ""
print_warning "브라우저에서 Grafana에 접속해보세요."
wait_for_user

# 포트 포워딩 종료
kill $GRAFANA_PID 2>/dev/null || true

# 4. Demo 3: 애플리케이션 배포
print_step "4/4 Demo 3: 애플리케이션 배포 (15분)"

# Chart 의존성 추가
print_step "Chart 의존성 추가"
cat >> myapp/Chart.yaml <<'EOF'

dependencies:
  - name: postgresql
    version: "12.x.x"
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
EOF

print_success "의존성 추가 완료"
cat myapp/Chart.yaml
wait_for_user

# Repository 추가
print_step "Bitnami Repository 추가"
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
helm repo update
print_success "Repository 추가 완료"
wait_for_user

# 의존성 다운로드
print_step "의존성 다운로드"
helm dependency update ./myapp
print_success "의존성 다운로드 완료"
ls -la myapp/charts/
wait_for_user

# 프로덕션 Values 파일
print_step "프로덕션 Values 파일 작성"
cat > values-prod.yaml <<'EOF'
replicaCount: 3

image:
  repository: nginx
  tag: "1.21"

service:
  type: LoadBalancer
  port: 80

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

# PostgreSQL 설정
postgresql:
  enabled: true
  auth:
    username: myapp
    password: myapp-password
    database: myapp
  primary:
    persistence:
      enabled: true
      size: 20Gi
EOF

print_success "Values 파일 작성 완료"
cat values-prod.yaml
wait_for_user

# Namespace 생성
print_step "Production Namespace 생성"
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
print_success "Namespace 생성 완료"
wait_for_user

# 애플리케이션 배포
print_step "애플리케이션 배포 (3-5분 소요)"
print_warning "PostgreSQL 초기화 시간이 필요합니다..."

helm install myapp ./myapp \
  -n production \
  -f values-prod.yaml \
  --wait \
  --timeout 5m

print_success "애플리케이션 배포 완료"
wait_for_user

# 배포 확인
print_step "배포 상태 확인"
helm list -n production
echo ""
kubectl get all -n production
echo ""
kubectl get pvc -n production
wait_for_user

# 5. Demo 4: 업그레이드 & 롤백
print_step "Demo 4: 업그레이드 & 롤백 (10분)"

# 현재 상태 확인
print_step "현재 Release 상태"
helm status myapp -n production
wait_for_user

# 이미지 업그레이드
print_step "이미지 업그레이드 (v1.21 -> v1.22)"
helm upgrade myapp ./myapp \
  -n production \
  -f values-prod.yaml \
  --set image.tag=1.22 \
  --wait

print_success "업그레이드 완료"
kubectl get pods -n production
wait_for_user

# Release 이력
print_step "Release 이력"
helm history myapp -n production
wait_for_user

# 레플리카 수 변경
print_step "레플리카 수 변경 (3 -> 5)"
helm upgrade myapp ./myapp \
  -n production \
  -f values-prod.yaml \
  --set replicaCount=5 \
  --wait

print_success "레플리카 변경 완료"
kubectl get pods -n production
wait_for_user

# 롤백
print_step "롤백 (Revision 2로)"
helm rollback myapp 2 -n production --wait
print_success "롤백 완료"

kubectl get pods -n production
echo ""
helm history myapp -n production
wait_for_user

# 6. Demo 완료
print_step "Demo 완료"
print_success "모든 Demo가 성공적으로 완료되었습니다!"
echo ""
echo "배포된 리소스:"
echo "- Prometheus Stack (monitoring namespace)"
echo "- MyApp + PostgreSQL (production namespace)"
echo ""
print_warning "리소스를 정리하려면 cleanup-helm.sh를 실행하세요."
echo ""
echo "=== November Week 4 Day 3: Helm Demo 완료 ==="
