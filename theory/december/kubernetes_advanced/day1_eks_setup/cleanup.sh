#!/bin/bash

# EKS 클러스터 완전 삭제 스크립트
# VPC 및 모든 관련 리소스 포함

echo "🗑️ EKS 클러스터 삭제 시작..."

# 클러스터 이름과 리전 설정
CLUSTER_NAME="my-eks-cluster"
REGION="ap-northeast-2"
PROFILE="sso"

echo "📋 현재 클러스터 상태 확인..."
eksctl get cluster --name $CLUSTER_NAME --region $REGION --profile $PROFILE

echo "🔍 노드 그룹 확인..."
eksctl get nodegroup --cluster $CLUSTER_NAME --region $REGION --profile $PROFILE

echo "⚠️  클러스터 삭제를 시작합니다. 이 작업은 되돌릴 수 없습니다!"
read -p "계속하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 삭제 취소됨"
    exit 1
fi

echo "🗑️ EKS 클러스터 삭제 중... (약 10-15분 소요)"
eksctl delete cluster --name $CLUSTER_NAME --region $REGION --profile $PROFILE

echo "✅ EKS 클러스터 삭제 완료!"
echo "📝 삭제된 리소스:"
echo "   - EKS 클러스터: $CLUSTER_NAME"
echo "   - 노드 그룹: worker-nodes-small (또는 worker-nodes)"
echo "   - VPC 및 서브넷 (10.0.0.0/16)"
echo "   - Internet Gateway"
echo "   - NAT Gateway"
echo "   - Route Tables"
echo "   - Security Groups"
echo "   - IAM 역할 및 정책"
echo "   - EC2 인스턴스"
echo "   - EBS 볼륨"

echo "🎉 모든 리소스가 성공적으로 삭제되었습니다!"
