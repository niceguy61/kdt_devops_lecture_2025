#!/bin/bash

# Lab 1: Kong API Gateway - 환경 정리

echo "=== Kong API Gateway Lab 환경 정리 시작 ==="
echo ""

# 1. Kong 네임스페이스 삭제
echo "1. Kong 네임스페이스 삭제 중..."
kubectl delete namespace kong
echo "   ✅ Kong 네임스페이스 삭제 완료"

# 2. 백엔드 서비스 삭제
echo "2. 백엔드 서비스 삭제 중..."
kubectl delete deployment user-service product-service order-service 2>/dev/null
kubectl delete service user-service product-service order-service 2>/dev/null
echo "   ✅ 백엔드 서비스 삭제 완료"

echo ""
echo "=== 환경 정리 완료 ==="
echo ""
echo "💡 클러스터는 유지됩니다. 다음 실습에서 재사용 가능합니다."
echo "   클러스터 삭제가 필요한 경우: kind delete cluster --name lab-cluster"
