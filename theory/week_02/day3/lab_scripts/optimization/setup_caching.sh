#!/bin/bash

# Week 2 Day 3 Lab 1: 캐싱 시스템 구축 스크립트
# 사용법: ./setup_caching.sh

echo "=== 캐싱 시스템 구축 시작 ==="

echo "1. Redis 캐시 시스템 설정..."

# 최적화된 Docker Compose 파일 생성
cat > docker-compose.optimized.yml << 'EOF'
version: '3.8'

services:
  app:
    image: optimized-app:v1
    container_name: optimized-app-cached
    ports:
      - "3000:3000"
    depends_on:
      - redis
    environment:
      - NODE_ENV=production
      - REDIS_URL=redis://redis:6379
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
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  redis:
    image: redis:7-alpine
    container_name: redis-cache
    ports:
      - "6379:6379"
    command: >
      redis-server 
      --maxmemory 64mb 
      --maxmemory-policy allkeys-lru
      --save 60 1000
      --appendonly yes
      --appendfsync everysec
    volumes:
      - redis-data:/data
    deploy:
      resources:
        limits:
          memory: 128M
          cpus: '0.25'
        reservations:
          memory: 64M
          cpus: '0.1'
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  redis-data:
    driver: local

networks:
  default:
    name: optimized-app-network
    driver: bridge
EOF

echo "✅ Docker Compose 설정 완료"

echo ""
echo "2. 기존 컨테이너 정리..."

# 기존 컨테이너 정리
docker stop optimized-app > /dev/null 2>&1
docker rm optimized-app > /dev/null 2>&1

echo "✅ 기존 컨테이너 정리 완료"

echo ""
echo "3. 캐시 시스템 시작..."

# 캐시 시스템 시작
docker-compose -f docker-compose.optimized.yml up -d

echo "서비스 시작 중..."
sleep 15

# 서비스 상태 확인
echo ""
echo "4. 서비스 상태 확인..."
docker-compose -f docker-compose.optimized.yml ps

echo ""
echo "5. 헬스체크 확인..."

# 애플리케이션 헬스체크
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ 애플리케이션 정상 동작"
    
    # 헬스체크 상세 정보
    curl -s http://localhost:3000/health | jq . 2>/dev/null || curl -s http://localhost:3000/health
else
    echo "❌ 애플리케이션 헬스체크 실패"
    echo "로그 확인:"
    docker logs optimized-app-cached --tail 10
fi

# Redis 헬스체크
if docker exec redis-cache redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis 정상 동작"
else
    echo "❌ Redis 헬스체크 실패"
fi

echo ""
echo "6. 캐시 성능 테스트..."

# 캐시 없이 성능 테스트 (기준점)
echo "   - 캐시 성능 비교 테스트 실행..."

# 캐시 플러시 (깨끗한 상태에서 시작)
docker exec redis-cache redis-cli FLUSHALL > /dev/null 2>&1

# 캐시 미스 상태에서 테스트
echo "   - 캐시 미스 상태 테스트 (첫 번째 실행)"
ab -n 500 -c 10 -q http://localhost:3000/load-test > cache-test-miss.txt 2>&1
CACHE_MISS_RPS=$(grep "Requests per second" cache-test-miss.txt | awk '{print $4}')
CACHE_MISS_TIME=$(grep "Time per request.*mean" cache-test-miss.txt | head -1 | awk '{print $4}')

# 캐시 히트 상태에서 테스트
echo "   - 캐시 히트 상태 테스트 (두 번째 실행)"
ab -n 500 -c 10 -q http://localhost:3000/load-test > cache-test-hit.txt 2>&1
CACHE_HIT_RPS=$(grep "Requests per second" cache-test-hit.txt | awk '{print $4}')
CACHE_HIT_TIME=$(grep "Time per request.*mean" cache-test-hit.txt | head -1 | awk '{print $4}')

echo ""
echo "7. 캐시 효과 분석..."

echo "=== 캐시 성능 비교 결과 ==="
echo "캐시 미스 (첫 실행): ${CACHE_MISS_RPS} req/sec, ${CACHE_MISS_TIME}ms"
echo "캐시 히트 (재실행): ${CACHE_HIT_RPS} req/sec, ${CACHE_HIT_TIME}ms"

