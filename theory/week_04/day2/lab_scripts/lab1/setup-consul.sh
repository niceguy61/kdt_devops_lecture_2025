#!/bin/bash

# Week 4 Day 2 Lab 1: Consul 서비스 디스커버리 구축
# 사용법: ./setup-consul.sh

echo "=== Consul 서비스 디스커버리 구축 시작 ==="

# 기존 Consul 컨테이너 정리
echo "1. 기존 Consul 컨테이너 정리 중..."
docker stop consul-server 2>/dev/null || true
docker rm consul-server 2>/dev/null || true

# Consul 서버 실행
echo "2. Consul 서버 실행 중..."
docker run -d \
  --name consul-server \
  --network microservices-net \
  -p 8500:8500 \
  -p 8600:8600/udp \
  consul:1.15 \
  agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0

# Consul 시작 대기
echo "3. Consul 서버 시작 대기 중..."
sleep 10

# Consul 상태 확인
echo "4. Consul 상태 확인 중..."
if curl -s http://localhost:8500/v1/status/leader | grep -q '"'; then
    echo "✅ Consul 서버 정상 실행"
    echo ""
    echo "접속 정보:"
    echo "- Consul UI: http://localhost:8500/ui"
    echo "- API 엔드포인트: http://localhost:8500"
    echo ""
    echo "현재 노드 정보:"
    curl -s http://localhost:8500/v1/catalog/nodes | jq -r '.[] | "- 노드: \(.Node), 주소: \(.Address)"'
else
    echo "❌ Consul 서버 시작 실패"
    docker logs consul-server
    exit 1
fi

echo ""
echo "=== Consul 구축 완료 ==="
