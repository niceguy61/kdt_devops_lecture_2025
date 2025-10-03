#!/bin/bash

# Challenge 1: 문제가 있는 E-Shop 시스템 배포

echo "🚀 Challenge 1: E-Shop 장애 시스템 배포 시작..."

echo "📦 네임스페이스 생성 중..."
kubectl create namespace eshop-broken --dry-run=client -o yaml | kubectl apply -f -

echo "🗄️ 데이터베이스 배포 중 (PVC 문제 포함)..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-storage
  namespace: eshop-broken
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Ti  # 의도적 오류: 불가능한 용량
  storageClassName: nonexistent-storage  # 의도적 오류: 존재하지 않는 StorageClass
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  namespace: eshop-broken
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
          value: eshopdb
        - name: POSTGRES_USER
          value: eshopuser
        - name: POSTGRES_PASSWORD
          value: eshoppass
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: db-data
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: db-data
        persistentVolumeClaim:
          claimName: database-storage
---
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: eshop-broken
spec:
  selector:
    app: database
  ports:
  - port: 5432
    targetPort: 5432
EOF

echo "🔧 백엔드 API 배포 중 (서비스 이름 오류 포함)..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: eshop-broken
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: nginx:alpine
        ports:
        - containerPort: 80
        env:
        - name: DATABASE_URL
          value: "postgresql://eshopuser:eshoppass@database-service:5432/eshopdb"
---
apiVersion: v1
kind: Service
metadata:
  name: wrong-backend-service  # 의도적 오류: 잘못된 서비스 이름
  namespace: eshop-broken
spec:
  selector:
    app: backend
  ports:
  - port: 3000
    targetPort: 80
EOF

echo "🎨 프론트엔드 배포 중..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: eshop-broken
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
      - name: frontend
        image: nginx:alpine
        ports:
        - containerPort: 80
        env:
        - name: REACT_APP_API_URL
          value: "http://backend-service:3000"  # 올바른 서비스 이름 참조
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: eshop-broken
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
EOF

echo "🌐 Ingress 배포 중 (라우팅 오류 포함)..."
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shop-ingress
  namespace: eshop-broken
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: shop.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nonexistent-frontend-service  # 의도적 오류: 존재하지 않는 서비스
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service  # 올바른 이름이지만 서비스가 wrong-backend-service로 생성됨
            port:
              number: 3000
EOF

echo "🔐 네트워크 정책 배포 중 (라벨 불일치 포함)..."
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: eshop-broken
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: wrong-backend  # 의도적 오류: 잘못된 라벨
    ports:
    - protocol: TCP
      port: 5432
EOF

echo "❌ 문제가 있는 E-Shop 시스템 배포 완료!"
echo ""
echo "🚨 발생한 문제들:"
echo "1. DNS 해결 실패 - 잘못된 서비스 이름"
echo "2. Ingress 라우팅 오류 - 존재하지 않는 서비스 참조"
echo "3. PVC 바인딩 실패 - 불가능한 스토리지 요청"
echo "4. 네트워크 정책 차단 - 라벨 불일치"
echo ""
echo "🔍 문제 해결을 시작하세요!"
echo "kubectl get all -n eshop-broken"
