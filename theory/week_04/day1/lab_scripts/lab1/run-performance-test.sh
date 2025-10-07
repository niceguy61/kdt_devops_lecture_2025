#!/bin/bash

# Week 4 Day 1 Lab 1: 성능 테스트 실행
# 사용법: ./run-performance-test.sh

echo "=== 성능 테스트 시작 ==="
echo ""

set -e

echo "1/4 부하 테스트 도구 배포 중..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load-tester
  namespace: testing
spec:
  replicas: 1
  selector:
    matchLabels:
      app: load-tester
  template:
    metadata:
      labels:
        app: load-tester
    spec:
      containers:
      - name: load-tester
        image: alpine/curl:latest
        command: ["/bin/sh"]
        args: ["-c", "while true; do sleep 3600; done"]
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
EOF

echo "✅ 부하 테스트 도구 배포 완료"

echo ""
echo "2/4 테스트 도구 준비 대기 중..."
kubectl wait --for=condition=ready pod -l app=load-tester -n testing --timeout=60s

# 테스트 Pod 이름 가져오기
TESTER_POD=$(kubectl get pods -n testing -l app=load-tester -o jsonpath='{.items[0].metadata.name}')
echo "✅ 테스트 Pod 준비 완료: $TESTER_POD"

echo ""
echo "3/4 모놀리스 성능 테스트 실행 중..."
echo "--- 모놀리스 /api/users 테스트 ---"
kubectl exec -n testing $TESTER_POD -- sh -c "
    for i in \$(seq 1 100); do
        curl -s -w 'Response time: %{time_total}s\n' -o /dev/null http://monolith-service.ecommerce-monolith.svc.cluster.local/api/users
        sleep 0.1
    done
" | tee /tmp/monolith-results.txt

echo ""
echo "--- 모놀리스 /api/products 테스트 ---"
kubectl exec -n testing $TESTER_POD -- sh -c "
    for i in \$(seq 1 50); do
        curl -s -w 'Response time: %{time_total}s\n' -o /dev/null http://monolith-service.ecommerce-monolith.svc.cluster.local/api/products
        sleep 0.1
    done
"

echo ""
echo "4/4 마이크로서비스 성능 테스트 실행 중..."
echo "--- 마이크로서비스 /api/users 테스트 ---"
kubectl exec -n testing $TESTER_POD -- sh -c "
    for i in \$(seq 1 10); do
        curl -s -w 'Response time: %{time_total}s\n' -o /dev/null http://user-service.ecommerce-microservices.svc.cluster.local/api/users
        sleep 0.1
    done
" | tee /tmp/microservice-results.txt

echo ""
echo "=== 성능 테스트 완료 ==="
echo ""
echo "📊 성능 비교 요약:"
echo ""
echo "모놀리스 평균 응답 시간:"
if [ -f /tmp/monolith-results.txt ]; then
    grep "Response time" /tmp/monolith-results.txt | awk '{sum+=$3; count++} END {printf "%.4fs\n", sum/count}'
else
    echo "데이터 없음"
fi

echo ""
echo "마이크로서비스 평균 응답 시간:"
if [ -f /tmp/microservice-results.txt ]; then
    grep "Response time" /tmp/microservice-results.txt | awk '{sum+=$3; count++} END {printf "%.4fs\n", sum/count}'
else
    echo "데이터 없음"
fi

echo ""
echo "📈 리소스 사용량:"
echo ""
echo "모놀리스 리소스 사용량:"
kubectl top pods -n ecommerce-monolith 2>/dev/null || echo "메트릭 서버가 필요합니다"

echo ""
echo "마이크로서비스 리소스 사용량:"
kubectl top pods -n ecommerce-microservices 2>/dev/null || echo "메트릭 서버가 필요합니다"

echo ""
echo "다음 단계: ./analyze-architecture.sh 실행"
