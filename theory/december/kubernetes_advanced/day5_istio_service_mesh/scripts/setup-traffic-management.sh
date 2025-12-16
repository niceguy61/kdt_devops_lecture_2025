#!/bin/bash

# Istio 트래픽 관리 설정 스크립트

echo "🚀 Istio 트래픽 관리 설정 시작..."
echo "=================================="

NAMESPACE="production"

# 네임스페이스 확인
if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
    echo "❌ 네임스페이스 '$NAMESPACE'가 존재하지 않습니다"
    exit 1
fi

# Istio 설치 확인
if ! kubectl get pods -n istio-system | grep -q "istiod"; then
    echo "❌ Istio가 설치되지 않았습니다"
    echo "   먼저 install-istio.sh를 실행하세요"
    exit 1
fi

echo "✅ 사전 조건 확인 완료"

# 1. Gateway 생성
echo -e "\n🌐 Istio Gateway 생성 중..."

cat > /tmp/frontend-gateway.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: frontend-gateway
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
EOF

kubectl apply -f /tmp/frontend-gateway.yaml

if [ $? -eq 0 ]; then
    echo "✅ Gateway 생성 완료"
else
    echo "❌ Gateway 생성 실패"
    exit 1
fi

# 2. VirtualService 생성 (프론트엔드)
echo -e "\n🔀 프론트엔드 VirtualService 생성 중..."

cat > /tmp/virtualservice-frontend.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: frontend-vs
  namespace: production
spec:
  hosts:
  - "*"
  gateways:
  - frontend-gateway
  http:
  - match:
    - uri:
        prefix: /api/
    route:
    - destination:
        host: backend-service
        port:
          number: 3000
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: frontend-service
        port:
          number: 80
EOF

kubectl apply -f /tmp/virtualservice-frontend.yaml

if [ $? -eq 0 ]; then
    echo "✅ 프론트엔드 VirtualService 생성 완료"
else
    echo "❌ 프론트엔드 VirtualService 생성 실패"
    exit 1
fi

# 3. DestinationRule 생성 (백엔드)
echo -e "\n⚖️  백엔드 DestinationRule 생성 중..."

cat > /tmp/destinationrule-backend.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: backend-dr
  namespace: production
spec:
  host: backend-service
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN
    connectionPool:
      tcp:
        maxConnections: 20
      http:
        http1MaxPendingRequests: 20
        http2MaxRequests: 100
        maxRequestsPerConnection: 5
        maxRetries: 3
    outlierDetection:
      consecutiveGatewayErrors: 5
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
  subsets:
  - name: v1
    labels:
      version: v1
    trafficPolicy:
      connectionPool:
        tcp:
          maxConnections: 10
        http:
          http1MaxPendingRequests: 10
          maxRequestsPerConnection: 2
  - name: v2
    labels:
      version: v2
    trafficPolicy:
      connectionPool:
        tcp:
          maxConnections: 20
        http:
          http1MaxPendingRequests: 20
          maxRequestsPerConnection: 5
EOF

kubectl apply -f /tmp/destinationrule-backend.yaml

if [ $? -eq 0 ]; then
    echo "✅ 백엔드 DestinationRule 생성 완료"
else
    echo "❌ 백엔드 DestinationRule 생성 실패"
    exit 1
fi

# 4. 백엔드 Pod에 버전 라벨 추가
echo -e "\n🏷️  백엔드 Pod에 버전 라벨 추가 중..."

# 기존 백엔드 Pod에 v1 라벨 추가
kubectl patch deployment backend-api -n "$NAMESPACE" -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1"}}}}}'

if [ $? -eq 0 ]; then
    echo "✅ 백엔드 Pod 버전 라벨 추가 완료"
else
    echo "❌ 백엔드 Pod 버전 라벨 추가 실패"
fi

# 5. 백엔드 VirtualService 생성 (트래픽 분할)
echo -e "\n🔀 백엔드 트래픽 분할 VirtualService 생성 중..."

cat > /tmp/virtualservice-backend.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend-vs
  namespace: production
