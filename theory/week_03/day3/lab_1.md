# Week 3 Day 3 Lab 1: 네트워킹 & 서비스 구성

<div align="center">

**🌐 3-Tier 애플리케이션** • **🔗 서비스 연결** • **💾 영속적 스토리지**

*Frontend-Backend-Database 완전한 네트워킹 구성 실습*

</div>

---

## 🕘 실습 정보
**시간**: 12:00-13:30 (90분)  
**목표**: 완전한 3-tier 애플리케이션의 네트워킹과 스토리지 구성  
**방식**: 단계별 실습 + 페어 프로그래밍

## 🎯 실습 목표

### 📚 학습 목표
- **3-tier 아키텍처**: Frontend-Backend-Database 계층별 구성
- **서비스 타입**: ClusterIP, NodePort, LoadBalancer 실제 사용
- **영속적 스토리지**: PVC를 이용한 데이터베이스 데이터 보존
- **Ingress 설정**: 도메인 기반 라우팅과 외부 접근

### 🛠️ 구현 목표
- **완전한 애플리케이션**: 웹 인터페이스부터 데이터베이스까지
- **네트워크 연결**: 각 계층 간 안정적 통신
- **외부 접근**: Ingress를 통한 도메인 기반 접근
- **데이터 영속화**: 데이터베이스 재시작 시에도 데이터 보존

---

## 🏗️ 전체 아키텍처

```mermaid
graph TB
    subgraph "외부 사용자"
        U[사용자<br/>shop.local]
    end
    
    subgraph "Ingress Layer"
        I[Nginx Ingress<br/>shop.local → frontend-service]
    end
    
    subgraph "Frontend Tier"
        F[Frontend Pod<br/>React App]
        FS[Frontend Service<br/>ClusterIP:80]
    end
    
    subgraph "Backend Tier"
        B[Backend Pod<br/>Node.js API]
        BS[Backend Service<br/>ClusterIP:3000]
    end
    
    subgraph "Database Tier"
        D[Database Pod<br/>PostgreSQL]
        DS[Database Service<br/>ClusterIP:5432]
        PVC[PersistentVolumeClaim<br/>postgres-data]
    end
    
    U --> I
    I --> FS
    FS --> F
    F --> BS
    BS --> B
    B --> DS
    DS --> D
    D --> PVC
    
    style U fill:#e3f2fd
    style I fill:#ffebee
    style F fill:#e8f5e8
    style B fill:#fff3e0
    style D fill:#f3e5f5
    style PVC fill:#fce4ec
```

---

## 🛠️ Step 1: 네임스페이스 및 기본 설정 (10분)

### Step 1-1: 환경 준비

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day3/lab_scripts/lab1
./setup-namespace.sh
```

**📋 스크립트 내용**: [setup-namespace.sh](./lab_scripts/lab1/setup-namespace.sh)

**1-1. 수동 실행 (학습용)**
```bash
# 네임스페이스 생성
kubectl create namespace shop-app

# 기본 네임스페이스 설정
kubectl config set-context --current --namespace=shop-app

# 확인
kubectl get namespace shop-app
```

---

## 🗄️ Step 2: 데이터베이스 계층 구성 (25분)

### Step 2-1: 영속적 스토리지 생성 (10분)

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day3/lab_scripts/lab1
./create-database-storage.sh
```

**📋 스크립트 내용**: [create-database-storage.sh](./lab_scripts/lab1/create-database-storage.sh)

**2-1. 수동 실행 (학습용)**
```bash
# PVC 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-data
  namespace: shop-app
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
EOF

# PVC 상태 확인
kubectl get pvc postgres-data
```

