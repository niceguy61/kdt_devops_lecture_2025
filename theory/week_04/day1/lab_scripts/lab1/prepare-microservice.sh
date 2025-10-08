#!/bin/bash

# Week 4 Day 1 Lab 1: 마이크로서비스 준비
# 사용법: ./prepare-microservice.sh <service-name>

SERVICE_NAME=${1:-user-service}

echo "=== 마이크로서비스 준비: $SERVICE_NAME ==="
echo ""

set -e

echo "1/3 마이크로서비스용 데이터베이스 배포 중..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${SERVICE_NAME}-db
  namespace: ecommerce-microservices
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${SERVICE_NAME}-db
  template:
    metadata:
      labels:
        app: ${SERVICE_NAME}-db
    spec:
      containers:
      - name: postgres
        image: postgres:16
        env:
        - name: POSTGRES_DB
          value: ${SERVICE_NAME}
        - name: POSTGRES_USER
          value: admin
        - name: POSTGRES_PASSWORD
          value: password123
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}-db
  namespace: ecommerce-microservices
spec:
  selector:
    app: ${SERVICE_NAME}-db
  ports:
  - port: 5432
    targetPort: 5432
EOF

echo "✅ $SERVICE_NAME 데이터베이스 배포 완료"

echo ""
echo "2/3 마이크로서비스 설정 준비 중..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${SERVICE_NAME}-config
  namespace: ecommerce-microservices
data:
  default.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location /api/users {
            return 200 '{"service": "user-microservice", "endpoint": "users", "response_time": "3ms", "db": "dedicated"}';
            add_header Content-Type application/json;
        }
        
        location /health {
            return 200 '{"service": "user-microservice", "status": "healthy"}';
            add_header Content-Type application/json;
        }
        
        location / {
            return 200 '{"service": "user-microservice", "status": "running", "architecture": "microservice"}';
            add_header Content-Type application/json;
        }
    }
EOF

echo "✅ 마이크로서비스 설정 완료"

echo ""
echo "3/3 배포 상태 확인 중..."
kubectl wait --for=condition=ready pod -l app=${SERVICE_NAME}-db -n ecommerce-microservices --timeout=60s

echo "✅ $SERVICE_NAME 준비 완료"

echo ""
echo "=== 마이크로서비스 준비 완료 ==="
echo ""
echo "준비된 리소스:"
kubectl get all -l app=${SERVICE_NAME}-db -n ecommerce-microservices
echo ""
echo "다음 단계: ./setup-api-gateway.sh 실행"
