# Week 4 Day 2 Hands-on 1: Istio Service Mesh 구축

<div align="center">

**⛵ Istio** • **🔀 트래픽 관리** • **🔐 mTLS** • **📊 관측성**

*Service Mesh로 마이크로서비스 통신 완전 제어*

</div>

---

## 🕘 실습 정보
**시간**: 14:00-14:50 (50분)  
**목표**: Istio Service Mesh 설치 및 고급 트래픽 관리  
**방식**: Lab 1 기반 + Istio 추가 설치

## 🎯 실습 목표

### 📚 학습 목표
- **Istio 아키텍처**: Control Plane(Istiod)과 Data Plane(Envoy) 이해
- **Sidecar 패턴**: Envoy Proxy 자동 주입 메커니즘
- **트래픽 관리**: VirtualService와 DestinationRule로 카나리 배포
- **관측성**: Kiali, Jaeger, Prometheus 통합 모니터링

### 🛠️ 구현 목표
- **Istio 설치**: Control Plane 배포 및 Ingress Gateway 설정
- **카나리 배포**: User Service v1(90%) vs v2(10%) 트래픽 분할
- **서비스 메시**: Envoy Sidecar를 통한 모든 트래픽 제어
- **관측성 도구**: Kiali 서비스 그래프 및 Jaeger 분산 추적

---

## 🚀 Step 0: 환경 초기화 (5분)

### Step 0-1: 클러스터 정리 및 재구성

```bash
# 기존 클러스터 완전 삭제
kind delete cluster --name lab-cluster

# Lab 1 기반 클러스터 재생성
../lab1/setup-cluster.sh

# 클러스터 상태 확인
kubectl get nodes
kubectl get namespaces
```

### Step 0-2: 기본 서비스 배포 (Lab 1 기반)

```bash

# 배포 상태 확인
kubectl get pods -n backend
kubectl get services -n backend
```

---

## 🏗️ 전체 아키텍처

```mermaid
graph TB
    subgraph "Istio Control Plane"
        Istiod[Istiod<br/>Pilot + Citadel + Galley]
    end
    
    subgraph "Istio Ingress"
        IG[Istio Ingress Gateway<br/>NodePort 30080]
    end
    
    subgraph "Application Pods"
        subgraph "User Service v1"
            U1A[User App v1]
            U1E[Envoy Sidecar]
        end
        
        subgraph "User Service v2"
            U2A[User App v2]
            U2E[Envoy Sidecar]
        end
        
        subgraph "Product Service"
            PA[Product App]
            PE[Envoy Sidecar]
        end
        
        subgraph "Order Service"
            OA[Order App]
            OE[Envoy Sidecar]
        end
    end
    
    subgraph "Observability"
        K[Kiali<br/>Service Graph]
        J[Jaeger<br/>Tracing]
        P[Prometheus<br/>Metrics]
        G[Grafana<br/>Dashboard]
    end
    
    C[Client] --> IG
    IG --> U1E
    IG --> U2E
    
    U1E <--> U1A
    U2E <--> U2A
    PE <--> PA
    OE <--> OA
    
    U1E <--> PE
    U2E <--> PE
    PE <--> OE
    
    Istiod -.-> U1E
    Istiod -.-> U2E
    Istiod -.-> PE
    Istiod -.-> OE
    
    U1E -.-> P
    U2E -.-> P
    PE -.-> P
    OE -.-> P
    
    P --> G
    U1E -.-> J
    U2E -.-> J
    
    K -.-> Istiod
    
    style Istiod fill:#e3f2fd
    style IG fill:#4caf50
    style U1A fill:#2196f3
    style U2A fill:#2196f3
    style PA fill:#2196f3
    style OA fill:#2196f3
    style U1E fill:#ff9800
    style U2E fill:#ff9800
    style PE fill:#ff9800
    style OE fill:#ff9800
    style K fill:#9c27b0
    style J fill:#9c27b0
    style P fill:#9c27b0
    style G fill:#9c27b0
```

---

## 🛠️ Step 1: Istio 설치 (15분)

### Step 1-1: Istio 다운로드 및 설치

```bash
# Istio 다운로드 (1.20.0 버전)
cd /tmp
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -

# PATH 설정
cd istio-1.20.0
export PATH=$PWD/bin:$PATH

# Istio 설치 (demo 프로필)
istioctl install --set values.defaultRevision=default -y

# 설치 확인
kubectl get pods -n istio-system
kubectl get svc -n istio-system
```

### Step 1-2: 네임스페이스 Sidecar 주입 설정

