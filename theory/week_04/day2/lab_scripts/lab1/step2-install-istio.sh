#!/bin/bash

# Step 2: Istio 설치

echo "=== Step 2: Istio 설치 시작 ==="
echo ""

# Istio 다운로드
echo "1. Istio 다운로드 중..."
if [ ! -d "istio-1.20.0" ]; then
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -
    echo "   ✅ Istio 다운로드 완료"
else
    echo "   ℹ️  Istio가 이미 다운로드되어 있습니다"
fi

# PATH 추가
cd istio-1.20.0
export PATH=$PWD/bin:$PATH

# Istio 설치
echo ""
echo "2. Istio 설치 중..."
istioctl install --set profile=minimal -y

# 설치 확인
echo ""
echo "3. Istio 설치 확인 중..."
kubectl wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=120s

echo ""
kubectl get pods -n istio-system
echo ""
kubectl get svc -n istio-system

# Default namespace에 Sidecar Injection 활성화
echo ""
echo "4. Sidecar Injection 활성화 중..."
kubectl label namespace default istio-injection=enabled --overwrite
kubectl get namespace default --show-labels

echo ""
echo "=== Step 2: Istio 설치 완료 ==="
