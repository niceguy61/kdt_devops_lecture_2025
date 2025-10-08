#!/bin/bash

# Week 4 Day 2 Lab 1: 환경 준비
# Kubernetes 클러스터 확인 및 기존 리소스 정리

echo "=== Istio Gateway API Lab 환경 준비 시작 ==="
echo ""

# Kubernetes 클러스터 확인
echo "1. Kubernetes 클러스터 확인 중..."
if ! kubectl cluster-info &>/dev/null; then
    echo "   ❌ Kubernetes 클러스터에 연결할 수 없습니다"
    echo "   💡 kind, minikube, 또는 다른 클러스터를 시작하세요"
    exit 1
fi
echo "   ✅ Kubernetes 클러스터 연결 확인"

# 기존 리소스 정리
echo ""
echo "2. 기존 리소스 정리 중..."

# HTTPRoute 삭제
kubectl delete httproute user-route product-route order-route 2>/dev/null || true

# Gateway 삭제
kubectl delete gateway api-gateway 2>/dev/null || true

# 서비스 삭제
kubectl delete deployment,service user-service product-service order-service 2>/dev/null || true

# Port-forward 프로세스 종료
pkill -f "kubectl port-forward" 2>/dev/null || true

echo "   ✅ 기존 리소스 정리 완료"

# 필수 도구 확인
echo ""
echo "3. 필수 도구 확인 중..."

if ! command -v kubectl &>/dev/null; then
    echo "   ❌ kubectl이 설치되지 않았습니다"
    exit 1
fi
echo "   ✅ kubectl: $(kubectl version --client --short 2>/dev/null | head -1)"

if ! command -v curl &>/dev/null; then
    echo "   ❌ curl이 설치되지 않았습니다"
    exit 1
fi
echo "   ✅ curl: 설치됨"

# Istio 확인
echo ""
echo "4. Istio 설치 확인 중..."
if kubectl get namespace istio-system &>/dev/null; then
    echo "   ℹ️  Istio가 이미 설치되어 있습니다"
    echo "   💡 기존 Istio를 사용합니다"
else
    echo "   ℹ️  Istio가 설치되지 않았습니다"
    echo "   💡 Step 2에서 Istio를 설치하세요"
fi

echo ""
echo "=== 환경 준비 완료 ==="
echo ""
echo "작업 디렉토리: $(pwd)"
echo "Kubernetes Context: $(kubectl config current-context)"
echo ""
echo "다음 단계: Istio 설치"
