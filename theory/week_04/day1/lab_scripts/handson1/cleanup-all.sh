#!/bin/bash

# Week 4 Day 1 Hands-on 1: 환경 정리
# 사용법: ./cleanup-all.sh

echo "=== Week 4 Day 1 Hands-on 1 환경 정리 시작 ==="

# 에러가 발생해도 계속 진행
set +e

# 진행 상황 표시 함수
show_progress() {
    echo ""
    echo "🧹 $1"
    echo "----------------------------------------"
}

# 확인 함수
confirm_cleanup() {
    echo "⚠️  다음 리소스들이 삭제됩니다:"
    echo "   - ecommerce-microservices 네임스페이스 (모든 서비스 포함)"
    echo "   - testing 네임스페이스 (Load Tester 포함)"
    echo "   - Nginx Ingress Controller (선택사항)"
    echo ""
    read -p "정말로 정리하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 정리 작업이 취소되었습니다."
        exit 1
    fi
}

# 사용자 확인
confirm_cleanup

# Hands-on 1에서 생성한 리소스들 정리
show_progress "1/5 Hands-on 1 생성 리소스 정리"

echo "🗑️  Jobs 정리 중..."
kubectl delete jobs --all -n ecommerce-microservices 2>/dev/null || true

echo "🗑️  CronJobs 정리 중..."
kubectl delete cronjobs --all -n ecommerce-microservices 2>/dev/null || true

echo "🗑️  Deployments 정리 중..."
kubectl delete deployments --all -n ecommerce-microservices 2>/dev/null || true

echo "🗑️  Services 정리 중..."
kubectl delete services --all -n ecommerce-microservices 2>/dev/null || true

echo "🗑️  ConfigMaps 정리 중..."
kubectl delete configmaps --all -n ecommerce-microservices 2>/dev/null || true

echo "🗑️  Ingress 정리 중..."
kubectl delete ingress --all -n ecommerce-microservices 2>/dev/null || true

echo "✅ Hands-on 1 리소스 정리 완료"

# 네임스페이스 정리
show_progress "2/5 네임스페이스 정리"
if kubectl get namespace ecommerce-microservices >/dev/null 2>&1; then
    echo "🗑️  ecommerce-microservices 네임스페이스 삭제 중..."
    kubectl delete namespace ecommerce-microservices
    echo "✅ ecommerce-microservices 네임스페이스 삭제 완료"
else
    echo "ℹ️  ecommerce-microservices 네임스페이스가 이미 없습니다"
fi

if kubectl get namespace testing >/dev/null 2>&1; then
    echo "🗑️  testing 네임스페이스 삭제 중..."
    kubectl delete namespace testing
    echo "✅ testing 네임스페이스 삭제 완료"
else
    echo "ℹ️  testing 네임스페이스가 이미 없습니다"
fi

# Nginx Ingress Controller 정리 (선택사항)
show_progress "3/5 Nginx Ingress Controller 정리 (선택사항)"
echo "⚠️  Nginx Ingress Controller를 삭제하면 다른 실습에 영향을 줄 수 있습니다."
read -p "Nginx Ingress Controller도 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Nginx Ingress Controller 삭제 중..."
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml 2>/dev/null || true
    echo "✅ Nginx Ingress Controller 삭제 완료"
else
    echo "ℹ️  Nginx Ingress Controller는 유지됩니다"
fi

# 임시 파일 정리
show_progress "4/5 임시 파일 정리"
if [ -d "./istio-1.27.1" ]; then
    echo "🗑️  Istio 다운로드 파일 정리 중..."
    rm -rf ./istio-1.27.1
    echo "✅ Istio 파일 정리 완료"
else
    echo "ℹ️  정리할 임시 파일이 없습니다"
fi

# 최종 확인
show_progress "5/5 정리 결과 확인"
echo "🔍 남은 리소스 확인:"
echo ""

echo "📦 ecommerce-microservices 네임스페이스:"
if kubectl get namespace ecommerce-microservices >/dev/null 2>&1; then
    kubectl get all -n ecommerce-microservices 2>/dev/null || echo "   (리소스 없음)"
else
    echo "   (네임스페이스 없음)"
fi

echo ""
echo "📦 testing 네임스페이스:"
if kubectl get namespace testing >/dev/null 2>&1; then
    kubectl get all -n testing 2>/dev/null || echo "   (리소스 없음)"
else
    echo "   (네임스페이스 없음)"
fi

echo ""
echo "📦 Ingress Controller:"
if kubectl get namespace ingress-nginx >/dev/null 2>&1; then
    echo "   ✅ 유지됨 (다른 실습에서 사용 가능)"
else
    echo "   ❌ 삭제됨"
fi

echo ""
echo "=== Week 4 Day 1 Hands-on 1 환경 정리 완료 ==="
echo ""
echo "🎯 정리된 내용:"
echo "- ✅ 모든 마이크로서비스 리소스 삭제"
echo "- ✅ Jobs, CronJobs, ConfigMaps 정리"
echo "- ✅ 네임스페이스 정리"
echo "- ✅ 임시 파일 정리"
echo ""
echo "💡 다시 실습하려면 ./setup-environment.sh를 실행하세요!"
echo ""