```bash
# backend 네임스페이스에 Istio 주입 활성화  
kubectl label namespace backend istio-injection=enabled

# 라벨 확인
kubectl get namespace -L istio-injection
```

```bash
# 1. Lab 1 Kong 정리 확인
kubectl get namespace kong 2>/dev/null && echo "⚠️  Lab 1 cleanup 먼저 실행하세요" || echo "✅ Kong 정리 완료"

# 2. backend 네임스페이스 생성
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -

# 3. 백엔드 서비스 배포 (User, Product, Order)
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=User Service Response"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product-service
  template:
    metadata:
      labels:
        app: product-service
    spec:
      containers:
      - name: product-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=Product Service Response"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: product-service
spec:
  selector:
    app: product-service
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
      - name: order-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=Order Service Response"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  selector:
    app: order-service
  ports:
  - port: 80
    targetPort: 8080
EOF

# 4. Pod 준비 대기
kubectl wait --for=condition=ready pod -l app=user-service -n backend --timeout=60s
kubectl wait --for=condition=ready pod -l app=product-service -n backend --timeout=60s
kubectl wait --for=condition=ready pod -l app=order-service -n backend --timeout=60s

---

## 🔄 Step 2: 애플리케이션 재배포 (Sidecar 주입) (10분)

### Step 2-1: 기존 Pod 재시작 (Sidecar 주입)

```bash
# 기존 Deployment 재시작 (Sidecar 주입을 위해)
kubectl rollout restart deployment -n backend

# Pod 재시작 대기
kubectl rollout status deployment/user-service -n backend
kubectl rollout status deployment/product-service -n backend  
kubectl rollout status deployment/order-service -n backend

# Sidecar 주입 확인 (각 Pod에 2개 컨테이너 있어야 함)
kubectl get pods -n backend
```

### Step 2-2: Sidecar 주입 검증

```bash
# Pod 상세 정보 확인 (2개 컨테이너: app + istio-proxy)
kubectl describe pod -l app=user-service -n backend | grep -A 5 "Containers:"

# Envoy 설정 확인
kubectl exec -n backend deployment/user-service -c istio-proxy -- pilot-agent request GET config_dump | head -20
```
  labels:
    app: user-service
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: user-service
      version: v2
  template:
    metadata:
      labels:
        app: user-service
        version: v2
    spec:
      containers:
      - name: user-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=User Service v2 Response (NEW)"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
EOF

# 4. Product Service 재배포 (version 라벨 포함)
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
  labels:
    app: product-service
    version: v1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product-service
      version: v1
  template:
    metadata:
      labels:
        app: product-service
        version: v1
    spec:
      containers:
      - name: product-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=Product Service Response"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
EOF

# 5. Order Service 재배포 (version 라벨 포함)
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  labels:
    app: order-service
    version: v1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: order-service
      version: v1
  template:
    metadata:
      labels:
        app: order-service
        version: v1
    spec:
      containers:
      - name: order-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=Order Service Response"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
EOF

# 6. Pod 준비 대기
kubectl wait --for=condition=ready pod -l app=user-service -n backend --timeout=120s
kubectl wait --for=condition=ready pod -l app=product-service -n backend --timeout=120s
kubectl wait --for=condition=ready pod -l app=order-service -n backend --timeout=120s
```

**검증**:
```bash
# Sidecar 주입 확인 (각 Pod는 2/2 컨테이너여야 함)
kubectl get pods -n backend

# 특정 Pod의 컨테이너 확인
kubectl get pod -n backend -l app=user-service -o jsonpath='{.items[0].spec.containers[*].name}'
# 출력: user-service istio-proxy
```

---

## 🌐 Step 3: Istio 트래픽 관리 설정 (20분)

### Step 3-1: Gateway 생성 (5분)

**목표**: Istio Ingress Gateway를 통한 외부 트래픽 수신

```bash
# Istio Gateway 생성
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: app-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
EOF

# Gateway 확인
kubectl get gateway -n backend
```

### Step 3-2: VirtualService 및 DestinationRule 생성 (10분)

**목표**: User Service 카나리 배포 (v1: 90%, v2: 10%)

