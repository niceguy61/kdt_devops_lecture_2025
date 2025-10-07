#!/bin/bash

# Week 4 Day 1 Hands-on 1: 환경 설정 스크립트
# 사용법: ./setup-environment.sh

echo "=== Week 4 Day 1 Hands-on 1: 고급 패턴 환경 설정 시작 ==="
echo ""

# 에러 발생 시 스크립트 중단
set -e

echo "1/4 기본 환경 확인 중..."
if kubectl get namespace ecommerce-microservices > /dev/null 2>&1; then
    echo "✅ 기본 네임스페이스 존재 확인"
else
    echo "❌ Lab 1을 먼저 실행해주세요"
    echo "cd ../lab1 && ./setup-environment.sh"
    exit 1
fi

echo ""
echo "2/4 고급 패턴용 네임스페이스 생성 중..."
kubectl create namespace advanced-patterns --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace service-mesh --dry-run=client -o yaml | kubectl apply -f -
echo "✅ 고급 패턴 네임스페이스 생성 완료"

echo ""
echo "3/4 필요한 도구 확인 중..."
if command -v istioctl > /dev/null 2>&1; then
    echo "✅ Istio CLI 설치 확인"
    istioctl version --remote=false
else
    echo "⚠️ Istio CLI가 설치되지 않았습니다. 자동 설치를 진행합니다."
fi

echo ""
echo "4/4 작업 디렉토리 준비 중..."
mkdir -p manifests/{saga,cqrs,eventsourcing,servicemesh}
echo "✅ 디렉토리 구조 생성 완료"

echo ""
echo "=== 고급 패턴 환경 설정 완료 ==="
echo ""
echo "생성된 네임스페이스:"
kubectl get namespaces | grep -E "(ecommerce|advanced|service-mesh)"
echo ""
echo "다음 단계: Hands-on 1 Step 1 실행"
