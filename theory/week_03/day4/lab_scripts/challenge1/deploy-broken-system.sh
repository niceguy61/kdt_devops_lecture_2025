#!/bin/bash

# Week 3 Day 4 Challenge 1: 문제 시스템 배포
# 사용법: ./deploy-broken-system.sh

set -e

echo "=== SecureBank 문제 시스템 배포 시작 ==="

# 네임스페이스 생성
echo "1/5 네임스페이스 생성 중..."
kubectl create namespace securebank --dry-run=client -o yaml | kubectl apply -f -

# 문제 1: 잘못된 RBAC 설정
echo "2/5 RBAC 리소스 배포 중 (문제 포함)..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: developer-sa
  namespace: securebank
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer-role
  namespace: securebank
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get"]  # 의도적 오류: create 권한 없음
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["list"]  # 의도적 오류: get 권한 없음
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: securebank
subjects:
- kind: ServiceAccount
  name: wrong-developer-sa  # 의도적 오류: 잘못된 SA 이름
  namespace: securebank
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
EOF

# 문제 3: 잘못된 Network Policy
echo "3/5 Network Policy 배포 중 (문제 포함)..."
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: securebank
spec:
  podSelector:
    matchLabels:
      app: backend
      tier: wrong-tier  # 의도적 오류: 잘못된 라벨
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 9999  # 의도적 오류: 잘못된 포트
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: securebank
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  # 의도적 오류: ingress 규칙 없음 (모든 트래픽 차단)
EOF

# 문제 4: Secret 노출
echo "4/5 애플리케이션 배포 중 (Secret 노출 문제 포함)..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: securebank
data:
  api-key: "sk-1234567890abcdef"  # 의도적 오류: API 키를 ConfigMap에 저장
  database-url: "postgresql://admin:password123@database:5432/securebank"  # 의도적 오류: 평문 비밀번호
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: securebank
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
      tier: api
  template:
    metadata:
      labels:
        app: backend
        tier: api
    spec:
      serviceAccountName: developer-sa
      containers:
      - name: backend
        image: nginx:alpine
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_PASSWORD
          value: "supersecret123"  # 의도적 오류: 평문 비밀번호
        - name: API_KEY
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: api-key
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: securebank
spec:
  selector:
    app: backend
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: securebank
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
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  namespace: securebank
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
      - name: database
        image: postgres:13-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_PASSWORD
          value: "dbpassword"
---
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: securebank
spec:
  selector:
    app: database
  ports:
  - port: 5432
    targetPort: 5432
EOF

# 상태 확인
echo "5/5 배포 상태 확인 중..."
sleep 5
kubectl get all -n securebank

echo ""
echo "=== SecureBank 문제 시스템 배포 완료 ==="
echo ""
echo "🚨 발견된 보안 문제:"
echo "1. RBAC 권한 오류 - developer-sa가 Pod 생성 불가"
echo "2. 인증서 만료 - 시뮬레이션 (실제 환경에서 테스트)"
echo "3. Network Policy 차단 - 잘못된 라벨과 포트"
echo "4. Secret 노출 - 평문 비밀번호와 ConfigMap 오용"
echo ""
echo "Challenge 시작!"
