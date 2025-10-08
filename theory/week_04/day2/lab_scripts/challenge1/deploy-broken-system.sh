#!/bin/bash

# Challenge 1: 망가진 시스템 배포

echo "=== Challenge 1: 망가진 시스템 배포 시작 ==="
echo ""

# 클러스터 확인
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes 클러스터에 연결할 수 없습니다"
    echo ""
    echo "먼저 환경을 준비하세요:"
    echo "  ./setup-environment.sh"
    exit 1
fi

# 컨텍스트 확인
CURRENT_CONTEXT=$(kubectl config current-context)
if [[ "$CURRENT_CONTEXT" != "kind-w4d2-challenge" ]]; then
    echo "⚠️  현재 컨텍스트: $CURRENT_CONTEXT"
    echo "⚠️  w4d2-challenge 클러스터가 아닙니다"
    echo ""
    read -p "계속 진행하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Istio 설치
echo ""
echo "1. Istio 설치 중..."
if [ ! -d "istio-1.20.0" ]; then
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -
fi

cd istio-1.20.0
export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo -y

# 잘못된 NodePort 설정 (시나리오 1)
kubectl patch svc istio-ingressgateway -n istio-system --type='json' \
  -p='[{"op": "replace", "path": "/spec/ports/1/nodePort", "value": 30091}]'

kubectl label namespace default istio-injection=enabled --overwrite
kubectl wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=istio-ingressgateway -n istio-system --timeout=120s

cd ..

# 기본 서비스 배포
echo ""
echo "2. 기본 서비스 배포 중..."
kubectl apply -f - <<YAML
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
---
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
        version: v1
    spec:
      containers:
      - name: user-service
        image: hashicorp/http-echo
        args:
        - "-text=User Service v1"
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
---
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
        version: v1
    spec:
      containers:
      - name: product-service
        image: hashicorp/http-echo
        args:
        - "-text=Product Service v1"
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
---
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
        version: v1
    spec:
      containers:
      - name: order-service
        image: hashicorp/http-echo
        args:
        - "-text=Order Service v1"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
YAML

kubectl wait --for=condition=ready pod -l app=user-service --timeout=60s
kubectl wait --for=condition=ready pod -l app=product-service --timeout=60s
kubectl wait --for=condition=ready pod -l app=order-service --timeout=60s

# 망가진 설정 배포
echo ""
echo "3. 망가진 설정 배포 중..."

# 시나리오 1: Gateway
kubectl apply -f broken-gateway.yaml

# 시나리오 2: VirtualService
kubectl apply -f broken-virtualservice.yaml

# 시나리오 3: v2 Deployment & DestinationRule
kubectl apply -f broken-deployment-v2.yaml
kubectl wait --for=condition=ready pod -l app=user-service,ver=v2 --timeout=60s
kubectl apply -f broken-destinationrule.yaml

echo ""
echo "=== 망가진 시스템 배포 완료 ==="
echo ""
echo "🚨 4개 시나리오의 오류가 주입되었습니다"
echo ""
echo "Challenge 시작:"
echo "  http://localhost:9090/users"
echo "  http://localhost:9090/products"
echo "  http://localhost:9090/orders"
echo ""
echo "📋 문제 파일:"
echo "  - broken-gateway.yaml"
echo "  - broken-virtualservice.yaml"
echo "  - broken-deployment-v2.yaml"
echo "  - broken-destinationrule.yaml"
echo "  - broken-fault-injection.yaml"
echo ""
echo "💡 해결 방법: solutions.md (막힐 때만 참고)"
