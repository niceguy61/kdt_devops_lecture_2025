#!/bin/bash

echo "=== Error Test App 부하 테스트 시나리오 ==="

# 시나리오 1: 정상 트래픽
echo "1. 정상 트래픽 시뮬레이션 (30초)..."
ab -n 300 -c 5 -t 30 http://localhost:4000/ > /dev/null 2>&1 &

# 시나리오 2: 에러 발생 트래픽
echo "2. 에러 발생 트래픽 (20초)..."
sleep 5
for i in {1..20}; do
  curl -s http://localhost:4000/error/500 > /dev/null &
  curl -s http://localhost:4000/error/random > /dev/null &
  sleep 1
done

# 시나리오 3: CPU 집약적 부하
echo "3. CPU 집약적 부하 테스트 (15초)..."
sleep 10
for i in {1..5}; do
  curl -s http://localhost:4000/load/cpu > /dev/null &
done

# 시나리오 4: 메모리 집약적 부하
echo "4. 메모리 집약적 부하 테스트 (10초)..."
sleep 5
for i in {1..3}; do
  curl -s http://localhost:4000/load/memory > /dev/null &
done

# 시나리오 5: 데이터베이스 연결 시뮬레이션
echo "5. 데이터베이스 연결 시뮬레이션..."
for i in {1..10}; do
  curl -s http://localhost:4000/db/connect > /dev/null
  sleep 2
done

# 시나리오 6: 메시지 큐 부하
echo "6. 메시지 큐 부하 테스트..."
curl -s -X POST -H "Content-Type: application/json" -d '{"count":25}' http://localhost:4000/queue/add > /dev/null
sleep 5
curl -s -X POST http://localhost:4000/queue/process > /dev/null

echo "✅ 모든 부하 테스트 시나리오 완료"
echo ""
echo "Grafana에서 다음 대시보드를 확인하세요:"
echo "- Error Test App Monitoring"
echo "- Load Test & Performance Dashboard"
echo "- Container Monitoring Dashboard"
