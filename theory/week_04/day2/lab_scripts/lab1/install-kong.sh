#!/bin/bash

# Lab 1: Kong API Gateway - Kong 설치

echo "=== Kong API Gateway 설치 시작 ==="
echo ""

# 1. Kong 네임스페이스 생성
echo "1. Kong 네임스페이스 생성 중..."
kubectl create namespace kong --dry-run=client -o yaml | kubectl apply -f -
echo "   ✅ 네임스페이스 생성 완료"

# 2. Kong Gateway 배포 (DB-less 모드)
echo ""
echo "2. Kong Gateway 배포 중..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: kong-proxy
  namespace: kong
spec:
  type: NodePort
  ports:
  - name: proxy
    port: 80
    targetPort: 8000
    nodePort: 30080
  - name: proxy-ssl
    port: 443
    targetPort: 8443
  selector:
    app: kong
---
apiVersion: v1
kind: Service
metadata:
  name: kong-admin
  namespace: kong
spec:
  type: NodePort
  ports:
  - name: admin
    port: 8001
    targetPort: 8001
    nodePort: 30081
  selector:
    app: kong
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kong
  namespace: kong
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kong
  template:
    metadata:
      labels:
        app: kong
    spec:
      containers:
      - name: kong
        image: kong:3.4
        env:
        - name: KONG_DATABASE
          value: "off"
        - name: KONG_PROXY_ACCESS_LOG
          value: "/dev/stdout"
        - name: KONG_ADMIN_ACCESS_LOG
          value: "/dev/stdout"
        - name: KONG_PROXY_ERROR_LOG
          value: "/dev/stderr"
        - name: KONG_ADMIN_ERROR_LOG
          value: "/dev/stderr"
        - name: KONG_ADMIN_LISTEN
          value: "0.0.0.0:8001"
        ports:
        - containerPort: 8000
          name: proxy
        - containerPort: 8443
          name: proxy-ssl
        - containerPort: 8001
          name: admin
        livenessProbe:
          httpGet:
            path: /status
            port: 8001
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /status
            port: 8001
          initialDelaySeconds: 10
          periodSeconds: 5
EOF

echo "   ✅ Kong 배포 완료"

# 3. Kong Pod 준비 대기
echo ""
echo "3. Kong Pod 준비 대기 중..."
kubectl wait --for=condition=ready pod -l app=kong -n kong --timeout=120s

# 4. Kong 상태 확인
echo ""
echo "4. Kong 상태 확인 중..."
kubectl get pods -n kong
echo ""
kubectl get svc -n kong

# 5. Kong Admin API 테스트
echo ""
echo "5. Kong Admin API 테스트 중..."
sleep 5
curl -s http://localhost:8001 | head -n 5

echo ""
echo "=== Kong 설치 완료 ==="
echo ""
echo "📍 접속 정보:"
echo "   - Kong Proxy: http://localhost:8000"
echo "   - Kong Admin API: http://localhost:8001"
echo ""
echo "다음 단계: ./deploy-services.sh"
