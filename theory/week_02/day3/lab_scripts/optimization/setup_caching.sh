#!/bin/bash

# Week 2 Day 3 Lab 1 - Phase 2: 캐싱 시스템 구축 스크립트
# 사용법: ./setup_caching.sh

echo "=== 캐싱 시스템 구축 시작 ==="
echo ""

echo "1. Docker Compose 파일 생성 중..."

# 최적화된 Docker Compose 파일 생성
cat > docker-compose.optimized.yml << 'EOF'
version: '3.8'
services:
  app:
    image: optimized-app:v1
    ports:
      - "3000:3000"
    depends_on:
      - redis
    read_only: true
    tmpfs:
      - /tmp:rw,noexec,nosuid,size=100m
      - /var/run:rw,noexec,nosuid,size=50m
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    security_opt:
      - no-new-privileges:true
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
        reservations:
          memory: 128M
          cpus: '0.25'
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --maxmemory 64mb --maxmemory-policy allkeys-lru --save ""
    deploy:
      resources:
        limits:
          memory: 128M
          cpus: '0.25'
        reservations:
          memory: 64M
          cpus: '0.1'
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

networks:
  default:
    driver: bridge
EOF

echo "✅ Docker Compose 파일 생성 완료"

echo ""
echo "2. 기존 컨테이너 정리 중..."

# 기존 컨테이너 정리
if docker ps -a | grep -q "optimized-app"; then
    docker stop optimized-app >/dev/null 2>&1
    docker rm optimized-app >/dev/null 2>&1
fi

echo "✅ 기존 컨테이너 정리 완료"

echo ""
echo "3. 캐싱 시스템 시작 중..."

# Docker Compose로 시스템 시작
docker-compose -f docker-compose.optimized.yml up -d

if [ $? -eq 0 ]; then
    echo "✅ 캐싱 시스템 시작 성공"
else
    echo "❌ 캐싱 시스템 시작 실패"
    exit 1
fi

echo ""
echo "4. 서비스 상태 확인 중..."

# 서비스 준비 대기
echo "서비스 준비 중..."
sleep 15

# 서비스 상태 확인
echo "=== 서비스 상태 ==="
docker-compose -f docker-compose.optimized.yml ps

# 헬스 체크
echo ""
echo "5. 헬스 체크 수행 중..."

APP_HEALTH=$(curl -s http://localhost:3000/health 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ 애플리케이션 헬스 체크 통과"
    echo "   응답: $APP_HEALTH"
else
    echo "❌ 애플리케이션 헬스 체크 실패"
    echo "애플리케이션 로그:"
    docker-compose -f docker-compose.optimized.yml logs app --tail 5
fi

# Redis 연결 확인
REDIS_PING=$(docker exec $(docker-compose -f docker-compose.optimized.yml ps -q redis) redis-cli ping 2>/dev/null)
if [ "$REDIS_PING" = "PONG" ]; then
    echo "✅ Redis 헬스 체크 통과"
else
    echo "❌ Redis 헬스 체크 실패"
    echo "Redis 로그:"
    docker-compose -f docker-compose.optimized.yml logs redis --tail 5
fi

echo ""
echo "6. 캐시 성능 테스트 수행 중..."

# Apache Bench 설치 확인
if ! command -v ab &> /dev/null; then
    echo "Apache Bench가 설치되지 않았습니다. 성능 테스트를 건너뜁니다."
else
    echo "=== 캐시 성능 테스트 (2000 요청, 20 동시) ==="
    ab -n 2000 -c 20 -q http://localhost:3000/load-test > cache_test.txt 2>&1
    
    if [ $? -eq 0 ]; then
        RPS_CACHE=$(grep "Requests per second" cache_test.txt | awk '{print $4}')
        TIME_PER_REQ_CACHE=$(grep "Time per request" cache_test.txt | head -1 | awk '{print $4}')
        FAILED_REQUESTS_CACHE=$(grep "Failed requests" cache_test.txt | awk '{print $3}')
        
        echo "✅ 캐시 성능 테스트 완료"
        echo "   - 초당 요청 수: $RPS_CACHE"
        echo "   - 요청당 시간: ${TIME_PER_REQ_CACHE}ms"
        echo "   - 실패한 요청: $FAILED_REQUESTS_CACHE"
        
        rm -f cache_test.txt
    else
        echo "❌ 캐시 성능 테스트 실패"
    fi
fi

echo ""
echo "7. Redis 상태 및 메모리 사용량 확인..."

# Redis 메모리 사용량 확인
echo "=== Redis 상태 ==="
REDIS_MEMORY=$(docker exec $(docker-compose -f docker-compose.optimized.yml ps -q redis) redis-cli info memory | grep used_memory_human | cut -d: -f2 | tr -d '\r')
REDIS_KEYS=$(docker exec $(docker-compose -f docker-compose.optimized.yml ps -q redis) redis-cli dbsize 2>/dev/null)

echo "Redis 메모리 사용량: $REDIS_MEMORY"
echo "Redis 키 개수: $REDIS_KEYS"

# 캐시 히트 테스트
echo ""
echo "8. 캐시 히트 테스트..."
echo "첫 번째 요청 (캐시 미스):"
time curl -s http://localhost:3000/load-test > /dev/null

echo "두 번째 요청 (캐시 히트):"
time curl -s http://localhost:3000/load-test > /dev/null

echo ""
echo "=== 캐싱 시스템 구축 완료 ==="
echo ""
echo "접속 정보:"
echo "- 애플리케이션: http://localhost:3000"
echo "- 헬스 체크: http://localhost:3000/health"
echo "- 부하 테스트: http://localhost:3000/load-test"
echo "- Redis: localhost:6379"
echo ""
echo "다음 단계: Phase 3 모니터링 시스템 구축"
echo ""