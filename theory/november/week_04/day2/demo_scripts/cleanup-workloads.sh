#!/bin/bash

# November Week 4 Day 2: 워크로드 및 클러스터 정리
# 설명: 데모에서 생성한 모든 리소스 삭제

set -e

echo "=== 워크로드 및 클러스터 정리 시작 ==="
echo ""

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. 부하 생성 Pod 삭제 (있으면)
echo -e "${BLUE}1/5 부하 생성 Pod 삭제 중...${NC}"
kubectl delete pod load-generator --ignore-not-found=true
echo -e "${GREEN}✅ 부하 생성 Pod 삭제 완료${NC}"
echo ""

# 2. HPA 삭제
echo -e "${BLUE}2/5 HPA 삭제 중...${NC}"
kubectl delete hpa nginx-app --ignore-not-found=true
echo -e "${GREEN}✅ HPA 삭제 완료${NC}"
echo ""

# 3. Service 삭제 (LoadBalancer 먼저 삭제)
echo -e "${BLUE}3/5 Service 삭제 중...${NC}"
kubectl delete service nginx-service --ignore-not-found=true
echo "LoadBalancer 삭제 대기 중 (약 1분 소요)..."
sleep 60
echo -e "${GREEN}✅ Service 삭제 완료${NC}"
echo ""

# 4. Deployment 삭제
echo -e "${BLUE}4/5 Deployment 삭제 중...${NC}"
kubectl delete deployment nginx-app --ignore-not-found=true
echo -e "${GREEN}✅ Deployment 삭제 완료${NC}"
echo ""

# 5. 클러스터 삭제 확인
echo -e "${BLUE}5/5 클러스터 삭제 확인...${NC}"
echo -e "${YELLOW}클러스터를 삭제하시겠습니까? (y/N)${NC}"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "클러스터 삭제 중..."
    if [ -f "../../day1/demo_scripts/cleanup-eks-cluster.sh" ]; then
        cd ../../day1/demo_scripts
        ./cleanup-eks-cluster.sh
        cd ../../day2/demo_scripts
    else
        echo "❌ Day 1 정리 스크립트를 찾을 수 없습니다."
    fi
else
    echo "클러스터는 유지됩니다."
fi

echo ""
echo "=== 워크로드 정리 완료 ==="
echo ""
