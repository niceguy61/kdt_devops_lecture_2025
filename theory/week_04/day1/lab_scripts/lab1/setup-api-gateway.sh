#!/bin/bash

# Week 4 Day 1 Lab 1: API Gateway 설정
# 사용법: ./setup-api-gateway.sh

echo "=== API Gateway 설정 시작 ==="
echo ""

set -e

echo "1/3 Ingress Controller 설치 중..."
# Nginx Ingress Controller 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

echo "✅ Ingress Controller 설치 완료"

echo ""
echo "2/3 Ingress Controller 준비 대기 중..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "✅ Ingress Controller 준비 완료"

echo ""
echo "3/3 API Gateway 라우팅 규칙 생성 중..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-gateway
  namespace: ecommerce-monolith
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /\$2
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /monolith(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: monolith-service
            port:
              number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservice-gateway
  namespace: ecommerce-microservices
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /\$2
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /microservice(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: user-service
            port:
              number: 80
EOF

echo "✅ API Gateway 라우팅 규칙 생성 완료"

echo ""
echo "=== API Gateway 설정 완료 ==="
echo ""
echo "Ingress Controller 상태:"
kubectl get pods -n ingress-nginx
echo ""
echo "생성된 Ingress 규칙:"
kubectl get ingress --all-namespaces
echo ""
echo "외부 IP 확인:"
kubectl get svc -n ingress-nginx
echo ""
echo "다음 단계: ./deploy-user-service.sh 실행"
