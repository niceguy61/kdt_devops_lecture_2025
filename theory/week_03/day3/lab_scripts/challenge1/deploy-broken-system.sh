#!/bin/bash

# Challenge 1: 문제가 있는 E-Shop 시스템 배포

echo "🚀 Challenge 1: E-Shop 장애 시스템 배포 시작..."

echo "📦 네임스페이스 생성 중..."
kubectl create namespace day3-challenge --dry-run=client -o yaml | kubectl apply -f -

echo "🗄️ 데이터베이스 배포 중 (PVC 문제 포함)..."
kubectl apply -f broken-database-pvc.yaml

echo "🔧 백엔드 API 배포 중 (서비스 이름 오류 포함)..."
kubectl apply -f broken-backend-service.yaml

echo "🎨 프론트엔드 배포 중..."
kubectl apply -f frontend-deployment.yaml

echo "🌐 Ingress 배포 중 (라우팅 오류 포함)..."
kubectl apply -f broken-ingress.yaml

echo "🔐 네트워크 정책 배포 중 (라벨 불일치 포함)..."
kubectl apply -f broken-network-policy.yaml

echo "❌ 문제가 있는 E-Shop 시스템 배포 완료!"
echo ""
echo "🚨 발생한 문제들:"
echo "1. DNS 해결 실패 - 잘못된 서비스 이름"
echo "2. Ingress 라우팅 오류 - 존재하지 않는 서비스 참조"
echo "3. PVC 바인딩 실패 - 불가능한 스토리지 요청"
echo "4. 네트워크 정책 차단 - 라벨 불일치"
echo ""
echo "🔍 문제 해결을 시작하세요!"
echo "kubectl get all -n day3-challenge"
