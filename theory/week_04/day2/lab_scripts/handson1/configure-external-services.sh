#!/bin/bash

# Week 4 Day 2 Hands-on 1: 외부 서비스 설정
# 사용법: ./configure-external-services.sh

echo "=== 외부 서비스 설정 시작 ==="

# 1. 외부 HTTP 서비스 등록 (httpbin.org)
echo "1. 외부 HTTP 서비스 등록 중..."
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

# 2. 외부 데이터베이스 서비스 등록 (시뮬레이션)
echo "2. 외부 데이터베이스 서비스 등록 중..."
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

# 3. 외부 서비스용 DestinationRule
echo "3. 외부 서비스용 DestinationRule 설정 중..."
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

# 4. Egress Gateway 설정
echo "4. Egress Gateway 설정 중..."
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

# 5. Egress VirtualService
echo "5. Egress VirtualService 설정 중..."
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

# 6. 설정 확인
echo "6. 설정 확인 중..."
sleep 10

echo "ServiceEntry 확인:"
kubectl get serviceentry

echo ""
echo "DestinationRule 확인:"
kubectl get destinationrule httpbin-external

echo ""
echo "Egress Gateway 확인:"
kubectl get gateway istio-egressgateway

echo ""
echo "=== 외부 서비스 설정 완료 ==="
echo ""
echo "설정된 외부 서비스:"
echo "- httpbin.org: HTTP/HTTPS 테스트 서비스"
echo "- external-db.company.com: 외부 데이터베이스 (시뮬레이션)"
echo ""
echo "테스트 방법:"
echo "kubectl run test-client --image=curlimages/curl --rm -it -- curl httpbin.org/get"
echo ""
echo "다음 단계: ./configure-jwt-auth.sh"
