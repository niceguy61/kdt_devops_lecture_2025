#!/bin/bash

# Lab 1: 환경 정리

echo "=== Lab 1 환경 정리 시작 ==="
echo ""

# HTTPRoute 삭제
echo "1. HTTPRoute 삭제 중..."
kubectl delete httproute user-route product-route order-route 2>/dev/null || true
echo "   ✅ HTTPRoute 삭제 완료"

# Gateway 삭제
echo ""
echo "2. Gateway 삭제 중..."
kubectl delete gateway api-gateway 2>/dev/null || true
echo "   ✅ Gateway 삭제 완료"

# 서비스 삭제
echo ""
echo "3. 서비스 삭제 중..."
kubectl delete deployment,service user-service product-service order-service 2>/dev/null || true
echo "   ✅ 서비스 삭제 완료"

# Istio 삭제 (선택사항)
echo ""
read -p "Istio를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd istio-1.20.0 2>/dev/null || true
    istioctl uninstall --purge -y
    kubectl delete namespace istio-system
    echo "   ✅ Istio 삭제 완료"
else
    echo "   ℹ️  Istio 유지"
fi

# Gateway API CRDs 삭제 (선택사항)
echo ""
read -p "Gateway API CRDs를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.0.0" | kubectl delete -f - 2>/dev/null || true
    echo "   ✅ Gateway API CRDs 삭제 완료"
else
    echo "   ℹ️  Gateway API CRDs 유지"
fi

# Namespace label 제거
echo ""
echo "4. Namespace label 제거 중..."
kubectl label namespace default istio-injection- 2>/dev/null || true
echo "   ✅ Namespace label 제거 완료"

# Port-forward 종료
echo ""
echo "5. Port-forward 프로세스 종료 중..."
pkill -f "kubectl port-forward" 2>/dev/null || true
echo "   ✅ Port-forward 종료 완료"

echo ""
echo "=== Lab 1 환경 정리 완료 ==="
