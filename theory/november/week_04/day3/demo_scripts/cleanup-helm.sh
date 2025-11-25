#!/bin/bash

# November Week 4 Day 3: Helm Demo 정리 스크립트
# 설명: Demo에서 생성한 모든 리소스 삭제
# 사용법: ./cleanup-helm.sh

set -e

echo "=== November Week 4 Day 3: Helm Demo 정리 시작 ==="
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

# 함수: 성공 출력
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 확인 메시지
print_warning "다음 리소스가 삭제됩니다:"
echo "- Helm Release: myapp (production namespace)"
echo "- Helm Release: prometheus (monitoring namespace)"
echo "- Namespace: production"
echo "- Namespace: monitoring"
echo "- 모든 PVC 및 데이터"
echo ""
read -p "정말 삭제하시겠습니까? (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "정리 작업이 취소되었습니다."
    exit 0
fi

# 1. 애플리케이션 삭제
print_step "1/5 애플리케이션 삭제"
if helm list -n production | grep -q myapp; then
    helm uninstall myapp -n production
    print_success "myapp 삭제 완료"
else
    print_warning "myapp이 설치되어 있지 않습니다."
fi

# 2. Prometheus Stack 삭제
print_step "2/5 Prometheus Stack 삭제"
if helm list -n monitoring | grep -q prometheus; then
    helm uninstall prometheus -n monitoring
    print_success "Prometheus Stack 삭제 완료"
else
    print_warning "Prometheus Stack이 설치되어 있지 않습니다."
fi

# 3. PVC 삭제 대기
print_step "3/5 리소스 정리 대기 (30초)"
sleep 30

# 4. Namespace 삭제
print_step "4/5 Namespace 삭제"

if kubectl get namespace production &> /dev/null; then
    kubectl delete namespace production --timeout=60s
    print_success "production namespace 삭제 완료"
else
    print_warning "production namespace가 존재하지 않습니다."
fi

if kubectl get namespace monitoring &> /dev/null; then
    kubectl delete namespace monitoring --timeout=60s
    print_success "monitoring namespace 삭제 완료"
else
    print_warning "monitoring namespace가 존재하지 않습니다."
fi

# 5. 포트 포워딩 종료
print_step "5/5 포트 포워딩 종료"
pkill -f "port-forward" 2>/dev/null || true
print_success "포트 포워딩 종료 완료"

# 6. 남은 PVC 확인
print_step "남은 PVC 확인"
REMAINING_PVC=$(kubectl get pvc --all-namespaces 2>/dev/null | grep -E "production|monitoring" || true)

if [ -n "$REMAINING_PVC" ]; then
    print_warning "다음 PVC가 남아있습니다:"
    echo "$REMAINING_PVC"
    echo ""
    read -p "수동으로 삭제하시겠습니까? (yes/no): " -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        kubectl get pvc --all-namespaces | grep -E "production|monitoring" | awk '{print $1, $2}' | while read ns pvc; do
            kubectl delete pvc $pvc -n $ns --force --grace-period=0
        done
        print_success "PVC 삭제 완료"
    fi
else
    print_success "남은 PVC가 없습니다."
fi

# 7. 작업 디렉토리 정리
print_step "작업 디렉토리 정리"
DEMO_DIR=~/helm-demo
if [ -d "$DEMO_DIR" ]; then
    read -p "작업 디렉토리($DEMO_DIR)를 삭제하시겠습니까? (yes/no): " -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        rm -rf $DEMO_DIR
        print_success "작업 디렉토리 삭제 완료"
    else
        print_warning "작업 디렉토리는 유지됩니다: $DEMO_DIR"
    fi
fi

# 완료
echo ""
print_success "모든 정리 작업이 완료되었습니다!"
echo ""
echo "=== November Week 4 Day 3: Helm Demo 정리 완료 ==="
