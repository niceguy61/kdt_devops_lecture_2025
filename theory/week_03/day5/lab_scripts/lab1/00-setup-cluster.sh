#!/bin/bash

# Week 3 Day 5 Lab 1: 클러스터 환경 설정
# 사용법: ./00-setup-cluster.sh

set -e

echo "=== Week 3 Day 5 Lab 1 환경 설정 ==="
echo ""

NAMESPACE="day5-lab"
CLUSTER_NAME="challenge-cluster"

# 클러스터 확인
echo "1. Kubernetes 클러스터 확인 중..."
if kubectl cluster-info &> /dev/null; then
    echo "✅ 클러스터 연결 확인"
    kubectl cluster-info
else
    echo "❌ 클러스터에 연결할 수 없습니다."
    echo ""
    echo "클러스터를 생성하시겠습니까? (kind 사용)"
    read -p "계속 진행하시겠습니까? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "📦 kind 클러스터 생성 중..."
        
        # kind 설치 확인
        if ! command -v kind &> /dev/null; then
            echo "kind를 설치합니다..."
            curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
            chmod +x ./kind
            sudo mv ./kind /usr/local/bin/kind
        fi
        
        # 클러스터 생성
        cat <<EOF | kind create cluster --name $CLUSTER_NAME --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF
        
        echo "✅ kind 클러스터 '$CLUSTER_NAME' 생성 완료"
    else
        echo "클러스터 설정이 취소되었습니다."
        exit 1
    fi
fi

echo ""
echo "2. Namespace 생성 중..."
if kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "ℹ️  Namespace '$NAMESPACE'가 이미 존재합니다."
else
    kubectl create namespace $NAMESPACE
    echo "✅ Namespace '$NAMESPACE' 생성 완료"
fi

echo ""
echo "3. 기본 Namespace 설정 중..."
kubectl config set-context --current --namespace=$NAMESPACE
echo "✅ 기본 Namespace를 '$NAMESPACE'로 설정"

echo ""
echo "=== 환경 설정 완료 ==="
echo ""
echo "📊 클러스터 정보:"
kubectl cluster-info
echo ""
echo "📦 현재 Namespace: $NAMESPACE"
kubectl config view --minify | grep namespace:
echo ""
echo "🔍 노드 상태:"
kubectl get nodes
echo ""
echo "💡 다음 단계:"
echo "   ./01-install-helm.sh"
