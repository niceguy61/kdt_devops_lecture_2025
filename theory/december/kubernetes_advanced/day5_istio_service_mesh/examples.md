# Day 5 실습 예제 모음

## 🎯 목적
Day 5 세션에서 사용하는 모든 Istio 서비스 메시 명령어와 예제를 한 곳에 모아 챌린저들이 쉽게 참조할 수 있도록 합니다.

---

## 📋 Session 1 예제: Istio 설치 및 기본 설정

### Istio 설치

#### Istio CLI 설치
```bash
# 최신 Istio 다운로드
curl -L https://istio.io/downloadIstio | sh -

# 특정 버전 다운로드
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -

# 수동 다운로드 및 설치
wget https://github.com/istio/istio/releases/download/1.20.0/istio-1.20.0-linux-amd64.tar.gz
tar -xzf istio-1.20.0-linux-amd64.tar.gz
sudo mv istio-1.20.0/bin/istioctl /usr/local/bin/

# PATH 설정
export PATH=$PWD/istio-*/bin:$PATH
echo 'export PATH=$PWD/istio-*/bin:$PATH' >> ~/.bashrc

# 설치 확인
istioctl version
```

#### Istio Control Plane 설치
```bash
# 사전 검사
istioctl analyze

# 설치 프로필 확인
istioctl profile list

# Demo 프로필로 설치 (개발/테스트용)
istioctl install --set values.defaultRevision=default -y

# Production 프로필로 설치
istioctl install --set values.defaultRevision=default --set values.pilot.env.EXTERNAL_ISTIOD=false -y

# 커스텀 설정으로 설치
cat > istio-config.yaml << 'EOF'
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: control-plane
spec:
  values:
    defaultRevision: default
  components:
    pilot:
      k8s:
        resources:
          requests:
            cpu: 200m
            memory: 128Mi
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        service:
          type: LoadBalancer
EOF

istioctl install -f istio-config.yaml -y
```

#### 설치 확인
```bash
# Istio 시스템 Pod 확인
kubectl get pods -n istio-system

# Istio 서비스 확인
kubectl get services -n istio-system

# Istio 설정 확인
kubectl get istiooperator -n istio-system

# Istio 버전 확인
istioctl version

# 클러스터 상태 분석
istioctl analyze --all-namespaces
```

### 사이드카 주입

#### 자동 주입 설정
```bash
# 네임스페이스에 자동 주입 라벨 추가
kubectl label namespace default istio-injection=enabled
kubectl label namespace production istio-injection=enabled
kubectl label namespace staging istio-injection=enabled

# 라벨 확인
kubectl get namespace --show-labels | grep istio-injection

# 특정 네임스페이스 라벨 제거
kubectl label namespace default istio-injection-

# 자동 주입 비활성화
kubectl label namespace production istio-injection=disabled --overwrite
```

#### 수동 주입
```bash
# YAML 파일에 사이드카 수동 주입
istioctl kube-inject -f deployment.yaml | kubectl apply -f -

# 기존 Deployment에 사이드카 주입
kubectl get deployment myapp -o yaml | istioctl kube-inject -f - | kubectl apply -f -

# 파일에서 주입된 YAML 생성
istioctl kube-inject -f deployment.yaml -o injected-deployment.yaml
```

#### 사이드카 상태 확인
```bash
# Pod 사이드카 확인 (2/2 Ready 상태)
kubectl get pods

# 사이드카 컨테이너 상세 확인
kubectl describe pod POD_NAME

# Envoy 프록시 설정 확인
istioctl proxy-config bootstrap POD_NAME -n NAMESPACE

# 프록시 상태 확인
istioctl proxy-status

# 특정 Pod의 프록시 설정
istioctl proxy-config cluster POD_NAME -n NAMESPACE
istioctl proxy-config listener POD_NAME -n NAMESPACE
istioctl proxy-config route POD_NAME -n NAMESPACE
istioctl proxy-config endpoint POD_NAME -n NAMESPACE
```

---

## 📋 Session 2 예제: 트래픽 관리 및 관측성

### Gateway 설정

#### 기본 Gateway
```yaml
# basic-gateway.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: my-gateway
  namespace: production
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
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: my-tls-secret
    hosts:
    - "myapp.example.com"
```

#### 다중 호스트 Gateway
```yaml
# multi-host-gateway.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: multi-host-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http-api
      protocol: HTTP
    hosts:
    - "api.example.com"
  - port:
      number: 80
      name: http-web
      protocol: HTTP
    hosts:
    - "web.example.com"
  - port:
      number: 80
      name: http-admin
      protocol: HTTP
    hosts:
    - "admin.example.com"
```

### VirtualService 설정

#### 기본 라우팅
```yaml
# basic-virtualservice.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: my-app-vs
spec:
  hosts:
  - "*"
  gateways:
  - my-gateway
  http:
  - match:
    - uri:
        prefix: /api/v1/
    route:
    - destination:
        host: api-service
        port:
          number: 8080
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: web-service
        port:
          number: 80
```

