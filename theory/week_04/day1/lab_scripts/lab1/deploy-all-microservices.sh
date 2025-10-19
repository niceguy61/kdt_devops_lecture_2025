#!/bin/bash

# Week 4 Day 1 Lab 1: 완전한 마이크로서비스 아키텍처 배포
# 사용법: ./deploy-all-microservices.sh

echo "=== 완전한 마이크로서비스 아키텍처 배포 시작 ==="
echo ""

set -e
trap 'echo "❌ 스크립트 실행 중 오류 발생"' ERR

echo "1/3 상품 서비스 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
  namespace: ecommerce
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product-service
  template:
    metadata:
      labels:
        app: product-service
    spec:
      containers:
      - name: product-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        env:
        - name: SERVICE_NAME
          value: product-service
---
apiVersion: v1
kind: Service
metadata:
  name: product-service
  namespace: ecommerce
spec:
  selector:
    app: product-service
  ports:
  - port: 80
    targetPort: 80
EOF

echo "2/3 주문 서비스 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  namespace: ecommerce
spec:
  replicas: 2
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
      - name: order-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        env:
        - name: SERVICE_NAME
          value: order-service
---
apiVersion: v1
kind: Service
metadata:
  name: order-service
  namespace: ecommerce
spec:
  selector:
    app: order-service
  ports:
  - port: 80
    targetPort: 80
EOF

echo "3/3 완전한 마이크로서비스 Ingress 설정 중..."
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-microservices-ingress
  namespace: ecommerce
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: ecommerce.local
    http:
      paths:
      - path: /api/users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 80
      - path: /api/products
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 80
      - path: /api/orders
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: user-service  # 기본 라우팅
            port:
              number: 80
EOF

# 기존 하이브리드 Ingress 삭제 (있는 경우에만)
kubectl delete ingress ecommerce-hybrid-ingress -n ecommerce --ignore-not-found=true

# 모놀리스 애플리케이션 스케일 다운 (완전 제거하지 않고 보존)
kubectl scale deployment ecommerce-monolith --replicas=0 -n ecommerce

echo "배포 상태 확인 중..."
kubectl wait --for=condition=ready pod -l app=product-service -n ecommerce --timeout=60s
kubectl wait --for=condition=ready pod -l app=order-service -n ecommerce --timeout=60s

echo ""
echo "=== 완전한 마이크로서비스 아키텍처 배포 완료 ==="
echo ""
echo "배포된 마이크로서비스:"
echo "- 사용자 서비스: user-service (2 replicas)"
echo "- 상품 서비스: product-service (2 replicas)"
echo "- 주문 서비스: order-service (2 replicas)"
echo "- 모놀리스: 스케일 다운됨 (0 replicas)"
echo ""
echo "라우팅 규칙:"
echo "- /api/users → user-service"
echo "- /api/products → product-service"
echo "- /api/orders → order-service"
echo "- / → user-service (기본)"
echo ""
echo "상태 확인:"
kubectl get pods -n ecommerce
echo ""
echo "서비스 확인:"
kubectl get svc -n ecommerce
echo ""
echo "✅ 완전한 마이크로서비스 아키텍처 배포 성공!"
