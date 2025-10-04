#!/bin/bash

# Week 3 Day 4 Hands-on 1: ETCD 암호화 설정 복구
# 사용법: ./rollback-etcd-encryption.sh

set -e

echo "=== ETCD 암호화 설정 복구 시작 ==="

# Kind 클러스터 이름 확인
CLUSTER_NAME=$(kind get clusters 2>/dev/null | head -1)
if [ -z "$CLUSTER_NAME" ]; then
    echo "❌ Kind 클러스터를 찾을 수 없습니다"
    exit 1
fi

CONTAINER_NAME="${CLUSTER_NAME}-control-plane"
echo "✅ 클러스터 발견: $CLUSTER_NAME"
echo "✅ 컨테이너: $CONTAINER_NAME"
echo ""

# 백업 파일 존재 확인
echo "백업 파일 확인 중..."
BACKUP_EXISTS=$(docker exec $CONTAINER_NAME test -f /etc/kubernetes/manifests/kube-apiserver.yaml.backup && echo "yes" || echo "no")

if [ "$BACKUP_EXISTS" = "yes" ]; then
    echo "✅ 백업 파일 발견"
    
    # 백업에서 복구
    docker exec -i $CONTAINER_NAME bash <<'EOF'
set -e

echo "백업 파일에서 복구 중..."
cp /etc/kubernetes/manifests/kube-apiserver.yaml.backup \
   /etc/kubernetes/manifests/kube-apiserver.yaml

echo "✅ 복구 완료"

# 암호화 설정 파일 제거
if [ -f /etc/kubernetes/encryption-config.yaml ]; then
    rm /etc/kubernetes/encryption-config.yaml
    echo "✅ 암호화 설정 파일 제거 완료"
fi
EOF

    echo ""
    echo "=== 복구 완료 ==="
    echo ""
    echo "API Server 재시작 대기 중 (30초)..."
    sleep 30
    
    echo "API Server 상태 확인:"
    kubectl get pods -n kube-system | grep kube-apiserver || echo "⚠️  아직 재시작 중입니다. 잠시 후 다시 확인하세요."
    
else
    echo "❌ 백업 파일이 없습니다"
    echo ""
    echo "클러스터를 재생성하는 것을 권장합니다:"
    echo "  kind delete cluster --name $CLUSTER_NAME"
    echo "  kind create cluster --name $CLUSTER_NAME"
fi

echo ""
echo "✅ 복구 작업 완료"
