#!/bin/bash

# Hands-on 1 정리 스크립트

echo "=== Hands-on 1 정리 시작 ==="
echo ""

# v2 서비스 삭제
echo "1. User Service v2 삭제 중..."
kubectl delete deployment user-service-v2

# VirtualService를 Lab 1 상태로 복원
echo ""
echo "2. VirtualService 복원 중..."
kubectl apply -f - <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: api-routes
spec:
  hosts:
  - "*"
  gateways:
  - api-gateway
  http:
  - match:
    - uri:
        prefix: /users
    route:
    - destination:
        host: user-service
        port:
          number: 80
  - match:
    - uri:
        prefix: /products
    route:
    - destination:
        host: product-service
        port:
          number: 80
  - match:
    - uri:
        prefix: /orders
    route:
    - destination:
        host: order-service
        port:
          number: 80
YAML

# DestinationRule 복원
echo ""
echo "3. DestinationRule 복원 중..."
kubectl apply -f - <<YAML
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: user-service
spec:
  host: user-service
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
YAML

echo ""
echo "=== 정리 완료 ==="
echo ""
echo "Lab 1 상태로 복원되었습니다"
echo "테스트: curl http://localhost/users"
