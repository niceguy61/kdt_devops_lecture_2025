#!/bin/bash

# Week 4 Day 5 Lab 1: 샘플 애플리케이션 배포
# 설명: 관측성 스택 테스트를 위한 샘플 앱 배포

set -e

echo "=== 샘플 애플리케이션 배포 시작 ==="

# 1. 네임스페이스 생성
echo "1/3 demo 네임스페이스 생성 중..."
kubectl create namespace demo --dry-run=client -o yaml | kubectl apply -f -

# 2. 샘플 애플리케이션 배포
echo "2/3 샘플 애플리케이션 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: demo
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30082
EOF

# 3. 배포 확인
echo "3/3 배포 상태 확인 중..."
kubectl wait --for=condition=ready pod -l app=web -n demo --timeout=300s
kubectl get pods -n demo

echo ""
echo "=== 샘플 애플리케이션 배포 완료 ==="
echo ""
echo "배포된 리소스:"
echo "- Deployment: web-app (3 replicas)"
echo "- Service: web-service (NodePort 30082)"
echo ""
echo "애플리케이션 접속:"
echo "- URL: http://localhost:30082"
echo ""
echo "테스트 명령어:"
echo "  curl http://localhost:30082"
echo ""
echo "✅ 모든 작업이 성공적으로 완료되었습니다."