### Step 2-2: PostgreSQL 데이터베이스 배포 (15분)

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day3/lab_scripts/lab1
./deploy-database.sh
```

**📋 스크립트 내용**: [deploy-database.sh](./lab_scripts/lab1/deploy-database.sh)

**2-2. 수동 실행 (학습용)**
```bash
# PostgreSQL Deployment 생성
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: shop-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: shopdb
        - name: POSTGRES_USER
          value: shopuser
        - name: POSTGRES_PASSWORD
          value: shoppass
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-data
        persistentVolumeClaim:
          claimName: postgres-data
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: shop-app
spec:
  type: ClusterIP
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
EOF

# 배포 상태 확인
kubectl get pods -l app=postgres
kubectl get svc postgres-service
```

---

## 🔧 Step 3: 백엔드 API 계층 구성 (25분)

### Step 3-1: Node.js API 서버 배포 (15분)

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day3/lab_scripts/lab1
./deploy-backend.sh
```

**📋 스크립트 내용**: [deploy-backend.sh](./lab_scripts/lab1/deploy-backend.sh)

**3-1. 수동 실행 (학습용)**
```bash
# Backend Deployment 생성
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: shop-app
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
        image: nginx:alpine  # 실제로는 Node.js API 이미지 사용
        ports:
        - containerPort: 80
        env:
        - name: DATABASE_URL
          value: "postgresql://shopuser:shoppass@postgres-service:5432/shopdb"
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
  name: backend-service
  namespace: shop-app
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - port: 3000
    targetPort: 80
EOF
```

### Step 3-2: 백엔드 연결 테스트 (10분)

**3-2. 연결 테스트**
```bash
# 백엔드 Pod 상태 확인
kubectl get pods -l app=backend

# 서비스 Endpoint 확인
kubectl get endpoints backend-service

# 데이터베이스 연결 테스트 (Pod 내부에서)
kubectl exec -it deployment/backend -- wget -qO- http://postgres-service:5432 || echo "Connection test completed"
```

---

## 🎨 Step 4: 프론트엔드 계층 구성 (20분)

### Step 4-1: React 프론트엔드 배포 (15분)

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day3/lab_scripts/lab1
./deploy-frontend.sh
```

**📋 스크립트 내용**: [deploy-frontend.sh](./lab_scripts/lab1/deploy-frontend.sh)

**4-1. 수동 실행 (학습용)**
```bash
# Frontend Deployment 생성
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: shop-app
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
          value: "http://backend-service:3000"
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: shop-app
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
EOF
```

### Step 4-2: NodePort로 임시 외부 접근 (5분)

**4-2. NodePort 서비스 생성**
```bash
# NodePort 서비스 추가 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: frontend-nodeport
  namespace: shop-app
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF

# NodePort 접근 테스트
kubectl get svc frontend-nodeport
echo "브라우저에서 http://localhost:30080 접근 가능"
```

---

## 🌐 Step 5: Ingress 설정 (10분)

### Step 5-1: Ingress Controller 설치 및 설정

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day3/lab_scripts/lab1
./setup-ingress.sh
```

**📋 스크립트 내용**: [setup-ingress.sh](./lab_scripts/lab1/setup-ingress.sh)

**5-1. 수동 실행 (학습용)**
```bash
# Ingress 리소스 생성
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shop-ingress
  namespace: shop-app
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
            name: frontend-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 3000
EOF

# Ingress 상태 확인
kubectl get ingress shop-ingress

# 로컬 hosts 파일 설정 (선택사항)
echo "127.0.0.1 shop.local" | sudo tee -a /etc/hosts
```

---

## ✅ Step 6: 전체 시스템 테스트 및 검증 (10분)

### Step 6-1: 종합 테스트

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_03/day3/lab_scripts/lab1
./test-complete-system.sh
```

**📋 스크립트 내용**: [test-complete-system.sh](./lab_scripts/lab1/test-complete-system.sh)

**6-1. 수동 검증 (학습용)**
```bash
# 전체 리소스 상태 확인
echo "=== Pods 상태 ==="
kubectl get pods -o wide

echo "=== Services 상태 ==="
kubectl get svc

echo "=== PVC 상태 ==="
kubectl get pvc

echo "=== Ingress 상태 ==="
kubectl get ingress