```bash
# 1. User Service VirtualService (카나리 배포)
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: user-service
spec:
  hosts:
  - "*"
  gateways:
  - app-gateway
  http:
  - match:
    - uri:
        prefix: /users
    route:
    - destination:
        host: user-service.backend.svc.cluster.local
        subset: v1
      weight: 90
    - destination:
        host: user-service.backend.svc.cluster.local
        subset: v2
      weight: 10
EOF

# 2. User Service DestinationRule (버전별 subset 정의)
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: user-service
spec:
  host: user-service.backend.svc.cluster.local
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
EOF

# 3. Product Service VirtualService
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: product-service
spec:
  hosts:
  - "*"
  gateways:
  - app-gateway
  http:
  - match:
    - uri:
        prefix: /products
    route:
    - destination:
        host: product-service.backend.svc.cluster.local
EOF

# 4. Order Service VirtualService
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: order-service
spec:
  hosts:
  - "*"
  gateways:
  - app-gateway
  http:
  - match:
    - uri:
        prefix: /orders
    route:
    - destination:
        host: order-service.backend.svc.cluster.local
EOF
```

### Step 3-3: 카나리 배포 테스트 (5분)

**목표**: 트래픽 분할 비율 확인

```bash
# 100번 호출하여 v1/v2 비율 확인
for i in {1..100}; do 
  curl -s http://localhost:8080/users
done | sort | uniq -c

# 예상 결과:
#  90 User Service v1 Response
#  10 User Service v2 Response (NEW)

# Product Service 테스트
curl http://localhost:8080/products

# Order Service 테스트
curl http://localhost:8080/orders
```

**검증**:
```bash
# Istio 설정 확인
kubectl get gateway,virtualservice,destinationrule -n backend

# VirtualService 상세 확인
kubectl get virtualservice user-service -n backend -o yaml
```

---

## 📊 Step 4: 관측성 도구 활용 (선택사항)

### Step 4-1: 관측성 도구 설치 확인

**목표**: Istio demo 프로파일에 포함된 관측성 도구 확인

```bash
# 관측성 도구 Pod 확인
kubectl get pods -n istio-system | grep -E "kiali|jaeger|prometheus|grafana"

# 예상 출력:
# grafana-xxx          1/1     Running
# istio-tracing-xxx    1/1     Running  (Jaeger)
# kiali-xxx            1/1     Running
# prometheus-xxx       1/1     Running
```

**만약 설치되지 않았다면**:
```bash
# Istio 샘플 애드온 설치
cd theory/week_04/day2/lab_scripts/handson1/istio-1.20.0
kubectl apply -f samples/addons/

# Pod 준비 대기
kubectl wait --for=condition=ready pod -l app=kiali -n istio-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=jaeger -n istio-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=prometheus -n istio-system --timeout=120s
```

### Step 4-2: Kiali 대시보드 (서비스 그래프)

```bash
# Kiali 포트 포워딩 (백그라운드)
kubectl port-forward -n istio-system svc/kiali 20001:20001 &

# 브라우저에서 접속
# http://localhost:20001
# Graph 메뉴에서 backend 네임스페이스 선택
```

### Step 4-3: Jaeger 분산 추적

```bash
# Jaeger 포트 포워딩 (백그라운드)
kubectl port-forward -n istio-system svc/tracing 16686:80 &

# 브라우저에서 접속
# http://localhost:16686
```

### Step 4-4: Prometheus 메트릭

```bash
# Prometheus 포트 포워딩 (백그라운드)
kubectl port-forward -n istio-system svc/prometheus 9090:9090 &

# 브라우저에서 접속
# http://localhost:9090
```

**포트 포워딩 종료**:
```bash
# 모든 port-forward 프로세스 종료
pkill -f "port-forward"

# 또는 jobs로 확인 후 개별 종료
jobs
kill %1  # job 번호에 따라
```

---

## 🚀 Step 5: 고급 Service Mesh 설정 (15분)

### Step 5-1: 프로덕션급 애플리케이션 배포
```bash
# 고급 User Service 배포 (리소스 제한, 헬스체크 포함)
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service-v1
  labels:
    app: user-service
    version: v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
      version: v1
  template:
    metadata:
      labels:
        app: user-service
        version: v1
    spec:
      containers:
      - name: user-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=User Service v1 - Production Ready"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# User Service v2 (카나리 배포용)
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service-v2
  labels:
    app: user-service
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: user-service
      version: v2
  template:
    metadata:
      labels:
        app: user-service
        version: v2
    spec:
      containers:
      - name: user-service
        image: hashicorp/http-echo:latest
        args:
        - "-text=User Service v2 - New Features"
        - "-listen=:8080"
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
EOF
```

### Step 5-2: 고급 Service Mesh 정책 설정
```bash
# 서킷 브레이커 설정
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: user-service-circuit-breaker
spec:
  host: user-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 10
      http:
        http1MaxPendingRequests: 10
        maxRequestsPerConnection: 2
    outlierDetection:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
EOF

# 재시도 정책 설정
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: user-service-retry
spec:
  hosts:
  - user-service
  http:
  - route:
    - destination:
        host: user-service
        subset: v1
      weight: 90
    - destination:
        host: user-service
        subset: v2
      weight: 10
    retries:
      attempts: 3
      perTryTimeout: 2s
    timeout: 10s
EOF
```

