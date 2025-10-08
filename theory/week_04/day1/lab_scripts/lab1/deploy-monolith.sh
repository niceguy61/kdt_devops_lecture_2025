#!/bin/bash

# Week 4 Day 1 Lab 1: 모놀리스 애플리케이션 배포
# 사용법: ./deploy-monolith.sh

echo "=== 모놀리스 애플리케이션 배포 시작 ==="
echo ""

set -e

echo "1/4 모놀리스 데이터베이스 배포 중..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monolith-db
  namespace: ecommerce-monolith
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monolith-db
  template:
    metadata:
      labels:
        app: monolith-db
    spec:
      containers:
      - name: postgres
        image: postgres:16
        env:
        - name: POSTGRES_DB
          value: ecommerce
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
  name: monolith-db
  namespace: ecommerce-monolith
spec:
  selector:
    app: monolith-db
  ports:
  - port: 5432
    targetPort: 5432
EOF

echo "✅ 데이터베이스 배포 완료"

echo ""
echo "2/4 모놀리스 애플리케이션 배포 중..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monolith-app
  namespace: ecommerce-monolith
spec:
  replicas: 2
  selector:
    matchLabels:
      app: monolith-app
  template:
    metadata:
      labels:
        app: monolith-app
    spec:
      containers:
      - name: ecommerce-monolith
        image: nginx:1.25
        ports:
        - containerPort: 80
        env:
        - name: DB_HOST
          value: monolith-db
        - name: DB_PORT
          value: "5432"
        - name: DB_NAME
          value: ecommerce
        volumeMounts:
        - name: app-config
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: app-config
        configMap:
          name: monolith-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: monolith-config
  namespace: ecommerce-monolith
data:
  default.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location /api/users {
            return 200 '{"service": "monolith", "endpoint": "users", "response_time": "5ms"}';
            add_header Content-Type application/json;
        }
        
        location /api/products {
            return 200 '{"service": "monolith", "endpoint": "products", "response_time": "8ms"}';
            add_header Content-Type application/json;
        }
        
        location /api/orders {
            return 200 '{"service": "monolith", "endpoint": "orders", "response_time": "12ms"}';
            add_header Content-Type application/json;
        }
        
        location / {
            return 200 '{"service": "ecommerce-monolith", "status": "running", "architecture": "monolith"}';
            add_header Content-Type application/json;
        }
    }
EOF

echo "✅ 애플리케이션 배포 완료"

echo ""
echo "3/4 로드밸런서 서비스 생성 중..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: monolith-service
  namespace: ecommerce-monolith
spec:
  type: LoadBalancer
  selector:
    app: monolith-app
  ports:
  - port: 80
    targetPort: 80
EOF

echo "✅ 로드밸런서 생성 완료"

echo ""
echo "4/4 배포 상태 확인 중..."
kubectl wait --for=condition=ready pod -l app=monolith-db -n ecommerce-monolith --timeout=60s
kubectl wait --for=condition=ready pod -l app=monolith-app -n ecommerce-monolith --timeout=60s

echo "✅ 모든 Pod 준비 완료"

echo ""
echo "=== 모놀리스 배포 완료 ==="
echo ""
echo "배포된 리소스:"
kubectl get all -n ecommerce-monolith
echo ""
echo "서비스 엔드포인트:"
kubectl get svc monolith-service -n ecommerce-monolith
echo ""
echo "다음 단계: ./prepare-microservice.sh user-service 실행"
