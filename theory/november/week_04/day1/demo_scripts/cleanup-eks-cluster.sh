#!/bin/bash

# November Week 4 Day 1 Demo: EKS 클러스터 정리
# 설명: Terraform으로 생성한 모든 리소스 삭제
# 사용법: ./cleanup-eks-cluster.sh

set -e

echo "=========================================="
echo "November Week 4 Day 1 Demo"
echo "EKS 클러스터 정리"
echo "=========================================="
echo ""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 현재 디렉토리 확인
if [ ! -f "provider.tf" ] || [ ! -f "eks.tf" ]; then
    echo -e "${RED}❌ Terraform 설정 파일을 찾을 수 없습니다.${NC}"
    echo "setup-eks-cluster.sh를 실행한 디렉토리에서 실행하세요."
    exit 1
fi

# 클러스터 이름 확인
if [ -f "terraform.tfstate" ]; then
    CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "")
    if [ -n "$CLUSTER_NAME" ]; then
        echo -e "${GREEN}✅ 클러스터 발견: $CLUSTER_NAME${NC}"
    fi
fi

# 사용자 확인
echo ""
echo -e "${YELLOW}⚠️  모든 리소스를 삭제하시겠습니까?${NC}"
echo "삭제될 리소스:"
echo "  - EKS Cluster"
echo "  - Managed Node Group"
echo "  - VPC (Subnets, NAT Gateway, Internet Gateway)"
echo "  - LoadBalancer"
echo "  - 모든 Kubernetes 리소스"
echo ""
read -p "정말로 삭제하시겠습니까? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo "취소되었습니다."
    exit 0
fi

# 1. Kubernetes 리소스 삭제
echo ""
echo "1/3 Kubernetes 리소스 삭제 중..."
if [ -f "test-deployment.yaml" ]; then
    kubectl delete -f test-deployment.yaml --ignore-not-found=true
    echo -e "${GREEN}✅ 테스트 워크로드 삭제 완료${NC}"
else
    echo -e "${YELLOW}⚠️  test-deployment.yaml 파일을 찾을 수 없습니다.${NC}"
fi

# LoadBalancer 완전 삭제 대기
echo "⏰ LoadBalancer 삭제 대기 중 (약 1-2분)..."
sleep 60

# 2. Terraform Destroy
echo ""
echo "2/3 Terraform Destroy 실행 중..."
echo "⏰ 약 10-15분 소요됩니다."
terraform destroy -auto-approve

echo -e "${GREEN}✅ Terraform 리소스 삭제 완료${NC}"

# 3. kubectl 컨텍스트 정리
echo ""
echo "3/3 kubectl 컨텍스트 정리 중..."
if [ -n "$CLUSTER_NAME" ]; then
    kubectl config delete-context "arn:aws:eks:*:*:cluster/$CLUSTER_NAME" 2>/dev/null || true
    kubectl config delete-cluster "arn:aws:eks:*:*:cluster/$CLUSTER_NAME" 2>/dev/null || true
    echo -e "${GREEN}✅ kubectl 컨텍스트 정리 완료${NC}"
fi

# 최종 확인
echo ""
echo "=========================================="
echo "✅ 정리 완료!"
echo "=========================================="
echo ""
echo "삭제된 리소스:"
echo "  - EKS Cluster: $CLUSTER_NAME"
echo "  - VPC 및 네트워크 리소스"
echo "  - Managed Node Group"
echo "  - LoadBalancer"
echo "  - 모든 Kubernetes 리소스"
echo ""
echo "💡 확인 방법:"
echo "  - AWS Console → EKS → Clusters"
echo "  - AWS Console → VPC → Your VPCs"
echo "  - AWS Console → EC2 → Load Balancers"
echo ""
echo "📁 Terraform 파일은 그대로 남아있습니다."
echo "디렉토리를 삭제하려면:"
echo "  cd .."
echo "  rm -rf $(basename $(pwd))"
echo ""
echo "=========================================="
