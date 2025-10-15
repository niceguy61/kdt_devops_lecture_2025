#!/bin/bash

# Week 3 Day 3 Lab 1: 고급 부하테스트 (Apache Bench 사용)
# 목적: 정확한 성능 메트릭 수집

echo "=== 고급 부하테스트 시작 ==="

# Apache Bench 테스트 Pod 생성
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: load-test-ab
  labels:
    app: load-test
spec:
  containers:
  - name: apache-bench
    image: httpd:2.4-alpine
    command: ["/bin/sh"]
    args: ["-c", "apk add --no-cache apache2-utils && sleep 3600"]
  restartPolicy: Never
EOF

echo "1. Apache Bench Pod 준비 중..."
kubectl wait --for=condition=Ready pod/load-test-ab --timeout=60s

# Frontend 서비스 IP 확인
FRONTEND_IP=$(kubectl get svc frontend-service -o jsonpath='{.spec.clusterIP}')
echo "Frontend IP: $FRONTEND_IP"

# 테스트 시나리오 실행
echo "2. 부하테스트 시나리오 실행 중..."

echo "📊 시나리오 1: 기본 성능 테스트"
kubectl exec load-test-ab -- ab -n 1000 -c 10 http://$FRONTEND_IP/

echo "📊 시나리오 2: 동시 접속 증가 테스트"
kubectl exec load-test-ab -- ab -n 2000 -c 50 http://$FRONTEND_IP/

echo "📊 시나리오 3: 고부하 스트레스 테스트"
kubectl exec load-test-ab -- ab -n 5000 -c 100 http://$FRONTEND_IP/

# 리소스 모니터링
echo "3. 리소스 사용량 모니터링..."
kubectl top pods
kubectl top nodes

# 정리
echo "4. 테스트 환경 정리..."
kubectl delete pod load-test-ab

echo ""
echo "=== 고급 부하테스트 완료 ==="
