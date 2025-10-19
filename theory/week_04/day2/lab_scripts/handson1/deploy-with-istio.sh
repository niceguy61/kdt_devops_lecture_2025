#!/bin/bash

# Hands-on 1: Istio Service Mesh - Sidecar 주입된 애플리케이션 배포

echo "=== Sidecar 주입된 애플리케이션 배포 시작 ==="
echo ""

# 0. backend 네임스페이스에 Sidecar 주입 활성화
echo "0. backend 네임스페이스 Sidecar 주입 활성화 중..."
kubectl label namespace backend istio-injection=enabled --overwrite
echo "   ✅ backend 네임스페이스 Sidecar 주입 활성화"

# 1. 기존 Deployment 삭제 (selector 변경을 위해)
echo ""
echo "1. 기존 Deployment 삭제 중..."
kubectl delete deployment user-service product-service order-service -n backend
echo "   ✅ 기존 Deployment 삭제 완료"

# 2. User Service v1 재배포 (version 라벨 포함)
echo ""
echo "2. User Service v1 재배포 중 (version 라벨 포함)..."
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service-v1
  labels:
    app: user-service
    version: v1
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
        - "-text=User Service v1 Response"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
EOF
echo "   ✅ User Service v1 재배포 완료"

# 3. User Service v2 배포 (카나리용)
echo ""
echo "3. User Service v2 배포 중 (카나리용)..."
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service-v2
  labels:
    app: user-service
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: user-service
      version: v2
  template:
    metadata:
      labels:
        app: user-service
        version: v2
    spec:
      containers:
      - name: user-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=User Service v2 Response (NEW)"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
EOF
echo "   ✅ User Service v2 배포 완료"

# 4. Product Service 재배포 (version 라벨 포함)
echo ""
echo "4. Product Service 재배포 중 (version 라벨 포함)..."
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
  labels:
    app: product-service
    version: v1
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
        - "-text=Product Service Response"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
EOF
echo "   ✅ Product Service 재배포 완료"

# 5. Order Service 재배포 (version 라벨 포함)
echo ""
echo "5. Order Service 재배포 중 (version 라벨 포함)..."
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  labels:
    app: order-service
    version: v1
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
        - "-text=Order Service Response"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
EOF
echo "   ✅ Order Service 재배포 완료"

# 6. Pod 준비 대기
echo ""
echo "6. Pod 준비 대기 중..."
kubectl wait --for=condition=ready pod -l app=user-service -n backend --timeout=120s
kubectl wait --for=condition=ready pod -l app=product-service -n backend --timeout=120s
kubectl wait --for=condition=ready pod -l app=order-service -n backend --timeout=120s
echo "   ✅ 모든 Pod 준비 완료"

# 7. Sidecar 주입 확인
echo ""
echo "7. Sidecar 주입 확인 중..."
echo ""
kubectl get pods -n backend

echo ""
echo "=== 애플리케이션 배포 완료 ==="
echo ""
echo "📍 배포된 서비스 (backend 네임스페이스):"
echo "   - user-service v1 (2 replicas) + Envoy Sidecar"
echo "   - user-service v2 (1 replica) + Envoy Sidecar"
echo "   - product-service v1 (2 replicas) + Envoy Sidecar"
echo "   - order-service v1 (2 replicas) + Envoy Sidecar"
echo ""
echo "💡 각 Pod는 2개 컨테이너를 가집니다:"
echo "   - 애플리케이션 컨테이너"
echo "   - istio-proxy (Envoy Sidecar)"
echo ""
echo "다음 단계: ./configure-istio.sh"
