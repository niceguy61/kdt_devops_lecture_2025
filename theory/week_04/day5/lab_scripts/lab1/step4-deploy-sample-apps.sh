#!/bin/bash

# Week 4 Day 5 Lab 1: 샘플 애플리케이션 배포
# 설명: 비용 추적을 위한 3개 네임스페이스에 샘플 앱 배포

set -e

echo "=== 샘플 애플리케이션 배포 시작 ==="

# 1. 네임스페이스 생성 및 라벨 추가
echo "1/4 네임스페이스 생성 중..."
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace development --dry-run=client -o yaml | kubectl apply -f -

kubectl label namespace production team=frontend cost-center=CC-1001 --overwrite
kubectl label namespace staging team=qa cost-center=CC-1002 --overwrite
kubectl label namespace development team=dev cost-center=CC-1003 --overwrite

# 2. Production 애플리케이션 배포 (높은 리소스)
echo "2/4 Production 애플리케이션 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
EOF

# 3. Staging 애플리케이션 배포 (중간 리소스)
echo "3/4 Staging 애플리케이션 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: staging
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
        tier: backend
    spec:
      containers:
      - name: api
        image: nginx:alpine
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 300m
            memory: 256Mi
EOF

# 4. Development 애플리케이션 배포 (낮은 리소스)
echo "4/4 Development 애플리케이션 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dev-service
  namespace: development
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dev
  template:
    metadata:
      labels:
        app: dev
        tier: backend
    spec:
      containers:
      - name: dev
        image: nginx:alpine
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
EOF

# 배포 완료 대기
echo ""
echo "배포 완료 대기 중..."
kubectl wait --for=condition=ready pod -l app=web -n production --timeout=300s
kubectl wait --for=condition=ready pod -l app=api -n staging --timeout=300s
kubectl wait --for=condition=ready pod -l app=dev -n development --timeout=300s

echo ""
echo "=== 샘플 애플리케이션 배포 완료 ==="
echo ""
echo "배포된 애플리케이션:"
echo "- Production: web-app (3 replicas, 높은 리소스)"
echo "- Staging: api-server (2 replicas, 중간 리소스)"
echo "- Development: dev-service (1 replica, 낮은 리소스)"
echo ""
echo "비용 추적 라벨:"
echo "- Production: team=frontend, cost-center=CC-1001"
echo "- Staging: team=qa, cost-center=CC-1002"
echo "- Development: team=dev, cost-center=CC-1003"
echo ""
echo "✅ 모든 작업이 성공적으로 완료되었습니다."
