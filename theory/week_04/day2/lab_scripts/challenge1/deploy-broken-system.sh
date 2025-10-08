#!/bin/bash

# Challenge 1: 망가진 시스템 배포

echo "=== Challenge 1: 망가진 시스템 배포 시작 ==="
echo ""

# 1. 기존 클러스터 삭제
echo "1. 기존 클러스터 정리 중..."
kind delete cluster --name w4d2-challenge 2>/dev/null || true

# 2. 새 클러스터 생성 (포트 9090)
echo ""
echo "2. Challenge 클러스터 생성 중 (포트 9090)..."
cat <<YAML | kind create cluster --name w4d2-challenge --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30090
    hostPort: 9090
    protocol: TCP
YAML

kubectl config use-context kind-w4d2-challenge
kubectl wait --for=condition=ready node --all --timeout=60s

# 3. Istio 설치
echo ""
echo "3. Istio 설치 중..."
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

# 4. 기본 서비스 배포
echo ""
echo "4. 기본 서비스 배포 중..."
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

# 5. 망가진 설정 배포
echo ""
echo "5. 망가진 설정 배포 중..."

# 시나리오 1: Gateway
kubectl apply -f broken-gateway.yaml

# 시나리오 2: VirtualService
kubectl apply -f broken-virtualservice.yaml

# 시나리오 3: v2 Deployment & DestinationRule
kubectl apply -f broken-deployment-v2.yaml
kubectl wait --for=condition=ready pod -l app=user-service,ver=v2 --timeout=60s
kubectl apply -f broken-destinationrule.yaml

# 시나리오 4는 별도 (Fault Injection은 나중에 수동으로 적용)

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
