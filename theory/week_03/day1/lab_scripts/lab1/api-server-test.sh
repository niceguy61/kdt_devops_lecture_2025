#!/bin/bash

# API Server 직접 호출 테스트 스크립트

echo "=== API Server Direct Access Test ==="

echo "1. Getting Authentication Token..."

# ServiceAccount 토큰 획득
TOKEN=$(kubectl get secret -n kube-system \
  $(kubectl get serviceaccount default -n kube-system -o jsonpath='{.secrets[0].name}') \
  -o jsonpath='{.data.token}' | base64 -d)

# API Server 주소 확인
API_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
echo "API Server: $API_SERVER"

echo "2. Testing Direct API Calls..."

# 직접 API 호출 테스트
echo "Getting pods in lab-day1 namespace:"
curl -k -H "Authorization: Bearer $TOKEN" \
  $API_SERVER/api/v1/namespaces/lab-day1/pods

echo -e "\n3. Checking API Versions..."

# API 버전 확인
echo "Available API versions:"
curl -k -H "Authorization: Bearer $TOKEN" \
  $API_SERVER/api

echo -e "\n4. Collecting API Metrics..."

# 메트릭 엔드포인트 확인
echo "API Server metrics (first 20 lines):"
curl -k -H "Authorization: Bearer $TOKEN" \
  $API_SERVER/metrics | head -20

echo -e "\n5. Analyzing Performance Metrics..."

# API Server 메트릭 수집
curl -k -H "Authorization: Bearer $TOKEN" \
  $API_SERVER/metrics > api-metrics.txt

# 주요 메트릭 분석
echo "=== API Server Request Duration ==="
grep "apiserver_request_duration_seconds" api-metrics.txt | head -10

echo "=== API Server Request Total ==="
grep "apiserver_request_total" api-metrics.txt | head -10

echo "=== ETCD Request Duration ==="
grep "etcd_request_duration_seconds" api-metrics.txt | head -10

echo "API Server test completed!"
echo "Metrics saved to api-metrics.txt"