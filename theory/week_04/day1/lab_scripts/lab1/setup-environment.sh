#!/bin/bash

# Week 4 Day 1 Lab 1: 환경 설정 스크립트
# 사용법: ./setup-environment.sh

echo "=== Week 4 Day 1 Lab 1: 환경 설정 시작 ==="
echo ""

# 에러 발생 시 스크립트 중단
set -e

echo "1/5 AWS CLI 설정 확인 중..."
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✅ AWS CLI 설정 완료"
    aws sts get-caller-identity --query 'Account' --output text
else
    echo "❌ AWS CLI 설정이 필요합니다"
    echo "aws configure를 실행하여 설정해주세요"
    exit 1
fi

echo ""
echo "2/5 kubectl 설정 확인 중..."
if kubectl version --client > /dev/null 2>&1; then
    echo "✅ kubectl 설치 확인"
    kubectl version --client | head -1
else
    echo "❌ kubectl이 설치되지 않았습니다"
    exit 1
fi

echo ""
echo "3/5 Docker 설정 확인 중..."
if docker --version > /dev/null 2>&1; then
    echo "✅ Docker 설치 확인"
    docker --version
else
    echo "❌ Docker가 설치되지 않았습니다"
    exit 1
fi

echo ""
echo "4/5 필요한 네임스페이스 생성 중..."
kubectl create namespace ecommerce-monolith --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ecommerce-microservices --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace testing --dry-run=client -o yaml | kubectl apply -f -
echo "✅ 네임스페이스 생성 완료"

echo ""
echo "5/5 작업 디렉토리 준비 중..."
mkdir -p manifests/{monolith,microservices,gateway,testing}
echo "✅ 디렉토리 구조 생성 완료"

echo ""
echo "=== 환경 설정 완료 ==="
echo ""
echo "생성된 네임스페이스:"
kubectl get namespaces | grep ecommerce
echo ""
echo "다음 단계: ./deploy-monolith.sh 실행"
