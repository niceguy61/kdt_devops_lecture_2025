#!/bin/bash

# Week 4 Day 1 Lab 1: 사용자 마이크로서비스 배포 (간소화 버전)
# 사용법: ./deploy-user-service-simple.sh

echo "=== 사용자 마이크로서비스 배포 시작 ==="
echo ""

set -e
trap 'echo "❌ 스크립트 실행 중 오류 발생"' ERR

echo "1/3 사용자 서비스 및 데이터베이스 배포 중..."
kubectl apply -f manifests/microservices/user-service.yaml

echo "2/3 하이브리드 Ingress 설정 중..."
kubectl apply -f manifests/microservices/hybrid-ingress.yaml

# 기존 Ingress 삭제
kubectl delete ingress ecommerce-ingress -n ecommerce --ignore-not-found=true

echo "3/3 배포 상태 확인 중..."
kubectl wait --for=condition=ready pod -l app=user-db -n ecommerce --timeout=60s
kubectl wait --for=condition=ready pod -l app=user-service -n ecommerce --timeout=60s

echo ""
echo "=== 사용자 마이크로서비스 배포 완료 ==="
echo ""
echo "배포된 리소스:"
echo "- 사용자 데이터베이스: user-db (1 replica)"
echo "- 사용자 서비스: user-service (2 replicas)"
echo "- 하이브리드 Ingress: /api/users, /users → user-service"
echo ""
echo "상태 확인:"
kubectl get pods -n ecommerce
echo ""
echo "✅ 하이브리드 아키텍처 배포 성공!"
