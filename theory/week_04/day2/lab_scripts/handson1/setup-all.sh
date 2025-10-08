#!/bin/bash

# Hands-on 1 전체 자동 설정 스크립트

echo "=== Hands-on 1 전체 자동 설정 시작 ==="
echo ""

# Step 1: Istio 설치
echo "Step 1: Istio 설치 중..."
if [ ! -d "istio-1.20.0" ]; then
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -
fi

cd istio-1.20.0
export PATH=$PWD/bin:$PATH

istioctl install --set profile=demo -y

# Ingress Gateway NodePort 설정
kubectl patch svc istio-ingressgateway -n istio-system --type='json' \
  -p='[{"op": "replace", "path": "/spec/ports/1/nodePort", "value": 30080}]'

# Sidecar Injection 활성화
kubectl label namespace default istio-injection=enabled --overwrite

# Istio 준비 대기
kubectl wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=istio-ingressgateway -n istio-system --timeout=120s

cd ..
echo "   ✅ Istio 설치 완료"

# Step 2: 기본 서비스 배포 (v1)
echo ""
echo "Step 2: 기본 서비스 배포 중..."
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

echo "   ✅ 기본 서비스 배포 완료"

# Step 3: Gateway 설정
echo ""
echo "Step 3: Gateway 설정 중..."
kubectl apply -f - <<YAML
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: api-gateway
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

echo "   ✅ Gateway 설정 완료"

# Step 4: v2 서비스 배포
echo ""
echo "Step 4: User Service v2 배포 중..."
kubectl apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service-v2
spec:
  replicas: 2
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
        image: hashicorp/http-echo
        args:
        - "-text=User Service v2 🚀"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
YAML

kubectl wait --for=condition=ready pod -l app=user-service,version=v2 --timeout=60s
echo "   ✅ v2 배포 완료"

# Step 5: Traffic Splitting 설정
echo ""
echo "Step 5: Traffic Splitting 설정 중..."
kubectl apply -f - <<YAML
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: user-service
spec:
  host: user-service
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
---
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
        subset: v1
      weight: 90
    - destination:
        host: user-service
        subset: v2
      weight: 10
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

echo "   ✅ Traffic Splitting 설정 완료"

# Step 6: Fault Injection 설정
echo ""
echo "Step 6: Fault Injection 설정 중..."
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
        subset: v1
      weight: 90
    - destination:
        host: user-service
        subset: v2
      weight: 10
  - match:
    - uri:
        prefix: /products
    fault:
      delay:
        percentage:
          value: 50
        fixedDelay: 3s
      abort:
        percentage:
          value: 20
        httpStatus: 503
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

echo "   ✅ Fault Injection 설정 완료"

echo ""
echo "=== 전체 설정 완료 ==="
echo ""
echo "테스트:"
echo "  curl http://localhost:8080/users"
echo "  curl http://localhost:8080/products"
echo ""
echo "브라우저:"
echo "  http://localhost:8080/users (새로고침 10번)"
echo "  http://localhost:8080/products (느린 응답/오류 확인)"

echo ""
echo "💡 중요: 포트 8080을 사용하세요!"
echo ""
echo "올바른 테스트:"
echo "  curl http://localhost:8080/users"
echo "  curl http://localhost:8080/products"
echo ""
echo "브라우저:"
echo "  http://localhost:8080/users (새로고침 10번)"
echo "  http://localhost:8080/products (느린 응답/오류 확인)"
