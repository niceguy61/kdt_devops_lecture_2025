#!/bin/bash

# Week 4 Day 2 Lab 1: Kong 라우트 설정
# 사용법: ./configure-kong-routes.sh

echo "=== Kong 라우트 설정 시작 ==="

# Kong 상태 확인
echo "1. Kong Gateway 상태 확인 중..."
if ! curl -s http://localhost:8001/ > /dev/null; then
    echo "❌ Kong Gateway가 실행되지 않았습니다"
    echo "먼저 ./setup-kong.sh를 실행하세요"
    exit 1
fi

# User Service 등록
echo "2. User Service 등록 중..."
USER_SERVICE_ID=$(curl -s -X POST http://localhost:8001/services/ \
  --data "name=user-service" \
  --data "url=http://user-service:3001" | jq -r '.id')

if [ "$USER_SERVICE_ID" != "null" ]; then
    echo "✅ User Service 등록 완료 (ID: $USER_SERVICE_ID)"
    
    # User Service 라우트 생성
    curl -s -X POST http://localhost:8001/services/user-service/routes \
      --data "paths[]=/api/users" \
      --data "strip_path=false" > /dev/null
    echo "✅ User Service 라우트 생성 완료"
else
    echo "❌ User Service 등록 실패"
fi

# Product Service 등록
echo "3. Product Service 등록 중..."
PRODUCT_SERVICE_ID=$(curl -s -X POST http://localhost:8001/services/ \
  --data "name=product-service" \
  --data "url=http://product-service:3002" | jq -r '.id')

if [ "$PRODUCT_SERVICE_ID" != "null" ]; then
    echo "✅ Product Service 등록 완료 (ID: $PRODUCT_SERVICE_ID)"
    
    # Product Service 라우트 생성
    curl -s -X POST http://localhost:8001/services/product-service/routes \
      --data "paths[]=/api/products" \
      --data "strip_path=false" > /dev/null
    echo "✅ Product Service 라우트 생성 완료"
else
    echo "❌ Product Service 등록 실패"
fi

# Order Service 등록
echo "4. Order Service 등록 중..."
ORDER_SERVICE_ID=$(curl -s -X POST http://localhost:8001/services/ \
  --data "name=order-service" \
  --data "url=http://order-service:3003" | jq -r '.id')

if [ "$ORDER_SERVICE_ID" != "null" ]; then
    echo "✅ Order Service 등록 완료 (ID: $ORDER_SERVICE_ID)"
    
    # Order Service 라우트 생성
    curl -s -X POST http://localhost:8001/services/order-service/routes \
      --data "paths[]=/api/orders" \
      --data "strip_path=false" > /dev/null
    echo "✅ Order Service 라우트 생성 완료"
else
    echo "❌ Order Service 등록 실패"
fi

# 헬스체크 라우트 추가
echo "5. 헬스체크 라우트 설정 중..."

# 통합 헬스체크 라우트
curl -s -X POST http://localhost:8001/services/user-service/routes \
  --data "paths[]=/health/users" \
  --data "strip_path=true" > /dev/null

curl -s -X POST http://localhost:8001/services/product-service/routes \
  --data "paths[]=/health/products" \
  --data "strip_path=true" > /dev/null

curl -s -X POST http://localhost:8001/services/order-service/routes \
  --data "paths[]=/health/orders" \
  --data "strip_path=true" > /dev/null

echo "✅ 헬스체크 라우트 설정 완료"

# Rate Limiting 플러그인 추가 (기본 설정)
echo "6. Rate Limiting 플러그인 설정 중..."
curl -s -X POST http://localhost:8001/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=100" \
  --data "config.hour=1000" > /dev/null
echo "✅ Rate Limiting 플러그인 설정 완료 (분당 100회, 시간당 1000회)"

# CORS 플러그인 추가
echo "7. CORS 플러그인 설정 중..."
curl -s -X POST http://localhost:8001/plugins \
  --data "name=cors" \
  --data "config.origins=*" \
  --data "config.methods=GET,POST,PUT,DELETE,PATCH,OPTIONS" \
  --data "config.headers=Accept,Accept-Version,Content-Length,Content-MD5,Content-Type,Date,X-Auth-Token" > /dev/null
echo "✅ CORS 플러그인 설정 완료"

# 등록된 서비스 및 라우트 확인
echo "8. 등록된 서비스 및 라우트 확인 중..."
echo ""
echo "=== 등록된 서비스 목록 ==="
curl -s http://localhost:8001/services | jq -r '.data[] | "- \(.name): \(.protocol)://\(.host):\(.port)"'

echo ""
echo "=== 등록된 라우트 목록 ==="
curl -s http://localhost:8001/routes | jq -r '.data[] | "- \(.paths[0]) -> \(.service.name)"'

echo ""
echo "=== 설치된 플러그인 목록 ==="
curl -s http://localhost:8001/plugins | jq -r '.data[] | "- \(.name): \(.config | keys | join(", "))"'

# 라우트 테스트
echo ""
echo "9. 라우트 테스트 중..."
echo ""
echo "=== API Gateway 테스트 ==="

# 헬스체크 테스트
echo "헬스체크 테스트:"
for service in users products orders; do
    response=$(curl -s -w "%{http_code}" http://localhost:8000/health/$service)
    http_code="${response: -3}"
    if [ "$http_code" = "200" ]; then
        echo "✅ /health/$service: OK"
    else
        echo "❌ /health/$service: Failed ($http_code)"
    fi
done

echo ""
echo "API 엔드포인트 테스트:"
# API 테스트
for endpoint in "/api/users" "/api/products" "/api/orders"; do
    response=$(curl -s -w "%{http_code}" http://localhost:8000$endpoint)
    http_code="${response: -3}"
    if [ "$http_code" = "200" ]; then
        echo "✅ $endpoint: OK"
    else
        echo "❌ $endpoint: Failed ($http_code)"
    fi
done

echo ""
echo "=== Kong 라우트 설정 완료 ==="
echo ""
echo "사용 가능한 엔드포인트:"
echo "- 사용자 API: http://localhost:8000/api/users"
echo "- 상품 API: http://localhost:8000/api/products"
echo "- 주문 API: http://localhost:8000/api/orders"
echo "- 헬스체크: http://localhost:8000/health/{users|products|orders}"