# 네트워크 연결 테스트
echo "=== 네트워크 연결 테스트 ==="
kubectl exec -it deployment/frontend -- wget -qO- http://backend-service:3000 || echo "Frontend → Backend 연결 테스트"
kubectl exec -it deployment/backend -- nc -zv postgres-service 5432 || echo "Backend → Database 연결 테스트"

# 데이터 영속성 테스트
echo "=== 데이터 영속성 테스트 ==="
kubectl delete pod -l app=postgres
kubectl wait --for=condition=Ready pod -l app=postgres --timeout=60s
echo "PostgreSQL Pod 재시작 후 데이터 확인 완료"
```

---

## 🔍 실습 체크포인트

### ✅ 기본 구성 확인
- [ ] **네임스페이스**: shop-app 네임스페이스 생성 및 설정
- [ ] **PVC**: postgres-data PVC 생성 및 바인딩
- [ ] **데이터베이스**: PostgreSQL Pod 정상 실행
- [ ] **백엔드**: Node.js API 서버 2개 Pod 실행
- [ ] **프론트엔드**: React 앱 2개 Pod 실행

### ✅ 네트워킹 확인
- [ ] **ClusterIP**: 모든 서비스가 ClusterIP로 내부 통신
- [ ] **NodePort**: 프론트엔드 NodePort로 외부 접근 가능
- [ ] **Ingress**: shop.local 도메인으로 접근 가능
- [ ] **서비스 디스커버리**: DNS 이름으로 서비스 간 통신

### ✅ 스토리지 확인
- [ ] **영속성**: PostgreSQL Pod 재시작 후에도 데이터 유지
- [ ] **PVC 바인딩**: PVC와 PV 정상 바인딩
- [ ] **볼륨 마운트**: 데이터베이스 데이터 디렉토리 정상 마운트

---

## 🚀 심화 실습 (선택사항)

### 고급 기능 추가

**HPA (Horizontal Pod Autoscaler) 설정**
```bash
# 프론트엔드 HPA 생성
kubectl autoscale deployment frontend --cpu-percent=70 --min=2 --max=5

# 백엔드 HPA 생성
kubectl autoscale deployment backend --cpu-percent=70 --min=2 --max=5

# HPA 상태 확인
kubectl get hpa
```

**Network Policy 적용**
```bash
# 데이터베이스 접근 제한 정책
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: postgres-policy
  namespace: shop-app
spec:
  podSelector:
    matchLabels:
      app: postgres
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
EOF
```

---

## 🧹 실습 정리

### 환경 정리 스크립트

**🚀 자동화 정리**
```bash
cd theory/week_03/day3/lab_scripts/lab1
./cleanup.sh
```

**수동 정리**
```bash
# 네임스페이스 삭제 (모든 리소스 함께 삭제)
kubectl delete namespace shop-app

# hosts 파일 정리 (선택사항)
sudo sed -i '/shop.local/d' /etc/hosts
```

---

## 💡 실습 회고

### 🤝 페어 회고 (5분)
1. **가장 어려웠던 부분**: 어떤 단계에서 가장 많은 시간이 걸렸나요?
2. **새로운 발견**: 이론에서 배운 것과 실습에서 다른 점이 있었나요?
3. **실무 적용**: 실제 프로젝트에서 어떻게 활용할 수 있을까요?

### 📊 학습 성과
- **3-tier 아키텍처**: 완전한 웹 애플리케이션 구조 이해
- **서비스 타입**: 각 계층에 적합한 서비스 타입 선택
- **영속적 스토리지**: 데이터 손실 없는 안전한 데이터 관리
- **Ingress 활용**: 도메인 기반 라우팅과 외부 접근 관리

---

<div align="center">

**🌐 네트워킹 완성** • **💾 스토리지 마스터** • **🔗 서비스 연결** • **🚀 실무 준비**

*다음: Challenge로 네트워크 장애 해결 능력 향상하기*

</div>
