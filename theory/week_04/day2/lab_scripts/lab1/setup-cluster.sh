#!/bin/bash

# Lab 1: Kong API Gateway - 클러스터 생성

echo "=== Kong API Gateway Lab - 클러스터 생성 시작 ==="
echo ""

# 1. 기존 클러스터 확인 및 삭제
echo "1. 기존 클러스터 확인 중..."
if kind get clusters | grep -q "lab-cluster"; then
    echo "   ⚠️  기존 lab-cluster 발견"
    echo "   🗑️  기존 클러스터 삭제 중..."
    kind delete cluster --name lab-cluster
    echo "   ✅ 기존 클러스터 삭제 완료"
fi

# 2. Kind 클러스터 생성 (포트 매핑)
echo ""
echo "2. Kind 클러스터 생성 중 (포트 8000, 8001 매핑)..."
cat <<YAML | kind create cluster --name lab-cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8000
    protocol: TCP
  - containerPort: 30081
    hostPort: 8001
    protocol: TCP
YAML

echo "   ✅ 클러스터 생성 완료"

# 3. kubectl 컨텍스트 설정
echo ""
echo "3. kubectl 컨텍스트 설정 중..."
kubectl config use-context kind-lab-cluster
echo "   ✅ 컨텍스트 설정 완료"

# 4. 클러스터 상태 확인
echo ""
echo "4. 클러스터 상태 확인 중..."
kubectl cluster-info
kubectl get nodes

echo ""
echo "=== 클러스터 생성 완료 ==="
echo ""
echo "📍 포트 매핑:"
echo "   - Kong Proxy: localhost:8000 → NodePort 30080"
echo "   - Kong Admin: localhost:8001 → NodePort 30081"
echo ""
echo "다음 단계: ./install-kong.sh"
