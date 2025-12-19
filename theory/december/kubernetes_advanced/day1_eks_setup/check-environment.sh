#!/bin/bash

# EKS 실습 환경 체크 스크립트
# 사용법: ./check-environment.sh

echo "🔍 EKS 실습 환경 체크를 시작합니다..."
echo "=================================================="

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 체크 결과 저장
ERRORS=0
WARNINGS=0

# 함수 정의
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 설치됨"
        return 0
    else
        echo -e "${RED}✗${NC} $1 설치되지 않음"
        return 1
    fi
}

check_aws_permission() {
    local service=$1
    local command=$2
    
    if eval $command &> /dev/null; then
        echo -e "${GREEN}✓${NC} $service 권한 확인됨"
        return 0
    else
        echo -e "${RED}✗${NC} $service 권한 없음"
        return 1
    fi
}

echo "1. 필수 도구 설치 확인"
echo "------------------------"

# AWS CLI 확인
if check_command "aws"; then
    AWS_VERSION=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
    echo "   버전: $AWS_VERSION"
    
    # AWS CLI v2 확인
    if [[ $AWS_VERSION == 2.* ]]; then
        echo -e "   ${GREEN}✓${NC} AWS CLI v2 사용 중"
    else
        echo -e "   ${YELLOW}⚠${NC} AWS CLI v1 감지됨. v2 권장"
        ((WARNINGS++))
    fi
else
    echo "   설치 방법: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    ((ERRORS++))
fi

# eksctl 확인
if check_command "eksctl"; then
    EKSCTL_VERSION=$(eksctl version 2>&1)
    echo "   버전: $EKSCTL_VERSION"
else
    echo "   설치 방법: https://eksctl.io/installation/"
    ((ERRORS++))
fi

# kubectl 확인
if check_command "kubectl"; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>&1 | grep -v "WARNING")
    echo "   버전: $KUBECTL_VERSION"
else
    echo "   설치 방법: https://kubernetes.io/docs/tasks/tools/"
    ((ERRORS++))
fi

echo ""
echo "2. AWS 자격 증명 확인"
echo "----------------------"

# AWS 자격 증명 확인
if aws sts get-caller-identity &> /dev/null; then
    echo -e "${GREEN}✓${NC} AWS 자격 증명 설정됨"
    
    # 계정 정보 출력
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
    USER_ARN=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)
    REGION=$(aws configure get region 2>/dev/null)
    
    echo "   계정 ID: $ACCOUNT_ID"
    echo "   사용자: $USER_ARN"
    echo "   기본 리전: ${REGION:-'설정되지 않음'}"
    
    if [ -z "$REGION" ]; then
        echo -e "   ${YELLOW}⚠${NC} 기본 리전이 설정되지 않음. ap-northeast-2 권장"
        ((WARNINGS++))
    elif [ "$REGION" != "ap-northeast-2" ]; then
        echo -e "   ${YELLOW}⚠${NC} 실습용 리전(ap-northeast-2)과 다름"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}✗${NC} AWS 자격 증명 설정되지 않음"
    echo "   해결 방법: aws configure 명령어 실행"
    ((ERRORS++))
fi

echo ""
echo "3. AWS 권한 확인"
echo "----------------"

# EKS 권한 확인
if check_aws_permission "EKS" "aws eks list-clusters --region ap-northeast-2"; then
    :
else
    echo "   필요 권한: eks:ListClusters"
    ((ERRORS++))
fi

# EC2 권한 확인  
if check_aws_permission "EC2" "aws ec2 describe-vpcs --region ap-northeast-2 --max-items 1"; then
    :
else
    echo "   필요 권한: ec2:DescribeVpcs"
    ((ERRORS++))
fi

# IAM 권한 확인
if check_aws_permission "IAM" "aws iam list-roles --max-items 1"; then
    :
else
    echo "   필요 권한: iam:ListRoles"
    ((ERRORS++))
fi

# CloudFormation 권한 확인
if check_aws_permission "CloudFormation" "aws cloudformation list-stacks --region ap-northeast-2 --max-items 1"; then
    :
else
    echo "   필요 권한: cloudformation:ListStacks"
    ((ERRORS++))
fi

echo ""
echo "4. 네트워크 연결 확인"
echo "--------------------"

# AWS API 연결 테스트
if curl -s --max-time 10 -I https://eks.ap-northeast-2.amazonaws.com > /dev/null; then
    echo -e "${GREEN}✓${NC} AWS EKS API 연결 가능"
else
    echo -e "${RED}✗${NC} AWS EKS API 연결 실패"
    echo "   방화벽 또는 프록시 설정 확인 필요"
    ((ERRORS++))
fi

echo ""
echo "=================================================="
echo "🏁 환경 체크 완료"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ 모든 요구사항이 충족되었습니다!${NC}"
    echo "EKS 실습을 시작할 수 있습니다."
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  경고 $WARNINGS개가 있지만 실습 진행 가능합니다.${NC}"
    echo "가능하면 경고 사항을 해결한 후 진행하세요."
    exit 0
else
    echo -e "${RED}❌ 오류 $ERRORS개, 경고 $WARNINGS개가 발견되었습니다.${NC}"
    echo ""
    echo "다음 문서를 참조하여 문제를 해결해주세요:"
    echo "📖 requirements.md - 상세한 설정 가이드"
    echo ""
    echo "주요 해결 방법:"
    echo "• 도구 미설치: requirements.md의 '필수 도구 설치' 섹션 참조"
    echo "• 자격 증명 오류: aws configure 명령어로 설정"
    echo "• 권한 오류: AWS 관리자에게 EKS 관련 권한 요청"
    exit 1
fi