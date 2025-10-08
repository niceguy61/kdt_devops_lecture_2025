#!/bin/bash

# Week 4 Day 2 Lab 1: 전체 서비스 자동 구축
# 사용법: ./setup-all-services.sh

echo "=========================================="
echo "  Week 4 Day 2 Lab 1: 전체 서비스 구축"
echo "  API Gateway & 서비스 디스커버리"
echo "=========================================="
echo ""

# 시작 시간 기록
start_time=$(date +%s)

# 1. 네트워크 구성
echo "🌐 Step 1/7: Docker 네트워크 구성"
./setup-network.sh
if [ $? -ne 0 ]; then
    echo "❌ 네트워크 구성 실패"
    exit 1
fi
echo ""

# 2. Consul 서비스 디스커버리 구축
echo "🔍 Step 2/7: Consul 서비스 디스커버리 구축"
./setup-consul.sh
if [ $? -ne 0 ]; then
    echo "❌ Consul 구축 실패"
    exit 1
fi
echo ""

# 3. User Service 배포
echo "👤 Step 3/7: User Service 배포"
./deploy-user-service.sh
if [ $? -ne 0 ]; then
    echo "❌ User Service 배포 실패"
    exit 1
fi
echo ""

# 4. Product Service 배포
echo "📦 Step 4/7: Product Service 배포"
./deploy-product-service.sh
if [ $? -ne 0 ]; then
    echo "❌ Product Service 배포 실패"
    exit 1
fi
echo ""

# 5. Order Service 배포
echo "📋 Step 5/7: Order Service 배포"
./deploy-order-service.sh
if [ $? -ne 0 ]; then
    echo "❌ Order Service 배포 실패"
    exit 1
fi
echo ""

# 6. Kong API Gateway 구축
echo "🚪 Step 6/7: Kong API Gateway 구축"
./setup-kong.sh
if [ $? -ne 0 ]; then
    echo "❌ Kong Gateway 구축 실패"
    exit 1
fi
echo ""

# 7. Kong 라우트 설정
echo "🛣️  Step 7/7: Kong 라우트 설정"
./configure-kong-routes.sh
if [ $? -ne 0 ]; then
    echo "❌ Kong 라우트 설정 실패"
    exit 1
fi
echo ""

# 완료 시간 계산
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo "=========================================="
echo "🎉 전체 서비스 구축 완료!"
echo "⏱️  소요 시간: ${minutes}분 ${seconds}초"
echo "=========================================="
echo ""

# 최종 상태 확인
echo "🔍 최종 상태 확인 중..."
echo ""

# 컨테이너 상태 확인
echo "=== 실행 중인 컨테이너 ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(consul|kong|user-service|product-service|order-service|db|cache)"

echo ""
echo "=== 서비스 헬스체크 ==="

# 각 서비스 헬스체크
services=("user-service:3001" "product-service:3002" "order-service:3003")
for service in "${services[@]}"; do
    name=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    
    if curl -s http://localhost:$port/health > /dev/null; then
        echo "✅ $name: 정상"
    else
        echo "❌ $name: 비정상"
    fi
done

# Consul 상태 확인
if curl -s http://localhost:8500/v1/status/leader > /dev/null; then
    echo "✅ Consul: 정상"
else
    echo "❌ Consul: 비정상"
fi

# Kong 상태 확인
if curl -s http://localhost:8001/ > /dev/null; then
    echo "✅ Kong Gateway: 정상"
else
    echo "❌ Kong Gateway: 비정상"
fi

echo ""
echo "=== 접속 정보 ==="
echo "🌐 서비스 URL:"
echo "  - Consul UI: http://localhost:8500/ui"
echo "  - Kong Admin: http://localhost:8001"
echo "  - Kong Manager: http://localhost:8002"
echo ""
echo "🔗 API 엔드포인트 (Kong을 통한 접근):"
echo "  - 사용자 API: http://localhost:8000/api/users"
echo "  - 상품 API: http://localhost:8000/api/products"
echo "  - 주문 API: http://localhost:8000/api/orders"
echo ""
echo "🔗 직접 서비스 접근:"
echo "  - User Service: http://localhost:3001/users"
echo "  - Product Service: http://localhost:3002/products"
echo "  - Order Service: http://localhost:3003/orders"
echo ""

# 간단한 API 테스트
echo "=== 간단한 API 테스트 ==="
echo "📋 사용자 목록 (처음 3명):"
curl -s http://localhost:3001/users | jq -r '.[:3][] | "  - \(.name) (\(.email))"' 2>/dev/null || echo "  API 응답 대기 중..."

echo ""
echo "📦 상품 목록 (처음 2개):"
curl -s http://localhost:3002/products | jq -r '.[:2][] | "  - \(.name): $\(.price)"' 2>/dev/null || echo "  API 응답 대기 중..."

echo ""
echo "📋 주문 목록:"
curl -s http://localhost:3003/orders | jq -r '.[] | "  - 주문 #\(.id): \(.status) ($\(.totalAmount))"' 2>/dev/null || echo "  API 응답 대기 중..."

echo ""
echo "=========================================="
echo "🚀 실습 준비 완료!"
echo ""
echo "다음 단계:"
echo "1. 서비스 디스커버리 테스트: ./test-service-discovery.sh"
echo "2. 실습 정리: ./cleanup.sh"
echo "=========================================="