# 성능 개선 계산
if [ -n "$CACHE_MISS_RPS" ] && [ -n "$CACHE_HIT_RPS" ]; then
    IMPROVEMENT=$(echo "scale=2; ($CACHE_HIT_RPS - $CACHE_MISS_RPS) / $CACHE_MISS_RPS * 100" | bc -l 2>/dev/null)
    if [ -n "$IMPROVEMENT" ]; then
        echo "처리량 개선: ${IMPROVEMENT}%"
    fi
fi

echo ""
echo "8. Redis 캐시 상태 확인..."

# Redis 정보 확인
echo "   - Redis 메모리 사용량:"
docker exec redis-cache redis-cli info memory | grep -E "(used_memory_human|maxmemory_human)"

echo "   - Redis 키 개수:"
REDIS_KEYS=$(docker exec redis-cache redis-cli dbsize)
echo "저장된 키: ${REDIS_KEYS}개"

echo "   - Redis 히트율:"
docker exec redis-cache redis-cli info stats | grep -E "(keyspace_hits|keyspace_misses)"

echo ""
echo "9. 캐시 설정 최적화 확인..."

# Redis 설정 확인
echo "   - Redis 설정 정보:"
docker exec redis-cache redis-cli config get maxmemory
docker exec redis-cache redis-cli config get maxmemory-policy

echo ""
echo "10. 종합 성능 리포트 생성..."

# 캐시 성능 리포트 생성
cat > cache-performance-report.txt << EOF
=== 캐시 시스템 성능 리포트 ===
테스트 일시: $(date)
시스템: optimized-app:v1 + Redis 7 Alpine

=== 캐시 성능 비교 ===
캐시 미스 상태:
- 처리량: ${CACHE_MISS_RPS} req/sec
- 평균 응답시간: ${CACHE_MISS_TIME}ms

캐시 히트 상태:
- 처리량: ${CACHE_HIT_RPS} req/sec
- 평균 응답시간: ${CACHE_HIT_TIME}ms

성능 개선: ${IMPROVEMENT:-"계산 불가"}%

=== Redis 상태 ===
메모리 사용량: $(docker exec redis-cache redis-cli info memory | grep used_memory_human | cut -d: -f2)
저장된 키: ${REDIS_KEYS}개
최대 메모리: 64MB
정책: allkeys-lru

=== 시스템 리소스 ===
$(docker stats --no-stream --format "{{.Container}}: CPU {{.CPUPerc}}, Memory {{.MemUsage}}" | grep -E "(optimized-app|redis)")

=== 권장사항 ===
- 캐시 히트율 모니터링 지속
- 메모리 사용량에 따른 maxmemory 조정
- 캐시 만료 정책 최적화
- 애플리케이션별 캐시 전략 수립
EOF

echo "✅ 캐시 성능 리포트 생성 완료"

echo ""
echo "11. 모니터링 연동 확인..."

# Prometheus 메트릭에 Redis 정보 포함 확인
if curl -s http://localhost:3000/metrics | grep -q "redis"; then
    echo "✅ Redis 메트릭이 애플리케이션에 포함됨"
else
    echo "⚠️  Redis 메트릭 연동 확인 필요"
fi

echo ""
echo "=== 캐싱 시스템 구축 완료 ==="
echo ""
echo "구축된 시스템:"
echo "- 애플리케이션: optimized-app:v1 (보안 강화 + 최적화)"
echo "- 캐시: Redis 7 Alpine (64MB, LRU 정책)"
echo "- 네트워크: 격리된 브리지 네트워크"
echo "- 모니터링: 헬스체크 + 메트릭 수집"
echo ""
echo "접속 정보:"
echo "- 애플리케이션: http://localhost:3000"
echo "- Redis: localhost:6379"
echo ""
echo "관리 명령어:"
echo "- 로그 확인: docker-compose -f docker-compose.optimized.yml logs"
echo "- 상태 확인: docker-compose -f docker-compose.optimized.yml ps"
echo "- 정리: docker-compose -f docker-compose.optimized.yml down -v"
echo ""
echo "생성된 파일:"
echo "- docker-compose.optimized.yml: 캐시 시스템 구성"
echo "- cache-performance-report.txt: 캐시 성능 분석 리포트"
echo ""
echo "다음 단계: 모니터링 시스템과 통합 테스트"