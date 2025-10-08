#!/bin/bash

# Week 4 Day 2 Lab 1: Kong API Gateway 구축
# 사용법: ./setup-kong.sh

echo "=== Kong API Gateway 구축 시작 ==="

# 기존 Kong 컨테이너 정리
echo "1. 기존 Kong 컨테이너 정리 중..."
docker stop kong-gateway kong-database 2>/dev/null || true
docker rm kong-gateway kong-database 2>/dev/null || true

# Kong 전용 PostgreSQL 실행
echo "2. Kong 데이터베이스 실행 중..."
docker run -d \
  --name kong-database \
  --network microservices-net \
  -e POSTGRES_USER=kong \
  -e POSTGRES_DB=kong \
  -e POSTGRES_PASSWORD=kong \
  postgres:13

# PostgreSQL 시작 대기
echo "3. 데이터베이스 시작 대기 중..."
sleep 10

# Kong 데이터베이스 마이그레이션
echo "4. Kong 데이터베이스 마이그레이션 중..."
docker run --rm \
  --network microservices-net \
  -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=kong-database \
  -e KONG_PG_USER=kong \
  -e KONG_PG_PASSWORD=kong \
  kong:3.4 kong migrations bootstrap

if [ $? -eq 0 ]; then
    echo "✅ 데이터베이스 마이그레이션 완료"
else
    echo "❌ 데이터베이스 마이그레이션 실패"
    exit 1
fi

# Kong Gateway 실행
echo "5. Kong Gateway 실행 중..."
docker run -d \
  --name kong-gateway \
  --network microservices-net \
  -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=kong-database \
  -e KONG_PG_USER=kong \
  -e KONG_PG_PASSWORD=kong \
  -e KONG_PROXY_ACCESS_LOG=/dev/stdout \
  -e KONG_ADMIN_ACCESS_LOG=/dev/stdout \
  -e KONG_PROXY_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_LISTEN=0.0.0.0:8001 \
  -e KONG_ADMIN_GUI_URL=http://localhost:8002 \
  -p 8000:8000 \
  -p 8001:8001 \
  -p 8002:8002 \
  kong:3.4

# Kong 시작 대기
echo "6. Kong Gateway 시작 대기 중..."
sleep 15

# Kong 상태 확인
echo "7. Kong Gateway 상태 확인 중..."
if curl -s http://localhost:8001/ | grep -q "version"; then
    echo "✅ Kong Gateway 정상 실행"
    echo ""
    echo "Kong 정보:"
    curl -s http://localhost:8001/ | jq -r '"- 버전: \(.version)", "- 노드 ID: \(.node_id)"'
    echo ""
    echo "접속 정보:"
    echo "- Proxy: http://localhost:8000"
    echo "- Admin API: http://localhost:8001"
    echo "- Manager UI: http://localhost:8002"
else
    echo "❌ Kong Gateway 시작 실패"
    docker logs kong-gateway
    exit 1
fi

# Kong Manager 설정 (선택사항)
echo "8. Kong Manager 설정 중..."
curl -s -X POST http://localhost:8001/workspaces \
  --data "name=microservices" \
  --data "comment=Microservices workspace" > /dev/null

echo ""
echo "=== Kong API Gateway 구축 완료 ==="