### Step 2-3: mTLS 보안 설정

```bash
# Strict mTLS 정책 적용
kubectl apply -n backend -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
EOF

# 인증 정책 확인
kubectl get peerauthentication
```

---

## 🔀 Step 3: 고급 트래픽 관리 & 카나리 배포 (20분)

### Step 3-1: 지능형 트래픽 라우팅
```bash
# 고급 Gateway 설정 (HTTPS 지원)
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: advanced-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "api.example.com"
    - "admin.example.com"
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: api-cert
    hosts:
    - "api.example.com"
EOF

# 헤더 기반 라우팅 (A/B 테스트)
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: user-service-ab-test
spec:
  hosts:
  - "api.example.com"
  gateways:
  - advanced-gateway
  http:
  # Beta 사용자는 v2로 라우팅
  - match:
    - headers:
        x-user-type:
          exact: beta
    route:
    - destination:
        host: user-service
        subset: v2
  # 일반 사용자는 90% v1, 10% v2
  - match:
    - uri:
        prefix: /users
    route:
    - destination:
        host: user-service
        subset: v1
      weight: 90
    - destination:
        host: user-service
        subset: v2
      weight: 10
    fault:
      delay:
        percentage:
          value: 0.1
        fixedDelay: 5s
EOF
```

### Step 3-2: 카나리 배포 자동화 테스트
```bash
# 트래픽 분산 테스트 (100회 요청)
for i in {1..100}; do
  curl -s -H "Host: api.example.com" http://localhost/users | grep -o "v[12]" || echo "error"
done | sort | uniq -c

# Beta 사용자 테스트
for i in {1..10}; do
  curl -s -H "Host: api.example.com" -H "x-user-type: beta" http://localhost/users
done

# 장애 주입 테스트
curl -w "@curl-format.txt" -H "Host: api.example.com" http://localhost/users
```

### Step 3-3: 실시간 메트릭 모니터링

```bash
# Istio 메트릭 확인
kubectl exec -n istio-system deployment/prometheus -- \
  promtool query instant 'istio_requests_total{destination_service_name="user-service"}'

# 성공률 확인
kubectl exec -n istio-system deployment/prometheus -- \
  promtool query instant 'rate(istio_requests_total{destination_service_name="user-service",response_code="200"}[1m])'
```

---

## 📊 Step 4: 관측성 및 보안 강화 (15분)

### Step 4-1: 분산 추적 설정
```bash
# Jaeger 추적 활성화
kubectl apply -n backend -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: control-plane
spec:
  values:
    pilot:
      traceSampling: 100.0
  meshConfig:
    defaultConfig:
      tracing:
        sampling: 100.0
EOF

# 추적 데이터 생성
for i in {1..50}; do
  curl -H "Host: api.example.com" http://localhost/users
  sleep 0.1
done
```

### Step 4-2: 보안 정책 강화

```bash
# 네임스페이스별 접근 제어
kubectl apply -n backend -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: user-service-policy
spec:
  selector:
    matchLabels:
      app: user-service
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/frontend/sa/frontend-sa"]
  - to:
    - operation:
        methods: ["GET", "POST"]
  - when:
    - key: request.headers[x-user-role]
      values: ["admin", "user"]
EOF

# Rate Limiting 설정
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: EnvoyFilter
metadata:
  name: rate-limit-filter
spec:
  workloadSelector:
    labels:
      app: user-service
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: SIDECAR_INBOUND
      listener:
        filterChain:
          filter:
            name: "envoy.filters.network.http_connection_manager"
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.filters.http.local_ratelimit
        typed_config:
          "@type": type.googleapis.com/udpa.type.v1.TypedStruct
          type_url: type.googleapis.com/envoy.extensions.filters.http.local_ratelimit.v3.LocalRateLimit
          value:
            stat_prefix: rate_limiter
            token_bucket:
              max_tokens: 100
              tokens_per_fill: 100
              fill_interval: 60s
EOF
```

---

## ✅ 고급 기능 검증 및 테스트 (10분)

