#!/bin/bash

# Week 4 Day 1 Lab 1: 모놀리스 애플리케이션 설정
# 사용법: ./setup-monolith.sh

echo "=== 모놀리스 E-Commerce 애플리케이션 배포 시작 ==="

# 에러 발생 시 스크립트 중단
set -e
trap 'echo "❌ 스크립트 실행 중 오류 발생"' ERR

echo "1/4 네임스페이스 생성 중..."
kubectl create namespace ecommerce --dry-run=client -o yaml | kubectl apply -f -

echo "2/4 PostgreSQL 데이터베이스 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
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
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: ecommerce
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
EOF

echo "3/4 모놀리스 애플리케이션 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-monolith
  namespace: ecommerce
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ecommerce-monolith
  template:
    metadata:
      labels:
        app: ecommerce-monolith
    spec:
      containers:
      - name: ecommerce-app
        image: nginx:alpine
        ports:
        - containerPort: 80
        env:
        - name: DB_HOST
          value: postgres-service
        - name: DB_NAME
          value: ecommerce
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-monolith-service
  namespace: ecommerce
spec:
  selector:
    app: ecommerce-monolith
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

echo "4/4 Ingress 설정 중..."
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  namespace: ecommerce
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: ecommerce.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ecommerce-monolith-service
            port:
              number: 80
EOF

# Pod 시작 대기
echo "Pod 시작 대기 중..."
kubectl wait --for=condition=ready pod -l app=postgres -n ecommerce --timeout=60s
kubectl wait --for=condition=ready pod -l app=ecommerce-monolith -n ecommerce --timeout=60s

# /etc/hosts 설정 (sudo 권한 필요)
if ! grep -q "ecommerce.local" /etc/hosts; then
    echo "127.0.0.1 ecommerce.local" | sudo tee -a /etc/hosts
    echo "✅ /etc/hosts 파일에 ecommerce.local 추가됨"
fi

echo ""
echo "=== 모놀리스 애플리케이션 배포 완료 ==="
echo ""
echo "배포된 리소스:"
echo "- Namespace: ecommerce"
echo "- Database: PostgreSQL (postgres-service)"
echo "- Application: E-Commerce Monolith (2 replicas)"
echo "- Ingress: ecommerce.local"
echo ""
echo "접속 정보:"
echo "- 웹 브라우저: http://ecommerce.local"
echo "- curl 테스트: curl -H 'Host: ecommerce.local' http://localhost/"
echo ""
echo "상태 확인:"
kubectl get pods -n ecommerce
echo ""
echo "✅ 모놀리스 배포 성공!"
