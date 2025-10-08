#!/bin/bash

# Step 6: 통합 테스트

echo "=== Step 6: 통합 테스트 시작 ==="
echo ""

# Port-forward 설정
echo "1. Port-forward 설정 중..."
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80 > /dev/null 2>&1 &
PF_PID=$!
sleep 3

# 기본 라우팅 테스트
echo ""
echo "2. 기본 라우팅 테스트..."
echo ""
echo "User Service:"
curl -s -H "Host: api.example.com" http://localhost:8080/users
echo ""
echo ""
echo "Product Service:"
curl -s -H "Host: api.example.com" http://localhost:8080/products
echo ""
echo ""
echo "Order Service:"
curl -s -H "Host: api.example.com" http://localhost:8080/orders
echo ""

# 로드밸런싱 테스트
echo ""
echo "3. 로드밸런싱 테스트 (10회 요청)..."
for i in {1..10}; do
  echo "Request $i:"
  curl -s -H "Host: api.example.com" http://localhost:8080/users
done

# Istio Proxy 상태 확인
echo ""
echo ""
echo "4. Istio Proxy 상태 확인..."
istioctl proxy-status

# Port-forward 종료
kill $PF_PID 2>/dev/null

echo ""
echo "=== Step 6: 통합 테스트 완료 ==="
echo ""
echo "💡 Port-forward를 계속 사용하려면:"
echo "   kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80"
