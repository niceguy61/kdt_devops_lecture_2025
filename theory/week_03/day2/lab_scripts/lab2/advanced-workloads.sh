#!/bin/bash

# H1: 고급 워크로드 관리
cd "$(dirname "$0")"

echo "🚀 H1: 고급 워크로드 관리 시작"

kubectl create namespace advanced-demo --dry-run=client -o yaml | kubectl apply -f -

# HPA가 있는 Deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scalable-app
  namespace: advanced-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scalable-app
  template:
    metadata:
      labels:
        app: scalable-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: scalable-app-hpa
  namespace: advanced-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scalable-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF

echo "✅ 고급 워크로드 배포 완료!"
echo "📊 HPA 상태: kubectl get hpa -n advanced-demo"
