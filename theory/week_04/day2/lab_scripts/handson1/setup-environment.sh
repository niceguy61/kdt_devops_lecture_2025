#!/bin/bash

# Week 4 Day 2 Hands-on 1: 환경 준비
# Lab 1 기반 확인 및 기존 고급 기능 리소스 정리

echo "=== Istio 고급 트래픽 관리 실습 환경 준비 시작 ==="
echo ""

# Kubernetes 클러스터 확인
echo "1. Kubernetes 클러스터 확인 중..."
if ! kubectl cluster-info &>/dev/null; then
    echo "   ❌ Kubernetes 클러스터에 연결할 수 없습니다"
    exit 1
fi
echo "   ✅ Kubernetes 클러스터 연결 확인"

# Istio 확인
echo ""
echo "2. Istio 설치 확인 중..."
if ! kubectl get namespace istio-system &>/dev/null; then
    echo "   ❌ Istio가 설치되지 않았습니다"
    echo "   💡 먼저 Lab 1을 완료하세요"
    exit 1
fi
echo "   ✅ Istio 설치 확인"

# Lab 1 리소스 확인
echo ""
echo "3. Lab 1 리소스 확인 중..."
if ! kubectl get gateway api-gateway &>/dev/null; then
    echo "   ❌ Lab 1이 완료되지 않았습니다"
    echo "   💡 먼저 Lab 1을 완료하세요"
    exit 1
fi
echo "   ✅ Lab 1 리소스 확인 완료"

# 기존 고급 기능 리소스 정리
echo ""
echo "4. 기존 고급 기능 리소스 정리 중..."

# VirtualService 삭제
kubectl delete virtualservice user-service product-service 2>/dev/null || true

# DestinationRule 삭제
kubectl delete destinationrule user-service product-service 2>/dev/null || true

# v2 Deployment 삭제
kubectl delete deployment user-service-v2 product-service-v2 2>/dev/null || true

# Security 정책 삭제
kubectl delete peerauthentication default 2>/dev/null || true
kubectl delete authorizationpolicy user-service-policy 2>/dev/null || true

# Kiali 프로세스 종료
pkill -f "istioctl dashboard kiali" 2>/dev/null || true

echo "   ✅ 기존 리소스 정리 완료"

echo ""
echo "=== 환경 준비 완료 ==="
echo ""
echo "작업 디렉토리: $(pwd)"
echo "Kubernetes Context: $(kubectl config current-context)"
echo ""
echo "다음 단계: Canary 배포 구현"
