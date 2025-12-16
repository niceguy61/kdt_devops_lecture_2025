#!/bin/bash

# VPC 및 서브넷 확인 스크립트

echo "🔍 기존 VPC 및 서브넷 확인..."
echo "=================================="

# 기존 VPC 목록 확인
echo "📋 기존 VPC 목록:"
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,State,Tags[?Key==`Name`].Value|[0]]' --output table

# 기본 VPC 확인
echo -e "\n📋 기본 VPC:"
aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[*].[VpcId,CidrBlock,State]' --output table

# 기본 VPC의 서브넷 확인
DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)

if [ "$DEFAULT_VPC_ID" != "None" ] && [ "$DEFAULT_VPC_ID" != "" ]; then
    echo -e "\n📋 기본 VPC ($DEFAULT_VPC_ID) 서브넷:"
    aws ec2 describe-subnets --filters "Name=vpc-id,Values=$DEFAULT_VPC_ID" \
        --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,MapPublicIpOnLaunch,Tags[?Key==`Name`].Value|[0]]' \
        --output table
    
    echo -e "\n💡 기존 VPC 사용 설정 예시:"
    echo "cluster-config-existing-vpc.yaml 파일에서 다음 값들을 수정하세요:"
    echo "vpc:"
    echo "  id: \"$DEFAULT_VPC_ID\""
    echo "  subnets:"
    
    # 퍼블릭 서브넷 (MapPublicIpOnLaunch=true)
    echo "    public:"
    aws ec2 describe-subnets --filters "Name=vpc-id,Values=$DEFAULT_VPC_ID" "Name=map-public-ip-on-launch,Values=true" \
        --query 'Subnets[*].[AvailabilityZone,SubnetId]' --output text | \
        while read az subnet_id; do
            echo "      $az:"
            echo "        id: \"$subnet_id\""
        done
    
    # 프라이빗 서브넷 (MapPublicIpOnLaunch=false)
    echo "    private:"
    aws ec2 describe-subnets --filters "Name=vpc-id,Values=$DEFAULT_VPC_ID" "Name=map-public-ip-on-launch,Values=false" \
        --query 'Subnets[*].[AvailabilityZone,SubnetId]' --output text | \
        while read az subnet_id; do
            echo "      $az:"
            echo "        id: \"$subnet_id\""
        done
else
    echo "⚠️  기본 VPC가 없습니다. 새 VPC를 생성하거나 기존 VPC를 사용하세요."
fi

echo -e "\n🎯 권장사항:"
echo "1. 새 VPC 생성 (권장): cluster-config.yaml 사용"
echo "   - 깨끗한 네트워크 환경"
   - EKS 전용 설정 최적화"
echo "2. 기존 VPC 사용: cluster-config-existing-vpc.yaml 수정 후 사용"
echo "   - 기존 리소스와 통합"
echo "   - 네트워크 설정 주의 필요"
