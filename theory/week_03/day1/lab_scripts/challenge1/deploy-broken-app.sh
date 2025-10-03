#!/bin/bash

# Challenge 1: 문제가 있는 웹 애플리케이션 배포 스크립트

echo "🚀 Challenge 1: 문제가 있는 웹 애플리케이션 배포 시작..."
echo "⚠️  이 애플리케이션들은 의도적으로 문제가 있습니다."

# 현재 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 스크립트 디렉토리: $SCRIPT_DIR"

# 기존 리소스 정리
echo "🧹 기존 리소스 정리 중..."
kubectl delete namespace challenge1 2>/dev/null || true
sleep 5

# 네임스페이스 생성
echo "📦 네임스페이스 생성 중..."
kubectl create namespace challenge1
kubectl config set-context --current --namespace=challenge1

echo "🏗️  문제가 있는 애플리케이션들 배포 중..."

# 시나리오 1: 포트 문제가 있는 Frontend 배포
echo "📱 Frontend 애플리케이션 배포 중 (포트 문제 포함)..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: challenge1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
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
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: challenge1
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080  # 잘못된 포트! nginx는 80 포트 사용
    nodePort: 30080
  selector:
    app: frontend
EOF

# 시나리오 2: 환경변수 문제가 있는 API 서버 배포
echo "🔧 API 서버 배포 중 (환경변수 문제 포함)..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: challenge1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api
        image: httpd:2.4
        ports:
        - containerPort: 80
        env:
        - name: DATABASE_HOST
          value: "wrong-database-host"  # 잘못된 호스트명
        - name: DATABASE_PORT
          value: "5432"
        - name: API_PORT
          value: "80"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
---
apiVersion: v1
kind: Service
metadata:
  name: api-service
  namespace: challenge1
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30081
  selector:
    app: api-server
EOF

# 시나리오 3: 잘못된 이미지 태그 배포
echo "🖼️  Frontend v2 배포 중 (이미지 문제 포함)..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-v2
  namespace: challenge1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend-v2
  template:
    metadata:
      labels:
        app: frontend-v2
    spec:
      containers:
      - name: nginx
        image: nginx:nonexistent-tag  # 존재하지 않는 태그
        ports:
        - containerPort: 80
EOF

# 시나리오 4: 라벨 셀렉터 문제가 있는 Backend 배포
echo "⚙️  Backend 서비스 배포 중 (라벨 문제 포함)..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: challenge1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
        version: v1
    spec:
      containers:
      - name: httpd
        image: httpd:2.4
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: challenge1
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: backend-wrong  # 잘못된 셀렉터!
    version: v1
EOF

# 정상적인 데이터베이스 (참조용)
echo "🗄️  데이터베이스 배포 중 (정상)..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  namespace: challenge1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: "webstart"
        - name: POSTGRES_USER
          value: "admin"
        - name: POSTGRES_PASSWORD
          value: "password123"
        ports:
        - containerPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: challenge1
spec:
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: database
EOF

# 배포 완료 대기
echo "⏳ 배포 완료 대기 중 (30초)..."
sleep 30

echo ""
echo "💥 Challenge 1 문제 애플리케이션 배포 완료!"
echo ""
echo "🎯 배포된 문제들:"
echo "  1. Frontend Service: 잘못된 targetPort (8080 → 80)"
echo "  2. API Server: 잘못된 DATABASE_HOST 환경변수"
echo "  3. Frontend v2: 존재하지 않는 이미지 태그"
echo "  4. Backend Service: 잘못된 라벨 셀렉터"
echo ""
echo "🔍 현재 상태 확인:"
kubectl get pods -n challenge1
echo ""
kubectl get svc -n challenge1
echo ""
echo "🚀 Challenge 시작!"
echo "  1. 웹사이트 접근 테스트: curl http://localhost:30080"
echo "  2. API 서버 테스트: curl http://localhost:30081"
echo "  3. 각 문제를 하나씩 진단하고 해결하세요"
echo ""
echo "📋 사용 가능한 명령어:"
echo "  kubectl get pods -n challenge1"
echo "  kubectl describe pod <pod-name> -n challenge1"
echo "  kubectl logs <pod-name> -n challenge1"
echo "  kubectl get svc -n challenge1"
echo "  kubectl describe svc <service-name> -n challenge1"
echo ""
echo "🎯 목표: 모든 애플리케이션이 정상 동작하도록 문제 해결!"
