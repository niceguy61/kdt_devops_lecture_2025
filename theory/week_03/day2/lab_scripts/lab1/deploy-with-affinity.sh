#!/bin/bash

# Week 3 Day 2 Lab 1: Node Affinity 적용 배포
# 사용법: ./deploy-with-affinity.sh

echo "=== Node Affinity 적용 배포 시작 ==="

# 데이터베이스 Deployment 생성 (Node Affinity 적용)
echo "1. Node Affinity가 적용된 데이터베이스 Deployment 생성 중..."

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database-deployment
  labels:
    app: database
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
        tier: backend
        version: v1
    spec:
      affinity:
        nodeAffinity:
          # 필수 조건: SSD 스토리지를 가진 노드에만 배치
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: storage-type
                operator: In
                values: [ssd]
          # 선호 조건: 고성능 CPU를 가진 노드 우선
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: cpu-type
                operator: In
                values: [high-performance]
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: testdb
        - name: POSTGRES_USER
          value: admin
        - name: POSTGRES_PASSWORD
          value: password123
        ports:
        - containerPort: 5432
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 1
            memory: 2Gi
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-data
        emptyDir: {}
EOF

if [ $? -eq 0 ]; then
    echo "✅ 데이터베이스 Deployment 생성 완료"
else
    echo "❌ 데이터베이스 Deployment 생성 실패"
    exit 1
fi

# 배포 상태 확인
echo ""
echo "2. 배포 상태 확인 중..."
sleep 5

kubectl get deployments database-deployment
kubectl get pods -l app=database

echo ""
echo "3. Node Affinity 효과 확인:"
echo "Pod들이 어느 노드에 배치되었는지 확인:"
kubectl get pods -l app=database -o wide

echo ""
echo "4. 노드 라벨과 배치 결과 비교:"
kubectl get nodes --show-labels | grep -E "NAME|storage-type"

echo ""
echo "=== Node Affinity 배포 완료 ==="
echo ""
echo "배포된 리소스:"
echo "- Deployment: database-deployment (replicas: 2)"
echo "- 컨테이너: PostgreSQL 13"
echo "- Node Affinity: storage-type=ssd (필수), cpu-type=high-performance (선호)"
