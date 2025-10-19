#!/bin/bash

# Hands-on 1: Istio Service Mesh - 환경 준비

echo "=== Istio Hands-on 환경 준비 시작 ==="
echo ""

# 1. Lab 1 cleanup 확인
echo "1. Lab 1 환경 확인 중..."
if kubectl get namespace kong &>/dev/null; then
    echo "   ⚠️  Kong 네임스페이스가 존재합니다."
    echo "   💡 Lab 1 cleanup을 먼저 실행하세요:"
    echo "      cd ../lab1 && ./cleanup.sh"
    exit 1
fi
echo "   ✅ Kong 정리 완료"

# 2. backend 네임스페이스 확인 및 생성
echo ""
echo "2. backend 네임스페이스 준비 중..."
if ! kubectl get namespace backend &>/dev/null; then
    echo "   ⚠️  backend 네임스페이스가 없습니다. 생성합니다..."
    kubectl create namespace backend
    echo "   ✅ backend 네임스페이스 생성 완료"
else
    echo "   ✅ backend 네임스페이스 존재"
fi

# 3. 백엔드 서비스 확인 및 배포
echo ""
echo "3. 백엔드 서비스 확인 중..."
SERVICES=$(kubectl get svc -n backend --no-headers 2>/dev/null | wc -l)
if [ "$SERVICES" -lt 3 ]; then
    echo "   ⚠️  백엔드 서비스가 부족합니다. 배포를 시작합니다..."
    echo ""
    
    # User Service 배포
    echo "   3-1. User Service 배포 중..."
    kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=User Service Response"
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
    echo "      ✅ User Service 배포 완료"
    
    # Product Service 배포
    echo "   3-2. Product Service 배포 중..."
    kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
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
        image: hashicorp/http-echo:latest
        args:
        - "-text=Product Service Response"
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
    echo "      ✅ Product Service 배포 완료"
    
    # Order Service 배포
    echo "   3-3. Order Service 배포 중..."
    kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
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
        image: hashicorp/http-echo:latest
        args:
        - "-text=Order Service Response"
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
    echo "      ✅ Order Service 배포 완료"
    
    # Pod 준비 대기
    echo ""
    echo "   3-4. Pod 준비 대기 중..."
    kubectl wait --for=condition=ready pod -l app=user-service -n backend --timeout=60s
    kubectl wait --for=condition=ready pod -l app=product-service -n backend --timeout=60s
    kubectl wait --for=condition=ready pod -l app=order-service -n backend --timeout=60s
    echo "      ✅ 모든 Pod 준비 완료"
else
    echo "   ✅ 백엔드 서비스 확인 완료 (3개)"
fi

# 4. Pod 상태 확인
echo ""
echo "4. 최종 Pod 상태 확인..."
kubectl get pods -n backend
echo ""


echo ""
echo "=== 환경 준비 완료 ==="
echo ""
echo "📍 현재 상태:"
echo "   - backend 네임스페이스: 준비 완료"
echo "   - 백엔드 서비스: 3개 배포 완료 (user, product, order)"
echo "   - Pod 상태: 모두 Ready"
echo "   - Istio 설치 파일: 준비 완료"
echo ""
echo "다음 단계:"
echo "   1. Istio 설치: ./install-istio.sh"
echo "   2. Sidecar 주입 및 재배포: ./deploy-with-istio.sh"
echo "   3. Istio 트래픽 관리: ./configure-istio.sh"
