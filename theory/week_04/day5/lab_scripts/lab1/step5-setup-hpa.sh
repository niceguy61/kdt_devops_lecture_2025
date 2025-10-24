#!/bin/bash

# Week 4 Day 5 Lab 1: HPA 설정
# 설명: Horizontal Pod Autoscaler 설정

set -e

echo "=== HPA 설정 시작 ==="

# 1. Production HPA 설정
echo "1/2 Production HPA 설정 중..."
kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF

# 2. Staging HPA 설정
echo "2/2 Staging HPA 설정 중..."
kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-server-hpa
  namespace: staging
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-server
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF

# HPA 상태 확인
echo ""
echo "HPA 상태 확인 중..."
sleep 5
kubectl get hpa -n production
kubectl get hpa -n staging

echo ""
echo "=== HPA 설정 완료 ==="
echo ""
echo "설정된 HPA:"
echo "- Production: web-app-hpa (2-10 replicas, CPU 70%, Memory 80%)"
echo "- Staging: api-server-hpa (1-5 replicas, CPU 70%)"
echo ""
echo "💡 HPA가 메트릭을 수집하려면 1-2분 소요됩니다."
echo ""
echo "모니터링 명령어:"
echo "  kubectl get hpa -n production -w"
echo "  kubectl get hpa -n staging -w"
echo ""
echo "✅ 모든 작업이 성공적으로 완료되었습니다."