### 종합 테스트 스크립트
```bash
# 1. 서킷 브레이커 테스트
echo "=== Circuit Breaker Test ==="
for i in {1..20}; do
  curl -s -w "%{http_code}\n" -H "Host: api.example.com" http://localhost/users -m 1
done

# 2. mTLS 검증
echo "=== mTLS Verification ==="
kubectl exec -n istio-system deployment/istiod -- \
  pilot-discovery proxy-config cluster user-service-v1-xxx.backend | grep tls

# 3. 메트릭 수집 확인
echo "=== Metrics Collection ==="
kubectl port-forward -n istio-system svc/prometheus 9090:9090 &
sleep 5
curl -s "http://localhost:9090/api/v1/query?query=istio_requests_total" | jq '.data.result[0].metric'

# 4. 분산 추적 확인
echo "=== Distributed Tracing ==="
kubectl port-forward -n istio-system svc/jaeger-query 16686:16686 &
sleep 5
echo "Jaeger UI: http://localhost:16686"

# 5. 보안 정책 테스트
echo "=== Security Policy Test ==="
kubectl exec -it deployment/user-service-v1 -- \
  curl -s user-service.backend.svc.cluster.local
```

### 성능 벤치마크

```bash
# Apache Bench를 이용한 성능 테스트
kubectl run ab-test --image=httpd:alpine --rm -it -- \
  ab -n 1000 -c 10 -H "Host: api.example.com" http://istio-ingressgateway.istio-system/users

# 결과 분석
kubectl logs ab-test | grep -E "(Requests per second|Time per request)"
```

# 100번 호출하여 트래픽 분산 확인
for i in {1..100}; do
  curl -s http://localhost:8080/users
done | sort | uniq -c
```

**예상 결과**:
```
  90 User Service v1 Response
  10 User Service v2 Response (NEW)
```

---

## 🔧 Step 4: 고급 기능 (15분)

### Step 4-1: Fault Injection (장애 주입)

**지연 주입 (Delay Injection)**:
```bash
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: product-service
spec:
  hosts:
  - product-service
  http:
  - fault:
      delay:
        percentage:
          value: 50
        fixedDelay: 5s
    route:
    - destination:
        host: product-service
EOF
```

**테스트**:
```bash
# 50% 확률로 5초 지연 발생
time curl http://localhost:8080/products
```

**에러 주입 (Abort Injection)**:
```bash
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: order-service
spec:
  hosts:
  - order-service
  http:
  - fault:
      abort:
        percentage:
          value: 30
        httpStatus: 500
    route:
    - destination:
        host: order-service
EOF
```

**테스트**:
```bash
# 30% 확률로 500 에러 발생
for i in {1..10}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/orders
done
```

### Step 4-2: Circuit Breaker 설정

```bash
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: product-service
spec:
  host: product-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 1
      http:
        http1MaxPendingRequests: 1
        maxRequestsPerConnection: 1
    outlierDetection:
      consecutiveErrors: 1
      interval: 1s
      baseEjectionTime: 3m
      maxEjectionPercent: 100
EOF
```

**테스트**:
```bash
# 동시 요청으로 Circuit Breaker 트리거
for i in {1..20}; do
  curl -s http://localhost:8080/products &
done
wait
```

### Step 4-3: Retry & Timeout 정책

```bash
kubectl apply -n backend -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: user-service
spec:
  hosts:
  - user-service
  http:
  - route:
    - destination:
        host: user-service
    retries:
      attempts: 3
      perTryTimeout: 2s
      retryOn: 5xx
    timeout: 10s
EOF
```

---

## 📊 Step 5: 관측성 (선택사항)

### Step 5-1: Kiali 대시보드

```bash
# Kiali 설치
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml

# Kiali 접근 (백그라운드)
kubectl port-forward -n istio-system svc/kiali 20001:20001 &

# 브라우저에서 접근
# http://localhost:20001
```

### Step 5-2: Jaeger 분산 추적

```bash
# Jaeger 설치
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/jaeger.yaml

# Jaeger 접근 (백그라운드)
kubectl port-forward -n istio-system svc/tracing 16686:80 &

# 브라우저에서 접근
# http://localhost:16686
```

### Step 5-3: Prometheus & Grafana

```bash
# Prometheus 설치
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml

# Grafana 설치
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml

# Grafana 접근 (백그라운드)
kubectl port-forward -n istio-system svc/grafana 3000:3000 &

# 브라우저에서 접근
# http://localhost:3000
```

**💡 Port Forward 종료**:
```bash
# 모든 port-forward 프로세스 종료
pkill -f "port-forward"

