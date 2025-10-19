#!/bin/bash

# Hands-on 1: Istio Service Mesh - Istio 설치

echo "=== Istio 설치 시작 ==="
echo ""

# 1. Istio 다운로드
echo "1. Istio 다운로드 중..."
cd /tmp
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -
cd istio-1.20.0
export PATH=$PWD/bin:$PATH
echo "   ✅ Istio 다운로드 완료"

# 2. Istio 설치 (demo 프로파일)
echo ""
echo "2. Istio 설치 중 (demo 프로파일)..."
istioctl install --set profile=demo -y
echo "   ✅ Istio 설치 완료"

# 3. Istio 컴포넌트 확인
echo ""
echo "3. Istio 컴포넌트 확인 중..."
kubectl wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=istio-ingressgateway -n istio-system --timeout=120s
echo "   ✅ 모든 Istio 컴포넌트 준비 완료"

# 4. Sidecar 자동 주입 활성화
echo ""
echo "4. Sidecar 자동 주입 활성화 중..."
kubectl label namespace default istio-injection=enabled --overwrite
echo "   ✅ default 네임스페이스 Sidecar 주입 활성화"

# 5. 설치 확인
echo ""
echo "5. 설치 상태 확인 중..."
echo ""
kubectl get pods -n istio-system
echo ""
kubectl get namespace -L istio-injection

echo ""
echo "=== Istio 설치 완료 ==="
echo ""
echo "📍 설치된 컴포넌트:"
echo "   - Istiod (Control Plane)"
echo "   - Istio Ingress Gateway"
echo "   - Istio Egress Gateway"
echo ""
echo "💡 Sidecar 자동 주입:"
echo "   - default 네임스페이스: 활성화"
echo ""
echo "다음 단계: ./deploy-with-istio.sh"
