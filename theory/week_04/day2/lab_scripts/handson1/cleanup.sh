#!/bin/bash

# Hands-on 1: Istio Service Mesh - 환경 정리

echo "=== Istio 환경 정리 시작 ==="
echo ""

# 1. Istio 리소스 삭제
echo "1. Istio 리소스 삭제 중..."
kubectl delete gateway app-gateway 2>/dev/null
kubectl delete virtualservice --all 2>/dev/null
kubectl delete destinationrule --all 2>/dev/null
echo "   ✅ Istio 리소스 삭제 완료"

# 2. 애플리케이션 삭제
echo ""
echo "2. 애플리케이션 삭제 중..."
kubectl delete deployment user-service-v1 user-service-v2 product-service order-service 2>/dev/null
kubectl delete service user-service product-service order-service 2>/dev/null
echo "   ✅ 애플리케이션 삭제 완료"

# 3. Istio 언인스톨
echo ""
echo "3. Istio 언인스톨 중..."
cd /tmp/istio-1.20.0
export PATH=$PWD/bin:$PATH
istioctl uninstall --purge -y
echo "   ✅ Istio 언인스톨 완료"

# 4. Istio 네임스페이스 삭제
echo ""
echo "4. Istio 네임스페이스 삭제 중..."
kubectl delete namespace istio-system
echo "   ✅ Istio 네임스페이스 삭제 완료"

# 5. Sidecar 주입 비활성화
echo ""
echo "5. Sidecar 주입 비활성화 중..."
kubectl label namespace default istio-injection-
echo "   ✅ Sidecar 주입 비활성화 완료"

echo ""
echo "=== Istio 환경 정리 완료 ==="
echo ""
echo "💡 클러스터는 유지됩니다."
echo "   클러스터 삭제가 필요한 경우: kind delete cluster --name lab-cluster"