#### 고급 라우팅 (헤더, 쿼리 파라미터)
```yaml
# advanced-routing.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: advanced-routing
spec:
  hosts:
  - api.example.com
  http:
  - match:
    - headers:
        version:
          exact: v2
    - queryParams:
        debug:
          exact: "true"
    route:
    - destination:
        host: api-service
        subset: v2
  - match:
    - uri:
        regex: "^/api/v[0-9]+/users/[0-9]+$"
    route:
    - destination:
        host: user-service
  - route:
    - destination:
        host: api-service
        subset: v1
```

#### 트래픽 분할 (카나리 배포)
```yaml
# canary-deployment.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: canary-vs
spec:
  hosts:
  - my-service
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: my-service
        subset: v2
      weight: 100
  - route:
    - destination:
        host: my-service
        subset: v1
      weight: 90
    - destination:
        host: my-service
        subset: v2
      weight: 10
```

#### 재시도 및 타임아웃
```yaml
# retry-timeout.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: retry-timeout-vs
spec:
  hosts:
  - my-service
  http:
  - route:
    - destination:
        host: my-service
    timeout: 30s
    retries:
      attempts: 3
      perTryTimeout: 10s
      retryOn: gateway-error,connect-failure,refused-stream
```

### DestinationRule 설정

#### 기본 로드 밸런싱
```yaml
# basic-destinationrule.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: my-service-dr
spec:
  host: my-service
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN  # ROUND_ROBIN, LEAST_CONN, RANDOM, PASSTHROUGH
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

#### 연결 풀 및 서킷 브레이커
```yaml
# circuit-breaker.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: circuit-breaker-dr
spec:
  host: my-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 10
      http:
        http1MaxPendingRequests: 10
        http2MaxRequests: 100
        maxRequestsPerConnection: 2
        maxRetries: 3
        consecutiveGatewayErrors: 5
        interval: 30s
        baseEjectionTime: 30s
        maxEjectionPercent: 50
    outlierDetection:
      consecutiveGatewayErrors: 5
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
      minHealthPercent: 30
```

#### mTLS 설정
```yaml
# mtls-destinationrule.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: mtls-dr
spec:
  host: "*.production.svc.cluster.local"
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
---
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: production
spec:
  mtls:
    mode: STRICT
```

### 보안 정책

#### 인증 정책
```yaml
# authentication-policy.yaml
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: jwt-auth
  namespace: production
spec:
  selector:
    matchLabels:
      app: my-app
  jwtRules:
  - issuer: "https://accounts.google.com"
    jwksUri: "https://www.googleapis.com/oauth2/v3/certs"
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-jwt
  namespace: production
spec:
  selector:
    matchLabels:
      app: my-app
  action: ALLOW
  rules:
  - from:
    - source:
        requestPrincipals: ["*"]
```

#### 네트워크 정책
```yaml
# network-authorization.yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  {}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-frontend
  namespace: production
spec:
  selector:
    matchLabels:
      app: backend
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/frontend"]
  - to:
    - operation:
        methods: ["GET", "POST"]
```

### 관측성 설정

#### Telemetry 설정
```yaml
# telemetry-config.yaml
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: metrics-config
  namespace: production
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
    - match:
        metric: REQUEST_COUNT
      disabled: false
```

#### 분산 추적
```yaml
# tracing-config.yaml
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: tracing-config
spec:
  tracing:
  - providers:
    - name: jaeger
  - customTags:
      my_tag:
        literal:
          value: "my_value"
      user_id:
        header:
          name: "x-user-id"
```

---

## 🔧 유용한 Istio 명령어 모음

### 설정 관리

#### 설정 확인
```bash
# Istio 설정 검증
istioctl analyze
istioctl analyze --all-namespaces
istioctl analyze -n production

# 특정 리소스 검증
istioctl analyze gateway/my-gateway -n production
istioctl analyze virtualservice/my-vs -n production

# 설정 동기화 확인
istioctl proxy-status
```

#### 프록시 설정 확인
```bash
# 클러스터 설정
istioctl proxy-config cluster POD_NAME -n NAMESPACE

# 리스너 설정
istioctl proxy-config listener POD_NAME -n NAMESPACE

# 라우트 설정
istioctl proxy-config route POD_NAME -n NAMESPACE

# 엔드포인트 설정
istioctl proxy-config endpoint POD_NAME -n NAMESPACE

# 시크릿 설정
istioctl proxy-config secret POD_NAME -n NAMESPACE

# 전체 설정 덤프
istioctl proxy-config all POD_NAME -n NAMESPACE
```

### 디버깅

#### 로그 확인
```bash
# Istiod 로그
kubectl logs -n istio-system deployment/istiod

# Ingress Gateway 로그
kubectl logs -n istio-system deployment/istio-ingressgateway

# 사이드카 프록시 로그
kubectl logs POD_NAME -c istio-proxy -n NAMESPACE

# 실시간 로그 모니터링
kubectl logs -f -l app=my-app -c istio-proxy -n production
```

#### 메트릭 확인
```bash
# Envoy 관리 인터페이스 접근
kubectl port-forward POD_NAME 15000:15000 -n NAMESPACE