# 또는 개별 종료
jobs  # 백그라운드 작업 확인
kill %1  # 작업 번호로 종료
```

---

## ✅ 실습 체크포인트

### ✅ Istio 설치 확인
- [ ] Istiod 배포 완료
- [ ] Istio Ingress Gateway 실행 중
- [ ] default 네임스페이스 Sidecar 주입 활성화
- [ ] 모든 Pod에 2개 컨테이너 (app + istio-proxy)

### ✅ 트래픽 관리 확인
- [ ] Gateway 생성 완료
- [ ] VirtualService 설정 완료
- [ ] DestinationRule 설정 완료
- [ ] 카나리 배포 동작 확인 (90:10 비율)

### ✅ 고급 기능 확인
- [ ] Fault Injection 동작 확인
- [ ] Circuit Breaker 트리거 확인
- [ ] Retry & Timeout 정책 적용

### ✅ 관측성 확인 (선택)
- [ ] Kiali 서비스 그래프 확인
- [ ] Jaeger 분산 추적 확인
- [ ] Grafana 대시보드 확인

---

## 🧹 실습 정리

**🚀 자동화 스크립트 사용**
```bash
./cleanup.sh
```

**수동 정리**:
```bash
# Istio 리소스 삭제
kubectl delete gateway app-gateway
kubectl delete virtualservice --all
kubectl delete destinationrule --all

# 애플리케이션 삭제
kubectl delete deployment user-service-v1 user-service-v2 product-service order-service

# Istio 언인스톨
istioctl uninstall --purge -y

# Istio 네임스페이스 삭제
kubectl delete namespace istio-system

# Sidecar 주입 비활성화
kubectl label namespace default istio-injection-
```

---

## 💡 실습 회고

### 🤝 페어 회고 (5분)
1. **Kong vs Istio**: 두 도구의 가장 큰 차이점은?
2. **Sidecar 패턴**: Sidecar 주입의 장단점은?
3. **트래픽 관리**: 가장 유용한 기능은?
4. **실무 적용**: 어떤 상황에서 Istio를 선택하시겠어요?

### 📊 학습 성과
- **Istio 아키텍처**: Control Plane과 Data Plane 이해
- **Sidecar 패턴**: 자동 주입 및 투명한 프록시 체험
- **고급 트래픽 관리**: 카나리, Fault Injection, Circuit Breaker
- **관측성**: Kiali, Jaeger, Prometheus 통합 경험

### 🎯 Kong vs Istio 비교 정리

| 구분 | Kong | Istio |
|------|------|-------|
| **위치** | 클러스터 경계 (Edge) | 클러스터 내부 (Mesh) |
| **역할** | 외부 트래픽 관리 | 서비스 간 통신 관리 |
| **설치** | 간단 (단일 Gateway) | 복잡 (Control Plane + Sidecar) |
| **학습 곡선** | 낮음 ⭐⭐ | 높음 ⭐⭐⭐⭐⭐ |
| **기능** | API 관리 중심 | 전체 관측성 + 보안 |
| **성능 영향** | 낮음 (단일 홉) | 중간 (Sidecar 오버헤드) |
| **사용 시기** | API Gateway 필요 시 | 마이크로서비스 20개 이상 |

---

## ❓ FAQ (자주 묻는 질문)

### Q1. Sidecar가 자동 주입되지 않으면?
**A**: 
```bash
# 네임스페이스 라벨 확인
kubectl get namespace default -o yaml | grep istio-injection

# 라벨 추가
kubectl label namespace default istio-injection=enabled

# Pod 재시작 (Deployment 재배포)
kubectl rollout restart deployment user-service-v1 -n backend
```

### Q2. Istio Ingress Gateway 포트가 충돌하면?
**A**: 
- Kong과 Istio가 모두 30080 포트 사용
- Kong cleanup 후 Istio 설치 권장
- 또는 Istio Ingress Gateway 포트 변경

### Q3. VirtualService가 작동하지 않으면?
**A**: 
```bash
# Gateway 확인
kubectl get gateway

# VirtualService 확인
kubectl get virtualservice -n backend

# DestinationRule 확인
kubectl get destinationrule -n backend

# Istio 설정 검증
istioctl analyze
```

### Q4. Circuit Breaker가 트리거되지 않으면?
**A**: 
- `consecutiveErrors` 값 낮추기 (1로 설정)
- `maxConnections` 값 낮추기 (1로 설정)
- 충분한 동시 요청 생성 (20개 이상)

### Q5. Kiali 대시보드가 비어있으면?
**A**: 
- 트래픽 생성 필요 (서비스 호출)
- Prometheus 메트릭 수집 대기 (1-2분)
- 네임스페이스 필터 확인 (default 선택)

### Q6. Istio 제거 후에도 Sidecar가 남아있으면?
**A**: 
```bash
# Deployment 재배포
kubectl rollout restart deployment --all -n backend

