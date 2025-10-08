#!/bin/bash

# Step 4: 마이크로서비스 배포

echo "=== Step 4: 마이크로서비스 배포 시작 ==="
echo ""

# User Service 배포
echo "1. User Service 배포 중..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
      version: v1
  template:
    metadata:
      labels:
        app: user-service
        version: v1
    spec:
      containers:
      - name: user-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=User Service v1"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 8080
EOF

# Product Service 배포
echo ""
echo "2. Product Service 배포 중..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product-service
      version: v1
  template:
    metadata:
      labels:
        app: product-service
        version: v1
    spec:
      containers:
      - name: product-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=Product Service v1"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: product-service
spec:
  selector:
    app: product-service
  ports:
  - port: 80
    targetPort: 8080
EOF

# Order Service 배포
echo ""
echo "3. Order Service 배포 중..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: order-service
      version: v1
  template:
    metadata:
      labels:
        app: order-service
        version: v1
    spec:
      containers:
      - name: order-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=Order Service v1"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  selector:
    app: order-service
  ports:
  - port: 80
    targetPort: 8080
EOF

# Pod 시작 대기
echo ""
echo "4. Pod 시작 대기 중..."
kubectl wait --for=condition=ready pod -l app=user-service --timeout=60s
kubectl wait --for=condition=ready pod -l app=product-service --timeout=60s
kubectl wait --for=condition=ready pod -l app=order-service --timeout=60s

# 배포 확인
echo ""
echo "5. 배포 확인..."
kubectl get deployments
echo ""
kubectl get pods
echo ""
kubectl get svc

echo ""
echo "=== Step 4: 마이크로서비스 배포 완료 ==="
