#!/bin/bash

# Step 4: Istio Gateway & VirtualService 설정

echo "=== Step 4: Istio Gateway & VirtualService 설정 시작 ==="
echo ""

# Istio Gateway 생성
echo "1. Istio Gateway 생성 중..."
cat <<YAML | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: api-gateway
  namespace: default
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
YAML

sleep 2

# VirtualService 생성 (라우팅 규칙)
echo ""
echo "2. VirtualService 생성 중..."
cat <<YAML | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: api-routes
  namespace: default
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

# DestinationRule 생성 (로드밸런싱)
echo ""
echo "3. DestinationRule 생성 중..."
cat <<YAML | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: user-service
  namespace: default
spec:
  host: user-service
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: product-service
  namespace: default
spec:
  host: product-service
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: order-service
  namespace: default
spec:
  host: order-service
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
YAML

# 설정 확인 (Istio 리소스)
echo ""
echo "4. 설정 확인..."
kubectl get gateway.networking.istio.io
echo ""
kubectl get virtualservice
echo ""
kubectl get destinationrule

echo ""
echo "=== Step 4: Istio Gateway & VirtualService 설정 완료 ==="