# 통계 확인
curl http://localhost:15000/stats
curl http://localhost:15000/stats/prometheus

# 설정 확인
curl http://localhost:15000/config_dump

# 클러스터 상태
curl http://localhost:15000/clusters

# 리스너 상태
curl http://localhost:15000/listeners
```

#### 트래픽 추적
```bash
# 요청 추적 활성화
kubectl exec POD_NAME -c istio-proxy -n NAMESPACE -- \
  curl -X POST http://localhost:15000/logging?level=trace

# 특정 경로 추적
kubectl exec POD_NAME -c istio-proxy -n NAMESPACE -- \
  curl -X POST "http://localhost:15000/logging?paths=http,router,config:trace"

# 추적 비활성화
kubectl exec POD_NAME -c istio-proxy -n NAMESPACE -- \
  curl -X POST http://localhost:15000/logging?level=warning
```

### 관측성 도구

#### Kiali 설치 및 접근
```bash
# Kiali 설치
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml

# Kiali 대시보드 접근
kubectl port-forward -n istio-system service/kiali 20001:20001

# 브라우저에서 http://localhost:20001 접근
```

#### Prometheus 및 Grafana
```bash
# Prometheus 설치
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml

# Grafana 설치
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml

# Grafana 대시보드 접근
kubectl port-forward -n istio-system service/grafana 3000:3000

# Prometheus 접근
kubectl port-forward -n istio-system service/prometheus 9090:9090
```

#### Jaeger 분산 추적
```bash
# Jaeger 설치
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/jaeger.yaml

# Jaeger UI 접근
kubectl port-forward -n istio-system service/jaeger 16686:16686

# 브라우저에서 http://localhost:16686 접근
```

---

## 🚨 트러블슈팅 가이드

### 일반적인 문제들

#### 사이드카 주입 문제
```bash
# 문제: 사이드카가 주입되지 않음
# 해결: 네임스페이스 라벨 확인
kubectl get namespace NAMESPACE --show-labels
kubectl label namespace NAMESPACE istio-injection=enabled

# 문제: Pod가 1/2 Ready 상태
# 해결: 사이드카 로그 확인
kubectl logs POD_NAME -c istio-proxy
kubectl describe pod POD_NAME
```

#### Gateway 접근 문제
```bash
# 문제: Gateway를 통한 접근 불가
# 해결: LoadBalancer IP 및 포트 확인
kubectl get service istio-ingressgateway -n istio-system
kubectl describe service istio-ingressgateway -n istio-system

# Gateway 설정 확인
kubectl describe gateway GATEWAY_NAME -n NAMESPACE
istioctl analyze gateway/GATEWAY_NAME -n NAMESPACE
```

#### VirtualService 라우팅 문제
```bash
# 문제: 라우팅이 작동하지 않음
# 해결: VirtualService 설정 확인
kubectl describe virtualservice VS_NAME -n NAMESPACE
istioctl analyze virtualservice/VS_NAME -n NAMESPACE

# 프록시 라우트 설정 확인
istioctl proxy-config route POD_NAME -n NAMESPACE
```

#### 서비스 간 통신 문제
```bash
# 문제: 서비스 간 통신 실패
# 해결: mTLS 설정 확인
istioctl authn tls-check POD_NAME.NAMESPACE.svc.cluster.local

# DestinationRule 확인
kubectl describe destinationrule DR_NAME -n NAMESPACE

# 엔드포인트 확인
istioctl proxy-config endpoint POD_NAME -n NAMESPACE
```

#### 성능 문제
```bash
# 문제: 응답 시간 증가
# 해결: 연결 풀 설정 확인
kubectl describe destinationrule DR_NAME -n NAMESPACE

# Envoy 통계 확인
kubectl exec POD_NAME -c istio-proxy -- \
  curl -s http://localhost:15000/stats | grep -E "(upstream|downstream)"

# 서킷 브레이커 상태 확인
kubectl exec POD_NAME -c istio-proxy -- \
  curl -s http://localhost:15000/stats | grep outlier_detection
```

### 설정 검증

#### 전체 설정 검증
```bash
# 모든 네임스페이스 분석
istioctl analyze --all-namespaces

# 특정 네임스페이스 분석
istioctl analyze -n production

# 설정 파일 분석
istioctl analyze -f my-config.yaml

# 프록시 동기화 상태 확인
istioctl proxy-status
```

#### 메트릭 및 로그 모니터링
```bash
# 실시간 메트릭 모니터링
watch -n 2 'kubectl top pods -n production'

# 트래픽 패턴 분석
kubectl exec POD_NAME -c istio-proxy -- \
  curl -s http://localhost:15000/stats | grep -E "inbound|outbound" | head -20

# 에러율 모니터링
kubectl exec POD_NAME -c istio-proxy -- \
  curl -s http://localhost:15000/stats | grep -E "5xx|4xx"
```

이 예제 모음을 통해 챌린저들이 Istio 서비스 메시를 완벽하게 활용할 수 있을 것입니다!
