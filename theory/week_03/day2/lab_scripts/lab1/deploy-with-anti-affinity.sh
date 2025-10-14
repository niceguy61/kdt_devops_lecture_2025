#!/bin/bash

# Week 3 Day 2 Lab 1: Pod Anti-Affinity 적용 배포
# 사용법: ./deploy-with-anti-affinity.sh

echo "=== Pod Anti-Affinity 적용 배포 시작 ==="

# API 서버 Deployment 생성 (Pod Anti-Affinity 적용)
echo "1. Pod Anti-Affinity가 적용된 API 서버 Deployment 생성 중..."

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
  labels:
    app: api
    tier: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
        tier: backend
        version: v1
    spec:
      affinity:
        podAntiAffinity:
          # 같은 앱의 Pod들을 다른 노드에 배치 (고가용성)
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values: [api]
              topologyKey: kubernetes.io/hostname
      containers:
      - name: api-server
        image: httpd:2.4
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

if [ $? -eq 0 ]; then
    echo "✅ API 서버 Deployment 생성 완료"
else
    echo "❌ API 서버 Deployment 생성 실패"
    exit 1
fi

# 배포 상태 확인
echo ""
echo "2. 배포 상태 확인 중..."
sleep 10

kubectl get deployments api-deployment
kubectl get pods -l app=api

echo ""
echo "3. Pod Anti-Affinity 효과 확인:"
echo "API Pod들이 서로 다른 노드에 분산 배치되었는지 확인:"
kubectl get pods -l app=api -o wide

echo ""
echo "4. 노드별 Pod 분산 현황:"
echo "각 노드에 배치된 Pod 개수 확인:"
kubectl get pods -l app=api -o wide | awk 'NR>1 {print $7}' | sort | uniq -c

# 추가 테스트: 강제 Anti-Affinity 적용
echo ""
echo "5. 강제 Anti-Affinity 테스트 Deployment 생성..."

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-api-deployment
  labels:
    app: critical-api
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: critical-api
  template:
    metadata:
      labels:
        app: critical-api
        tier: backend
        version: v1
    spec:
      affinity:
        podAntiAffinity:
          # 강제 Anti-Affinity (필수 조건)
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values: [critical-api]
            topologyKey: kubernetes.io/hostname
      containers:
      - name: critical-api
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF

sleep 5
echo ""
echo "6. 강제 Anti-Affinity 결과 확인:"
kubectl get pods -l app=critical-api -o wide

echo ""
echo "=== Pod Anti-Affinity 배포 완료 ==="
echo ""
echo "배포된 리소스:"
echo "- api-deployment: 선호 Anti-Affinity (replicas: 3)"
echo "- critical-api-deployment: 필수 Anti-Affinity (replicas: 2)"
echo ""
echo "Anti-Affinity 효과:"
echo "- 같은 앱의 Pod들이 서로 다른 노드에 분산 배치"
echo "- 노드 장애 시 고가용성 확보"
