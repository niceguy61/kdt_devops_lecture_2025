#!/bin/bash

# Week 4 Day 2 Lab 1: Kong 라우트 설정 (최종 완성 버전)
# 사용법: ./configure-kong-routes.sh

echo "=== Kong 라우트 설정 시작 ==="

# Kong 상태 확인
echo "1. Kong Gateway 상태 확인 중..."
if ! curl -s http://localhost:8001/ > /dev/null; then
    echo "❌ Kong Gateway가 실행되지 않았습니다"
    echo "먼저 ./setup-kong.sh를 실행하세요"
    exit 1
fi

# 기존 라우트 및 서비스 정리
echo "2. 기존 설정 정리 중..."
for route_id in $(curl -s http://localhost:8001/routes | jq -r '.data[]?.id // empty'); do
    curl -s -X DELETE http://localhost:8001/routes/$route_id > /dev/null
done

for service_id in $(curl -s http://localhost:8001/services | jq -r '.data[]?.id // empty'); do
    curl -s -X DELETE http://localhost:8001/services/$service_id > /dev/null
done

echo "✅ 기존 설정 정리 완료"

# User Service 등록 및 라우트 설정
echo "3. User Service 등록 중..."
USER_SERVICE_ID=$(curl -s -X POST http://localhost:8001/services/ \
  --data "name=user-service" \
  --data "url=http://user-service:3001" | jq -r '.id')

if [ "$USER_SERVICE_ID" != "null" ]; then
    echo "✅ User Service 등록 완료"
    
    # 직접 경로: /users, /health
    curl -s -X POST http://localhost:8001/services/$USER_SERVICE_ID/routes \
      --data "paths[]=/users" \
      --data "strip_path=false" > /dev/null
    
    curl -s -X POST http://localhost:8001/services/$USER_SERVICE_ID/routes \
      --data "paths[]=/health" \
      --data "strip_path=false" > /dev/null
    
    # API 경로: /api/users -> /users (Request Transformer 사용)
    USER_API_ROUTE_ID=$(curl -s -X POST http://localhost:8001/services/$USER_SERVICE_ID/routes \
      --data "name=api-users" \
      --data "paths[]=/api/users" \
      --data "strip_path=false" | jq -r '.id')
    
    curl -s -X POST http://localhost:8001/routes/$USER_API_ROUTE_ID/plugins \
      --data "name=request-transformer" \
      --data "config.replace.uri=/users" > /dev/null
    
    echo "✅ User Service 라우트 생성 완료"
fi

# Product Service 등록 및 라우트 설정
echo "4. Product Service 등록 중..."
PRODUCT_SERVICE_ID=$(curl -s -X POST http://localhost:8001/services/ \
  --data "name=product-service" \
  --data "url=http://product-service:3002" | jq -r '.id')

if [ "$PRODUCT_SERVICE_ID" != "null" ]; then
    echo "✅ Product Service 등록 완료"
    
    # 직접 경로: /products
    curl -s -X POST http://localhost:8001/services/$PRODUCT_SERVICE_ID/routes \
      --data "paths[]=/products" \
      --data "strip_path=false" > /dev/null
    
    # API 경로: /api/products -> /products
    PRODUCT_API_ROUTE_ID=$(curl -s -X POST http://localhost:8001/services/$PRODUCT_SERVICE_ID/routes \
      --data "name=api-products" \
      --data "paths[]=/api/products" \
      --data "strip_path=false" | jq -r '.id')
    
    curl -s -X POST http://localhost:8001/routes/$PRODUCT_API_ROUTE_ID/plugins \
      --data "name=request-transformer" \
      --data "config.replace.uri=/products" > /dev/null
    
    echo "✅ Product Service 라우트 생성 완료"
fi

# Order Service 등록 및 라우트 설정
echo "5. Order Service 등록 중..."
ORDER_SERVICE_ID=$(curl -s -X POST http://localhost:8001/services/ \
  --data "name=order-service" \
  --data "url=http://order-service:3003" | jq -r '.id')

if [ "$ORDER_SERVICE_ID" != "null" ]; then
    echo "✅ Order Service 등록 완료"
    
    # 직접 경로: /orders
    curl -s -X POST http://localhost:8001/services/$ORDER_SERVICE_ID/routes \
      --data "paths[]=/orders" \
      --data "strip_path=false" > /dev/null
    
    # API 경로: /api/orders -> /orders
    ORDER_API_ROUTE_ID=$(curl -s -X POST http://localhost:8001/services/$ORDER_SERVICE_ID/routes \
      --data "name=api-orders" \
      --data "paths[]=/api/orders" \
      --data "strip_path=false" | jq -r '.id')
    
    curl -s -X POST http://localhost:8001/routes/$ORDER_API_ROUTE_ID/plugins \
      --data "name=request-transformer" \
      --data "config.replace.uri=/orders" > /dev/null
    
    echo "✅ Order Service 라우트 생성 완료"
fi

# Rate Limiting 플러그인 추가 (전역)
echo "6. Rate Limiting 플러그인 설정 중..."
curl -s -X POST http://localhost:8001/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=100" \
  --data "config.hour=1000" > /dev/null
echo "✅ Rate Limiting 설정 완료 (분당 100회, 시간당 1000회)"

# CORS 플러그인 추가 (전역)
echo "7. CORS 플러그인 설정 중..."
curl -s -X POST http://localhost:8001/plugins \
  --data "name=cors" \
  --data "config.origins=*" \
  --data "config.methods=GET,POST,PUT,DELETE,PATCH,OPTIONS" \
  --data "config.headers=Accept,Accept-Version,Content-Length,Content-MD5,Content-Type,Date,X-Auth-Token" > /dev/null
echo "✅ CORS 플러그인 설정 완료"

# Kong 설정 적용 대기
echo "8. Kong 설정 적용 대기 중..."
sleep 5

# 최종 테스트
echo "9. API Gateway 최종 테스트 중..."
echo ""
echo "=========================================="
echo "🎉 Kong API Gateway 완전 테스트"
echo "=========================================="

# 헬스체크
echo -e "\n1. 헬스체크:"
response=$(curl -s -w "%{http_code}" -o /tmp/test.txt http://localhost:8000/health)
if [ "$response" = "200" ]; then
    service_name=$(cat /tmp/test.txt | jq -r '.service // "unknown"')
    echo "✅ /health: OK ($service_name)"
else
    echo "❌ /health: Failed ($response)"
fi

# 직접 경로 테스트
echo -e "\n2. 직접 경로:"
for endpoint in "/users" "/products" "/orders"; do
    response=$(curl -s -w "%{http_code}" -o /tmp/test.txt http://localhost:8000$endpoint)
    if [ "$response" = "200" ]; then
        count=$(cat /tmp/test.txt | jq '. | length' 2>/dev/null || echo "N/A")
        echo "✅ $endpoint: OK ($count개 항목)"
    else
        echo "❌ $endpoint: Failed ($response)"
    fi
done

# API 경로 테스트
echo -e "\n3. API 경로:"
for endpoint in "/api/users" "/api/products" "/api/orders"; do
    response=$(curl -s -w "%{http_code}" -o /tmp/test.txt http://localhost:8000$endpoint)
    if [ "$response" = "200" ]; then
        count=$(cat /tmp/test.txt | jq '. | length' 2>/dev/null || echo "N/A")
        name=$(cat /tmp/test.txt | jq -r '.[0].name // .[0].id // "항목"' 2>/dev/null || echo "데이터")
        echo "✅ $endpoint: OK ($count개 항목, 첫 번째: $name)"
    else
        echo "❌ $endpoint: Failed ($response)"
    fi
done

# 서비스 간 통신 테스트
echo -e "\n4. 서비스 간 통신:"
response=$(curl -s -w "%{http_code}" -o /tmp/test.txt http://localhost:8000/orders/1/details)
if [ "$response" = "200" ]; then
    user_name=$(cat /tmp/test.txt | jq -r '.user.name // "사용자"' 2>/dev/null)
    product_name=$(cat /tmp/test.txt | jq -r '.product.name // "상품"' 2>/dev/null)
    quantity=$(cat /tmp/test.txt | jq -r '.quantity // "N"' 2>/dev/null)
    echo "✅ 주문 상세: OK ($user_name님이 $product_name $quantity개 주문)"
else
    echo "❌ 주문 상세: Failed ($response)"
fi

echo ""
echo "=========================================="
echo "🚀 Kong API Gateway 설정 완료!"
echo "=========================================="
echo ""
echo "✅ 사용 가능한 엔드포인트:"
echo "📍 헬스체크:"
echo "  - http://localhost:8000/health"
echo ""
echo "📍 직접 경로:"
echo "  - http://localhost:8000/users"
echo "  - http://localhost:8000/products"
echo "  - http://localhost:8000/orders"
echo "  - http://localhost:8000/orders/1/details"
echo ""
echo "📍 API 경로:"
echo "  - http://localhost:8000/api/users"
echo "  - http://localhost:8000/api/products"
echo "  - http://localhost:8000/api/orders"
echo ""
echo "🔧 관리 인터페이스:"
echo "  - Kong Admin API: http://localhost:8001"
echo "  - Kong Manager: http://localhost:8002"
echo "  - Consul UI: http://localhost:8500/ui"
echo ""
echo "🛡️ 적용된 플러그인:"
echo "  - Rate Limiting: 분당 100회, 시간당 1000회"
echo "  - CORS: 모든 도메인 허용"
echo "  - Request Transformer: /api/* -> /* 경로 변환"

# 임시 파일 정리
rm -f /tmp/test.txt
