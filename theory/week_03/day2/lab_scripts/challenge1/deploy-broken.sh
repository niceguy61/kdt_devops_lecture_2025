#!/bin/bash

# Challenge 1: 문제가 있는 워크로드 배포
cd "$(dirname "$0")"

echo "🚀 Challenge 1: 문제 해결 시나리오 시작"

kubectl create namespace challenge1 --dry-run=client -o yaml | kubectl apply -f -

# 문제 1: 잘못된 이미지
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-app
  namespace: challenge1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: broken-app
  template:
    metadata:
      labels:
        app: broken-app
    spec:
      containers:
      - name: app
        image: nginx:nonexistent-tag
        ports:
        - containerPort: 80
EOF

# 문제 2: 리소스 부족
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-hungry
  namespace: challenge1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: resource-hungry
  template:
    metadata:
      labels:
        app: resource-hungry
    spec:
      containers:
      - name: app
        image: nginx:1.20
        resources:
          requests:
            cpu: 10000m
            memory: 10Gi
EOF

echo "❌ 문제가 있는 워크로드 배포 완료"
echo "🔍 문제를 찾아 해결해보세요!"
