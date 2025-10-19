#!/bin/bash

# Lab 1: Kong API Gateway - Kong Service & Route 설정

echo "=== Kong Service & Route 설정 시작 ==="
echo ""

# 1. User Service 등록
echo "1. User Service 등록 중..."
curl -s -X POST http://localhost:8001/services \
  --data name=user-service \
  --data url='http://user-service.default.svc.cluster.local:80' > /dev/null
echo "   ✅ User Service 등록 완료"

# User Route 생성
echo "   User Route 생성 중..."
curl -s -X POST http://localhost:8001/services/user-service/routes \
  --data 'paths[]=/users' \
  --data name=user-route > /dev/null
echo "   ✅ User Route 생성 완료"

# 2. Product Service 등록
echo ""
echo "2. Product Service 등록 중..."
curl -s -X POST http://localhost:8001/services \
  --data name=product-service \
  --data url='http://product-service.default.svc.cluster.local:80' > /dev/null
echo "   ✅ Product Service 등록 완료"

# Product Route 생성
echo "   Product Route 생성 중..."
curl -s -X POST http://localhost:8001/services/product-service/routes \
  --data 'paths[]=/products' \
  --data name=product-route > /dev/null
echo "   ✅ Product Route 생성 완료"

# 3. Order Service 등록
echo ""
echo "3. Order Service 등록 중..."
curl -s -X POST http://localhost:8001/services \
  --data name=order-service \
  --data url='http://order-service.default.svc.cluster.local:80' > /dev/null
echo "   ✅ Order Service 등록 완료"

# Order Route 생성
echo "   Order Route 생성 중..."
curl -s -X POST http://localhost:8001/services/order-service/routes \
  --data 'paths[]=/orders' \
  --data name=order-route > /dev/null
echo "   ✅ Order Route 생성 완료"

# 4. 설정 확인
echo ""
echo "4. Kong 설정 확인 중..."
echo ""
echo "📋 등록된 Services:"
curl -s http://localhost:8001/services | jq -r '.data[] | "   - \(.name): \(.url)"'

echo ""
echo "📋 등록된 Routes:"
curl -s http://localhost:8001/routes | jq -r '.data[] | "   - \(.name): \(.paths[])"'

# 5. 라우팅 테스트
echo ""
echo "5. 라우팅 테스트 중..."
echo ""
echo "🧪 User Service 테스트:"
curl -s http://localhost:8000/users
echo ""

echo "🧪 Product Service 테스트:"
curl -s http://localhost:8000/products
echo ""

echo "🧪 Order Service 테스트:"
curl -s http://localhost:8000/orders
echo ""

echo ""
echo "=== Kong Service & Route 설정 완료 ==="
echo ""
echo "📍 테스트 URL:"
echo "   - User Service: http://localhost:8000/users"
echo "   - Product Service: http://localhost:8000/products"
echo "   - Order Service: http://localhost:8000/orders"
echo ""
echo "다음 단계: 플러그인 적용 (Lab 문서 Step 5 참조)"
