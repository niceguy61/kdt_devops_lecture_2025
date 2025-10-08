#!/bin/bash

# Week 4 Day 2 Hands-on 1: 환경 정리
# 고급 기능 리소스 제거

echo "=== Istio 고급 트래픽 관리 실습 환경 정리 시작 ==="
echo ""

# VirtualService 삭제
echo "1. VirtualService 삭제 중..."
kubectl delete virtualservice user-service product-service 2>/dev/null || true
echo "   ✅ VirtualService 삭제 완료"

# DestinationRule 삭제
echo ""
echo "2. DestinationRule 삭제 중..."
kubectl delete destinationrule user-service product-service 2>/dev/null || true
echo "   ✅ DestinationRule 삭제 완료"

# v2 Deployment 삭제
echo ""
echo "3. v2 Deployment 삭제 중..."
kubectl delete deployment user-service-v2 product-service-v2 2>/dev/null || true
echo "   ✅ v2 Deployment 삭제 완료"

# Security 정책 삭제
echo ""
echo "4. Security 정책 삭제 중..."
kubectl delete peerauthentication default 2>/dev/null || true
kubectl delete authorizationpolicy user-service-policy 2>/dev/null || true
echo "   ✅ Security 정책 삭제 완료"

# Kiali 삭제 (선택사항)
echo ""
read -p "Kiali를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml 2>/dev/null || true
    echo "   ✅ Kiali 삭제 완료"
else
    echo "   ℹ️  Kiali 유지"
fi

# Kiali 프로세스 종료
echo ""
echo "5. Kiali 프로세스 종료 중..."
pkill -f "istioctl dashboard kiali" 2>/dev/null || true
echo "   ✅ Kiali 프로세스 종료 완료"

# 트래픽 생성 프로세스 종료
echo ""
echo "6. 트래픽 생성 프로세스 종료 중..."
pkill -f "curl.*api.example.com" 2>/dev/null || true
echo "   ✅ 트래픽 생성 프로세스 종료 완료"

echo ""
echo "=== 환경 정리 완료 ==="
echo ""
echo "💡 Lab 1 리소스는 유지됩니다"
echo "   전체 정리를 원하면 Lab 1의 cleanup을 실행하세요"
