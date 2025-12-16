#!/bin/bash

# EKS 클러스터 설정 확인 스크립트

echo "🚀 EKS 클러스터 설정 확인 시작..."
echo "=================================="

# 1. AWS CLI 설정 확인
echo "1. AWS CLI 설정 확인"
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✅ AWS CLI 설정 완료"
    aws sts get-caller-identity --query 'Account' --output text | xargs echo "   계정 ID:"
else
    echo "❌ AWS CLI 설정 필요"
    exit 1
fi

# 2. 필수 도구 설치 확인
echo -e "\n2. 필수 도구 설치 확인"

# eksctl 확인
if command -v eksctl &> /dev/null; then
    echo "✅ eksctl 설치됨: $(eksctl version)"
else
    echo "❌ eksctl 설치 필요"
    echo "   설치 명령: curl --silent --location \"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_\$(uname -s)_amd64.tar.gz\" | tar xz -C /tmp && sudo mv /tmp/eksctl /usr/local/bin"
fi

# kubectl 확인
if command -v kubectl &> /dev/null; then
    echo "✅ kubectl 설치됨: $(kubectl version --client --short 2>/dev/null)"
else
    echo "❌ kubectl 설치 필요"
fi

# 3. 클러스터 상태 확인
echo -e "\n3. 클러스터 상태 확인"
if kubectl cluster-info > /dev/null 2>&1; then
    echo "✅ 클러스터 연결됨"
    kubectl get nodes --no-headers | wc -l | xargs echo "   노드 수:"
    kubectl get nodes -o wide
else
    echo "❌ 클러스터 연결 안됨"
fi

# 4. 네임스페이스 확인
echo -e "\n4. 기본 네임스페이스 확인"
kubectl get namespaces

echo -e "\n=================================="
echo "🎯 설정 확인 완료!"
