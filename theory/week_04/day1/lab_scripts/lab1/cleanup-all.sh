#!/bin/bash

# Week 4 Day 1 Lab 1: 전체 환경 정리
# 사용법: ./cleanup-all.sh

echo "=== Week 4 Day 1 Lab 1: 환경 정리 시작 ==="
echo ""

# 사용자 확인
read -p "모든 실습 리소스를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "정리 작업을 취소했습니다."
    exit 0
fi

echo "1/6 테스트 네임스페이스 정리 중..."
kubectl delete namespace testing --ignore-not-found=true
echo "✅ 테스트 환경 정리 완료"

echo ""
echo "2/6 마이크로서비스 네임스페이스 정리 중..."
kubectl delete namespace ecommerce-microservices --ignore-not-found=true
echo "✅ 마이크로서비스 환경 정리 완료"

echo ""
echo "3/6 모놀리스 네임스페이스 정리 중..."
kubectl delete namespace ecommerce-monolith --ignore-not-found=true
echo "✅ 모놀리스 환경 정리 완료"

echo ""
echo "4/6 Ingress Controller 정리 중..."
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml --ignore-not-found=true
echo "✅ Ingress Controller 정리 완료"

echo ""
echo "5/6 임시 파일 정리 중..."
rm -f /tmp/monolith-results.txt
rm -f /tmp/microservice-results.txt
rm -rf manifests/ 2>/dev/null || true
echo "✅ 임시 파일 정리 완료"

echo ""
echo "6/6 정리 상태 확인 중..."
echo "남은 네임스페이스:"
kubectl get namespaces | grep -E "(ecommerce|testing|ingress-nginx)" || echo "모든 실습 네임스페이스가 정리되었습니다."

echo ""
echo "=== 환경 정리 완료 ==="
echo ""
echo "🧹 정리된 리소스:"
echo "- ecommerce-monolith 네임스페이스"
echo "- ecommerce-microservices 네임스페이스"
echo "- testing 네임스페이스"
echo "- ingress-nginx 네임스페이스"
echo "- 임시 파일들"
echo ""
echo "💡 참고사항:"
echo "- 클러스터 자체는 유지됩니다"
echo "- 다른 실습을 위해 클러스터를 계속 사용할 수 있습니다"
echo "- 완전한 정리를 원한다면 클러스터를 삭제하세요"
echo ""
echo "🎉 Week 4 Day 1 Lab 1 실습이 완료되었습니다!"
