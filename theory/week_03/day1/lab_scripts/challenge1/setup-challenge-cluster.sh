#!/bin/bash

# Challenge 1용 Kind 클러스터 생성 스크립트

echo "🚀 Challenge 1용 Kubernetes 클러스터 생성 시작..."

# 기존 클러스터 확인 및 삭제
if kind get clusters | grep -q "challenge-cluster"; then
    echo "⚠️  기존 challenge-cluster 발견. 삭제 중..."
    kind delete cluster --name challenge-cluster
    sleep 5
fi

# Kind 클러스터 생성
echo "📦 Kind 클러스터 생성 중..."
cat <<EOF | kind create cluster --name challenge-cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
  - containerPort: 30081
    hostPort: 30081
    protocol: TCP
- role: worker
- role: worker
EOF

# 클러스터 생성 확인
if [ $? -eq 0 ]; then
    echo "✅ 클러스터 생성 완료!"
    
    # 컨텍스트 설정
    kubectl config use-context kind-challenge-cluster
    
    echo ""
    echo "🎯 클러스터 정보:"
    kubectl cluster-info
    
    echo ""
    echo "📋 노드 상태:"
    kubectl get nodes
    
    echo ""
    echo "✅ Challenge 1용 클러스터 준비 완료!"
    echo "   다음 명령어로 문제 애플리케이션을 배포하세요:"
    echo "   ./deploy-broken-app.sh"
else
    echo "❌ 클러스터 생성 실패!"
    exit 1
fi
