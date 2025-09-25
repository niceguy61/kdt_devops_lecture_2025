#!/bin/bash
# Docker Compose 모니터링 스크립트

echo "🔍 Docker Compose 모니터링 대시보드"
echo "=================================="

while true; do
    clear
    echo "📊 $(date '+%Y-%m-%d %H:%M:%S') - Docker Compose 상태"
    echo "=================================="
    
    # 컨테이너 상태
    echo "📦 컨테이너 상태:"
    docker-compose ps
    echo ""
    
    # 리소스 사용량
    echo "💻 리소스 사용량:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" $(docker-compose ps -q)
    echo ""
    
    # 디스크 사용량
    echo "💾 볼륨 사용량:"
    docker system df
    echo ""
    
    # 네트워크 상태
    echo "🌐 네트워크 상태:"
    docker network ls | grep $(basename $(pwd))
    echo ""
    
    echo "⏰ 5초 후 새로고침... (Ctrl+C로 종료)"
    sleep 5
done