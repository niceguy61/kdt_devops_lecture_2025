#!/bin/bash

# EKS 클러스터 정리 스크립트
# 주의: 이 스크립트는 클러스터를 완전히 삭제합니다!

CLUSTER_NAME="my-eks-cluster"
REGION="ap-northeast-2"

echo "⚠️  경고: 클러스터 '$CLUSTER_NAME'를 삭제합니다!"
echo "계속하려면 'yes'를 입력하세요:"
read -r confirmation

if [ "$confirmation" != "yes" ]; then
    echo "❌ 삭제 취소됨"
    exit 0
fi

echo "🗑️  클러스터 삭제 시작..."

# 1. 클러스터 존재 확인
if eksctl get cluster --name "$CLUSTER_NAME" --region "$REGION" > /dev/null 2>&1; then
    echo "✅ 클러스터 '$CLUSTER_NAME' 발견"
    
    # 2. 클러스터 삭제
    echo "🔄 클러스터 삭제 중... (약 10-15분 소요)"
    eksctl delete cluster --name "$CLUSTER_NAME" --region "$REGION"
    
    if [ $? -eq 0 ]; then
        echo "✅ 클러스터 삭제 완료"
    else
        echo "❌ 클러스터 삭제 실패"
        exit 1
    fi
else
    echo "❌ 클러스터 '$CLUSTER_NAME'를 찾을 수 없습니다"
fi

# 3. kubeconfig 정리
echo "🧹 kubeconfig 정리 중..."
kubectl config delete-context "arn:aws:eks:$REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$CLUSTER_NAME" 2>/dev/null || true
kubectl config delete-cluster "arn:aws:eks:$REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$CLUSTER_NAME" 2>/dev/null || true

echo "🎯 정리 완료!"
