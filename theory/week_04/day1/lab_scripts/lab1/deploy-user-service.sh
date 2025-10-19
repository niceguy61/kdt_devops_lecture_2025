#!/bin/bash

echo "=== 사용자 서비스 마이크로서비스 분리 시작 ==="
echo ""

set -e
trap 'echo "❌ 스크립트 실행 중 오류 발생"' ERR

echo "1/2 사용자 서비스 및 전용 DB 배포 중..."
kubectl apply -f manifests/microservices/user-service.yaml

echo "2/2 하이브리드 Ingress 설정 중..."
kubectl apply -f manifests/microservices/hybrid-ingress.yaml

# 기존 모놀리스 Ingress 삭제
kubectl delete ingress ecommerce-ingress -n ecommerce 2>/dev/null || true

echo ""
echo "배포 상태 확인 중..."
kubectl wait --for=condition=ready pod -l app=user-service -n ecommerce --timeout=60s

echo ""
echo "=== 사용자 서비스 마이크로서비스 분리 완료 ==="
echo ""

echo "📊 배포된 리소스:"
echo "- User Service: 마이크로서비스 (2 replicas)"
echo "- User DB: 독립 데이터베이스"
echo "- Monolith: 상품 + 주문 기능만 유지"
echo ""

echo "🔀 라우팅 규칙:"
echo "- /api/users → user-service (마이크로서비스)"
echo "- 나머지 경로 → monolith (기존 모놀리스)"
echo ""

echo "상태 확인:"
kubectl get pods -n ecommerce
echo ""

echo "✅ 하이브리드 아키텍처 구성 완료!"