# 또는 Pod 삭제 (자동 재생성)
kubectl delete pods --all -n backend
```

---

## 🌐 External Services 통합 (15분)

### Step 5-1: 외부 서비스 등록

```bash
# 외부 HTTP 서비스 등록 (httpbin.org)
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: httpbin-external
spec:
  hosts:
  - httpbin.org
  ports:
  - number: 80
    name: http
    protocol: HTTP
  - number: 443
    name: https
    protocol: HTTPS
  location: MESH_EXTERNAL
  resolution: DNS
EOF

# 외부 데이터베이스 서비스 등록 (시뮬레이션)
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: external-database
spec:
  hosts:
  - external-db.company.com
  ports:
  - number: 5432
    name: postgres
    protocol: TCP
  location: MESH_EXTERNAL
  resolution: DNS
EOF

# 외부 서비스용 DestinationRule
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: httpbin-external
spec:
  host: httpbin.org
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 5
      http:
        http1MaxPendingRequests: 5
        maxRequestsPerConnection: 1
    outlierDetection:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
EOF
```

### Step 5-2: 외부 서비스 접근 테스트

```bash
# 테스트용 Pod 생성
kubectl run test-client --image=curlimages/curl --rm -it -- sh

# Pod 내에서 실행
curl -I httpbin.org/get
curl -I https://httpbin.org/get

# 외부 서비스 메트릭 확인
exit
```

### Step 5-3: Egress Gateway 설정

```bash
# Egress Gateway 설정
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: istio-egressgateway
spec:
  selector:
    istio: egressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - httpbin.org
EOF

# Egress VirtualService
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: direct-httpbin-through-egress-gateway
spec:
  hosts:
  - httpbin.org
  gateways:
  - istio-egressgateway
  - mesh
  http:
  - match:
    - gateways:
      - mesh
      port: 80
    route:
    - destination:
        host: istio-egressgateway.istio-system.svc.cluster.local
        port:
          number: 80
      weight: 100
  - match:
    - gateways:
      - istio-egressgateway
      port: 80
    route:
    - destination:
        host: httpbin.org
        port:
          number: 80
      weight: 100
EOF
```

---

## 🔐 고급 보안 정책 (10분)

### Step 6-1: JWT 인증 설정

```bash
# JWT 인증 정책 설정
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: jwt-auth
spec:
  selector:
    matchLabels:
      app: user-service
  jwtRules:
  - issuer: "testing@secure.istio.io"
    jwksUri: "https://raw.githubusercontent.com/istio/istio/release-1.20/security/tools/jwt/samples/jwks.json"
EOF

# JWT 기반 인가 정책
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-jwt
spec:
  selector:
    matchLabels:
      app: user-service
  rules:
  - from:
    - source:
        requestPrincipals: ["testing@secure.istio.io/testing@secure.istio.io"]
EOF
```

### Step 6-2: JWT 토큰 테스트

```bash
# 유효한 JWT 토큰 생성 (테스트용)
TOKEN="eyJhbGciOiJSUzI1NiIsImtpZCI6IkRIRmJwb0lVcXJZOHQyenBBMnFYZkNtcjVWTzVaRXI0UnpIVV8tZW52dlEiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjQ2ODU5ODk3MDAsImZvbyI6ImJhciIsImlhdCI6MTUzMjM4OTcwMCwiaXNzIjoidGVzdGluZ0BzZWN1cmUuaXN0aW8uaW8iLCJzdWIiOiJ0ZXN0aW5nQHNlY3VyZS5pc3Rpby5pbyJ9.CfNnxWP2tcnR9q0vxyxweaF3ovQYHYZl82hAUsn21bwQd9zP7c-LS9qd_vpdLG4Tn1A15NxfCjp5f7QNBUo-KC9PJqYpgGbaXhaGx7bEdFWjcwv3nZzvc7M__ZpaCERdwU7igUmJqYGBYQ51vr2njU9ZimyKkfDe3axcyiBZde7G6dabliUosJvvKOPcKIWPccCgefSj_GNfwIip3-SsFdlR7BtbVUcqR-yv-XOxJ3Ry4c5p_-jpmHcMiKFyZnPczOavs2uSTyGiuFBfABRHZ9GhizOsgEGGCCgtfMpHjgJqiCOHdAhcHuWw"

# JWT 없이 요청 (실패해야 함)
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80 &
PF_PID=$!
sleep 5

curl -H "Host: api.example.com" http://localhost:8080/users

