#!/bin/bash

# Step 5: 통합 테스트

echo "=== Step 5: 통합 테스트 시작 ==="
echo ""

# Gateway URL 설정
export GATEWAY_URL="localhost"

echo "Gateway URL: http://$GATEWAY_URL"
echo ""

# 서비스별 테스트
echo "1. User Service 테스트..."
echo "   요청: curl http://$GATEWAY_URL/users"
curl -s http://$GATEWAY_URL/users
echo ""
echo ""

echo "2. Product Service 테스트..."
echo "   요청: curl http://$GATEWAY_URL/products"
curl -s http://$GATEWAY_URL/products
echo ""
echo ""

echo "3. Order Service 테스트..."
echo "   요청: curl http://$GATEWAY_URL/orders"
curl -s http://$GATEWAY_URL/orders
echo ""
echo ""

# 로드밸런싱 테스트
echo "4. 로드밸런싱 테스트 (User Service 10회 호출)..."
for i in {1..10}; do
    echo -n "   요청 $i: "
    curl -s http://$GATEWAY_URL/users
done
echo ""

# Istio 설정 확인
echo ""
echo "5. Istio 설정 확인..."
echo ""
echo "Gateway:"
kubectl get gateway.networking.istio.io
echo ""
echo "VirtualService:"
kubectl get virtualservice
echo ""
echo "DestinationRule:"
kubectl get destinationrule

echo ""
echo "=== Step 5: 통합 테스트 완료 ==="
echo ""
echo "💡 브라우저 테스트:"
echo "   http://localhost/users"
echo "   http://localhost/products"
echo "   http://localhost/orders"
