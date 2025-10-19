#!/bin/bash

# Week 4 Day 1 Lab 1: 성능 테스트
# 사용법: ./performance-test.sh

echo "=== 마이크로서비스 아키텍처 성능 테스트 ==="
echo ""

# 테스트용 Pod 생성
kubectl run performance-test --image=curlimages/curl --rm -it --restart=Never -- sh -c "
echo '=== 기본 성능 테스트 ==='
echo 'Testing 100 requests to each service...'
echo ''

echo '1. 사용자 서비스 테스트:'
time for i in \$(seq 1 10); do
  curl -s -H 'Host: ecommerce.local' http://ingress-nginx-controller.ingress-nginx.svc.cluster.local/api/users > /dev/null
done

echo '2. 상품 서비스 테스트:'
time for i in \$(seq 1 10); do
  curl -s -H 'Host: ecommerce.local' http://ingress-nginx-controller.ingress-nginx.svc.cluster.local/api/products > /dev/null
done

echo '3. 주문 서비스 테스트:'
time for i in \$(seq 1 10); do
  curl -s -H 'Host: ecommerce.local' http://ingress-nginx-controller.ingress-nginx.svc.cluster.local/api/orders > /dev/null
done

echo ''
echo '=== 동시 요청 테스트 ==='
echo 'Testing concurrent requests...'

# 백그라운드로 동시 요청 실행
for i in \$(seq 1 5); do
  curl -s -H 'Host: ecommerce.local' http://ingress-nginx-controller.ingress-nginx.svc.cluster.local/api/users > /dev/null &
  curl -s -H 'Host: ecommerce.local' http://ingress-nginx-controller.ingress-nginx.svc.cluster.local/api/products > /dev/null &
  curl -s -H 'Host: ecommerce.local' http://ingress-nginx-controller.ingress-nginx.svc.cluster.local/api/orders > /dev/null &
done

wait
echo 'Concurrent test completed!'
"