# JWT와 함께 요청 (성공해야 함)
curl -H "Host: api.example.com" -H "Authorization: Bearer $TOKEN" http://localhost:8080/users

kill $PF_PID
```

---

## 📈 성능 최적화 및 모니터링 (10분)

### Step 7-1: 고급 메트릭 설정

```bash
# 커스텀 메트릭 설정
kubectl apply -f - <<EOF
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: custom-metrics
spec:
  metrics:
  - providers:
    - name: prometheus
  - overrides:
    - match:
        metric: ALL_METRICS
      tagOverrides:
        request_id:
          value: "%{REQUEST_ID}"
        user_agent:
          value: "%{REQUEST_HEADERS['user-agent']}"
EOF

# 분산 추적 샘플링 조정
kubectl apply -f - <<EOF
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: tracing-config
spec:
  tracing:
  - providers:
    - name: jaeger
  - randomSamplingPercentage: 100.0
EOF
```

### Step 7-2: 성능 대시보드 설정

```bash
# Grafana 대시보드 접속
kubectl port-forward -n istio-system svc/grafana 3000:3000 &
GRAFANA_PID=$!

echo "Grafana 접속: http://localhost:3000"
echo "기본 계정: admin/admin"
echo ""
echo "추천 대시보드:"
echo "- Istio Service Dashboard"
echo "- Istio Workload Dashboard"
echo "- Istio Performance Dashboard"

# 성능 테스트 실행
kubectl run performance-test --image=fortio/fortio --rm -it -- \
  load -c 8 -qps 100 -t 60s -loglevel Warning \
  http://user-service.default.svc.cluster.local/

kill $GRAFANA_PID
```

---

## 🧹 실습 정리

### 완전한 환경 정리

```bash
# Istio 리소스 정리
kubectl delete virtualservice --all
kubectl delete destinationrule --all
kubectl delete gateway --all
kubectl delete serviceentry --all
kubectl delete authorizationpolicy --all
kubectl delete requestauthentication --all
kubectl delete peerauthentication --all
kubectl delete telemetry --all

# 애플리케이션 정리
kubectl delete deployment user-service-v1 user-service-v2 --ignore-not-found=true
kubectl delete service user-service --ignore-not-found=true

# 네임스페이스 라벨 제거
kubectl label namespace default istio-injection-

# Istio 제거 (선택사항)
istioctl uninstall --purge -y

# 포트 포워딩 정리
pkill -f "kubectl port-forward"

echo "✅ 모든 리소스 정리 완료"
```

---

## 💡 실습 회고

### 🤝 팀 회고 (15분)

**토론 주제**:
1. **Service Mesh의 가치**: Kong API Gateway와 비교했을 때 Istio의 장단점은?
2. **복잡성 vs 기능**: Service Mesh 도입 시 고려해야 할 트레이드오프는?
3. **실무 적용**: 어떤 상황에서 Service Mesh 도입을 권장하겠는가?
4. **운영 관점**: Service Mesh 운영 시 가장 중요한 모니터링 지표는?

### 📊 학습 성과

**기술적 성취**:
- ✅ **Istio 아키텍처**: Control Plane과 Data Plane 완전 이해
- ✅ **트래픽 관리**: 카나리 배포, A/B 테스트, 장애 주입
- ✅ **보안 강화**: mTLS, JWT 인증, 세밀한 접근 제어
- ✅ **관측성**: 분산 추적, 메트릭 수집, 시각화
- ✅ **외부 통합**: ServiceEntry, Egress Gateway 활용

**실무 역량**:
- 🎯 **아키텍처 설계**: 마이크로서비스 통신 패턴 설계
- 🔧 **운영 자동화**: Service Mesh 기반 배포 파이프라인
- 📊 **성능 최적화**: 트래픽 패턴 분석 및 최적화
- 🔐 **보안 강화**: Zero Trust 네트워크 구현
- 🚀 **확장성**: 대규모 마이크로서비스 환경 관리

### 🔮 다음 단계

**심화 학습 방향**:
- **Multi-Cluster Mesh**: 여러 클러스터 간 Service Mesh 연결
- **GitOps 통합**: ArgoCD와 Istio 통합 배포
- **Custom Envoy Filter**: 고급 트래픽 제어 로직 구현
- **Service Mesh Interface (SMI)**: 표준 인터페이스 활용

---

<div align="center">

**⛵ Istio Service Mesh** • **🔀 고급 트래픽 관리** • **📊 완전한 관측성** • **🌐 외부 서비스 통합**

*Service Mesh로 마이크로서비스 통신을 완전히 제어했습니다!*

</div>
