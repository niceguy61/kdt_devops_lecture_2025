#!/bin/bash

# Week 4 Day 1 Lab 1: 사용자 마이크로서비스 배포
# 사용법: ./deploy-user-service-fixed.sh

echo "=== 사용자 마이크로서비스 배포 시작 ==="
echo ""

set -e
trap 'echo "❌ 스크립트 실행 중 오류 발생"' ERR

echo "1/4 사용자 전용 데이터베이스 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-db
  namespace: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: user-db
  template:
    metadata:
      labels:
        app: user-db
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: userdb
        - name: POSTGRES_USER
          value: admin
        - name: POSTGRES_PASSWORD
          value: password123
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: user-db-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: user-db-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: user-db-service
  namespace: ecommerce
spec:
  selector:
    app: user-db
  ports:
  - port: 5432
    targetPort: 5432
EOF

echo "2/4 사용자 마이크로서비스 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: ecommerce
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
        image: nginx:alpine
        ports:
        - containerPort: 80
        env:
        - name: DB_HOST
          value: user-db-service
        - name: DB_NAME
          value: userdb
        - name: SERVICE_NAME
          value: user-service
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: ecommerce
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

echo "3/4 하이브리드 Ingress 설정 중..."
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-hybrid-ingress
  namespace: ecommerce
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: ecommerce.local
    http:
      paths:
      # 사용자 관련 요청은 마이크로서비스로
      - path: /api/users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 80
      - path: /users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 80
      # 나머지 요청은 모놀리스로
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ecommerce-monolith-service
            port:
              number: 80
EOF

# 기존 Ingress 삭제
kubectl delete ingress ecommerce-ingress -n ecommerce

echo "4/4 배포 상태 확인 중..."
kubectl wait --for=condition=ready pod -l app=user-db -n ecommerce --timeout=60s
kubectl wait --for=condition=ready pod -l app=user-service -n ecommerce --timeout=60s

echo ""
echo "=== 사용자 마이크로서비스 배포 완료 ==="
echo ""
echo "배포된 리소스:"
echo "- 사용자 데이터베이스: user-db (1 replica)"
echo "- 사용자 서비스: user-service (2 replicas)"
echo "- 하이브리드 Ingress: /api/users, /users → user-service"
echo ""
echo "상태 확인:"
kubectl get pods -n ecommerce
echo ""
echo "서비스 확인:"
kubectl get svc -n ecommerce
echo ""
echo "✅ 하이브리드 아키텍처 배포 성공!"
