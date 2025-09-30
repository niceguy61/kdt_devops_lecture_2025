#!/bin/bash

echo "=== 에러 시나리오 테스트 시작 ==="

echo "1. 다양한 에러 생성..."
curl -s http://localhost:4000/error/500 > /dev/null &
curl -s http://localhost:4000/error/404 > /dev/null &
curl -s http://localhost:4000/error/random > /dev/null &

echo "2. 부하 생성..."
for i in {1..5}; do
  curl -s http://localhost:4000/load/cpu > /dev/null &
  curl -s http://localhost:4000/load/memory > /dev/null &
done

echo "3. 데이터베이스 연결 시뮬레이션..."
curl -s http://localhost:4000/db/connect > /dev/null
curl -s http://localhost:4000/db/connect > /dev/null

echo "4. 메시지 큐 시뮬레이션..."
curl -s -X POST -H "Content-Type: application/json" -d '{"count":10}' http://localhost:4000/queue/add > /dev/null
curl -s -X POST http://localhost:4000/queue/process > /dev/null

echo "5. 랜덤 에러 생성 (30초간)..."
for i in {1..30}; do
  curl -s http://localhost:4000/error/random > /dev/null &
  sleep 1
done

wait

echo "✅ 에러 시나리오 테스트 완료"
echo "Prometheus에서 메트릭 확인: http://localhost:9090"
echo "Grafana에서 대시보드 확인: http://localhost:3001"
