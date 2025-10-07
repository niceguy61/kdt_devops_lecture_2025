#!/bin/bash

# Week 4 Day 1 Hands-on 1: 전체 환경 정리
# 사용법: ./cleanup-all.sh

echo "=== Week 4 Day 1 Hands-on 1: 환경 정리 시작 ==="
echo ""

# 사용자 확인
read -p "모든 고급 패턴 리소스를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "정리 작업을 취소했습니다."
    exit 0
fi

echo "1/5 Istio Service Mesh 정리 중..."
if command -v istioctl > /dev/null 2>&1; then
    istioctl uninstall --purge -y 2>/dev/null || echo "Istio가 설치되지 않았거나 이미 제거됨"
    kubectl delete namespace istio-system --ignore-not-found=true
    echo "✅ Istio 정리 완료"
else
    echo "✅ Istio CLI 없음, 건너뜀"
fi

echo ""
echo "2/5 고급 패턴 네임스페이스 정리 중..."
kubectl delete namespace advanced-patterns --ignore-not-found=true
kubectl delete namespace service-mesh --ignore-not-found=true
echo "✅ 고급 패턴 네임스페이스 정리 완료"

echo ""
echo "3/5 마이크로서비스 네임스페이스 내 고급 서비스 정리 중..."
kubectl delete deployment,service,configmap -n ecommerce-microservices \
  -l pattern=saga,cqrs,eventsourcing --ignore-not-found=true
echo "✅ 고급 서비스 정리 완료"

echo ""
echo "4/5 Istio 리소스 정리 중..."
kubectl delete gateway,virtualservice,destinationrule --all-namespaces \
  --ignore-not-found=true 2>/dev/null || echo "Istio 리소스 없음"
echo "✅ Istio 리소스 정리 완료"

echo ""
echo "5/5 임시 파일 정리 중..."
rm -rf manifests/ 2>/dev/null || true
rm -f /tmp/istio-* 2>/dev/null || true
echo "✅ 임시 파일 정리 완료"

echo ""
echo "=== 환경 정리 완료 ==="
echo ""
echo "🧹 정리된 리소스:"
echo "- Istio Service Mesh"
echo "- advanced-patterns 네임스페이스"
echo "- service-mesh 네임스페이스"
echo "- 고급 패턴 서비스들"
echo "- Istio 네트워킹 리소스"
echo ""
echo "💡 참고사항:"
echo "- 기본 Lab 1 환경은 유지됩니다"
echo "- ecommerce-microservices 네임스페이스는 보존됩니다"
echo "- 기본 서비스들(user-service 등)은 그대로 유지됩니다"
echo ""
echo "🎉 Week 4 Day 1 Hands-on 1 정리가 완료되었습니다!"