spec:
  hosts:
  - backend-service
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: backend-service
        subset: v2
      weight: 100
  - route:
    - destination:
        host: backend-service
        subset: v1
      weight: 100
    timeout: 30s
    retries:
      attempts: 3
      perTryTimeout: 10s
      retryOn: gateway-error,connect-failure,refused-stream
EOF

kubectl apply -f /tmp/virtualservice-backend.yaml

if [ $? -eq 0 ]; then
    echo "✅ 백엔드 VirtualService 생성 완료"
else
    echo "❌ 백엔드 VirtualService 생성 실패"
    exit 1
fi

# 6. 설정 확인 및 검증
echo -e "\n🔍 Istio 설정 검증 중..."

# Istio 리소스 확인
echo "생성된 Istio 리소스:"
kubectl get gateway,virtualservice,destinationrule -n "$NAMESPACE"

# 설정 분석
echo -e "\n설정 분석 결과:"
istioctl analyze -n "$NAMESPACE"

if [ $? -eq 0 ]; then
    echo "✅ 설정 검증 통과"
else
    echo "⚠️  설정에 일부 문제가 있을 수 있습니다"
fi

# 7. 외부 접근 정보 확인
echo -e "\n🌐 외부 접근 정보 확인 중..."

INGRESS_HOST=$(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
INGRESS_PORT=$(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{.spec.ports[?(@.name=="http2")].port}' 2>/dev/null)

if [ ! -z "$INGRESS_HOST" ]; then
    GATEWAY_URL="http://$INGRESS_HOST:$INGRESS_PORT"
    echo "✅ Gateway URL: $GATEWAY_URL"
    
    # 기본 접근 테스트
    echo -e "\n🧪 기본 접근 테스트 중..."
    
    echo "프론트엔드 헬스체크:"
    curl -s -m 10 "$GATEWAY_URL/health" && echo " ✅" || echo " ❌"
    
    echo "백엔드 API 헬스체크:"
    curl -s -m 10 "$GATEWAY_URL/api/health" | jq -r '.status // "failed"' 2>/dev/null && echo " ✅" || echo " ❌"
    
else
    echo "⏳ LoadBalancer IP 할당 대기 중..."
    echo "   다음 명령어로 확인: kubectl get service istio-ingressgateway -n istio-system -w"
fi

# 8. 프록시 상태 확인
echo -e "\n🔍 Envoy 프록시 상태 확인:"
istioctl proxy-status

# 9. 사이드카 주입 상태 확인
echo -e "\n🔍 사이드카 주입 상태 확인:"
kubectl get pods -n "$NAMESPACE" -o wide

# 임시 파일 정리
rm -f /tmp/frontend-gateway.yaml /tmp/virtualservice-*.yaml /tmp/destinationrule-*.yaml

echo -e "\n🎯 Istio 트래픽 관리 설정 완료!"

echo -e "\n📋 설정된 트래픽 관리 구성:"
echo "1. Gateway: 외부 트래픽 진입점 (포트 80)"
echo "2. VirtualService: 라우팅 규칙"
echo "   - /api/* → backend-service:3000"
echo "   - /* → frontend-service:80"
echo "3. DestinationRule: 로드 밸런싱 및 연결 풀 설정"

echo -e "\n🧪 테스트 명령어:"
if [ ! -z "$GATEWAY_URL" ]; then
    echo "# 프론트엔드 접근"
    echo "curl $GATEWAY_URL/"
    echo ""
    echo "# API 접근"
    echo "curl $GATEWAY_URL/api/health"
    echo ""
    echo "# 카나리 테스트 (헤더 사용)"
    echo "curl -H \"canary: true\" $GATEWAY_URL/api/health"
fi

echo -e "\n📊 관측성 도구 접근:"
echo "# Kiali 대시보드"
echo "kubectl port-forward -n istio-system service/kiali 20001:20001"
echo "브라우저: http://localhost:20001"
echo ""
echo "# 트래픽 생성 (모니터링용)"
echo "while true; do curl -s $GATEWAY_URL/api/health > /dev/null; sleep 1; done"

echo -e "\n✨ 트래픽 관리 설정이 완료되었습니다!"
