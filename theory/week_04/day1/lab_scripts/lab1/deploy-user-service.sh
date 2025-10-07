#!/bin/bash

# Week 4 Day 1 Lab 1: 사용자 마이크로서비스 배포
# 사용법: ./deploy-user-service.sh

echo "=== 사용자 마이크로서비스 배포 시작 ==="
echo ""

set -e

echo "1/3 사용자 마이크로서비스 배포 중..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: ecommerce-microservices
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
        image: nginx:1.25
        ports:
        - containerPort: 80
        env:
        - name: DB_HOST
          value: user-service-db
        - name: DB_PORT
          value: "5432"
        - name: DB_NAME
          value: user-service
        - name: SERVICE_NAME
          value: user-microservice
        volumeMounts:
        - name: service-config
          mountPath: /etc/nginx/conf.d
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: service-config
        configMap:
          name: user-service-config
EOF

echo "✅ 사용자 마이크로서비스 배포 완료"

echo ""
echo "2/3 사용자 서비스 노출 중..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: ecommerce-microservices
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

echo "✅ 사용자 서비스 노출 완료"

echo ""
echo "3/3 배포 상태 확인 중..."
kubectl wait --for=condition=ready pod -l app=user-service -n ecommerce-microservices --timeout=60s

echo "✅ 사용자 마이크로서비스 준비 완료"

echo ""
echo "=== 사용자 마이크로서비스 배포 완료 ==="
echo ""
echo "배포된 리소스:"
kubectl get all -l app=user-service -n ecommerce-microservices
echo ""
echo "서비스 상태:"
kubectl get svc user-service -n ecommerce-microservices
echo ""
echo "Pod 상태:"
kubectl get pods -l app=user-service -n ecommerce-microservices
echo ""
echo "다음 단계: ./run-performance-test.sh 실행"
