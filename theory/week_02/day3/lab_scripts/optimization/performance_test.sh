#!/bin/bash

# Week 2 Day 3 Lab 1 - Phase 2: 성능 테스트 스크립트
# 사용법: ./performance_test.sh

echo "=== 성능 테스트 시작 ==="
echo ""

# Apache Bench 설치 확인
echo "1. Apache Bench 설치 확인 중..."
if ! command -v ab &> /dev/null; then
    echo "Apache Bench가 설치되지 않았습니다. 설치를 시작합니다..."
    sudo apt-get update -qq
    sudo apt-get install -y apache2-utils
    echo "✅ Apache Bench 설치 완료"
else
    echo "✅ Apache Bench가 이미 설치되어 있습니다"
fi

# 기존 컨테이너 정리 및 최적화된 컨테이너 실행
echo ""
echo "2. 최적화된 컨테이너 실행 중..."

# 기존 컨테이너 정리
if docker ps -a | grep -q "optimized-app"; then
    docker stop optimized-app >/dev/null 2>&1
    docker rm optimized-app >/dev/null 2>&1
fi

if docker ps -a | grep -q "secure-app"; then
    docker stop secure-app >/dev/null 2>&1
    docker rm secure-app >/dev/null 2>&1
fi

# 최적화된 컨테이너 실행
docker run -d \
  --name optimized-app \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  --tmpfs /var/run:rw,noexec,nosuid,size=50m \
  --no-new-privileges \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --memory="256m" \
  --cpus="0.5" \
  --memory-swappiness=0 \
  -p 3000:3000 \
  optimized-app:v1

if [ $? -eq 0 ]; then
    echo "✅ 최적화된 컨테이너 실행 성공"
else
    echo "❌ 컨테이너 실행 실패"
    exit 1
fi

# 애플리케이션 준비 대기
echo "애플리케이션 준비 중..."
sleep 10

# 헬스 체크
HEALTH_CHECK=$(curl -s http://localhost:3000/health 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ 애플리케이션이 준비되지 않았습니다"
    docker logs optimized-app --tail 10
    exit 1
fi

echo "✅ 애플리케이션 준비 완료"

echo ""
echo "3. 기본 성능 테스트 수행 중..."

# 기본 성능 테스트
echo "=== 기본 성능 테스트 (1000 요청, 동시 10개) ==="
ab -n 1000 -c 10 -q http://localhost:3000/ > basic_test.txt 2>&1

if [ $? -eq 0 ]; then
    RPS_BASIC=$(grep "Requests per second" basic_test.txt | awk '{print $4}')
    TIME_PER_REQ=$(grep "Time per request" basic_test.txt | head -1 | awk '{print $4}')
    echo "✅ 기본 테스트 완료"
    echo "   - 초당 요청 수: $RPS_BASIC"
    echo "   - 요청당 시간: ${TIME_PER_REQ}ms"
else
    echo "❌ 기본 성능 테스트 실패"
fi

echo ""
echo "4. 부하 테스트 수행 중..."

# 부하 테스트
echo "=== 부하 테스트 (5000 요청, 동시 50개) ==="
ab -n 5000 -c 50 -q http://localhost:3000/load-test > load_test.txt 2>&1

if [ $? -eq 0 ]; then
    RPS_LOAD=$(grep "Requests per second" load_test.txt | awk '{print $4}')
    TIME_PER_REQ_LOAD=$(grep "Time per request" load_test.txt | head -1 | awk '{print $4}')
    FAILED_REQUESTS=$(grep "Failed requests" load_test.txt | awk '{print $3}')
    echo "✅ 부하 테스트 완료"
    echo "   - 초당 요청 수: $RPS_LOAD"
    echo "   - 요청당 시간: ${TIME_PER_REQ_LOAD}ms"
    echo "   - 실패한 요청: $FAILED_REQUESTS"
else
    echo "❌ 부하 테스트 실패"
fi

echo ""
echo "5. 리소스 사용량 모니터링..."

# 리소스 사용량 확인
echo "=== 리소스 사용량 ==="
docker stats optimized-app --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}"

echo ""
echo "6. 메모리 및 CPU 상세 분석..."

# 컨테이너 내부 리소스 확인
echo "=== 컨테이너 내부 리소스 상태 ==="
echo "메모리 사용량:"
docker exec optimized-app free -h 2>/dev/null || echo "메모리 정보 확인 불가"

echo ""
echo "프로세스 상태:"
docker exec optimized-app ps aux 2>/dev/null || echo "프로세스 정보 확인 불가"

echo ""
echo "7. 성능 테스트 결과 요약..."

# 결과 요약
echo "=== 성능 테스트 결과 요약 ==="
echo "기본 테스트 (1000 req, 10 concurrent):"
echo "  - RPS: ${RPS_BASIC:-N/A}"
echo "  - 평균 응답시간: ${TIME_PER_REQ:-N/A}ms"
echo ""
echo "부하 테스트 (5000 req, 50 concurrent):"
echo "  - RPS: ${RPS_LOAD:-N/A}"
echo "  - 평균 응답시간: ${TIME_PER_REQ_LOAD:-N/A}ms"
echo "  - 실패율: ${FAILED_REQUESTS:-0}/5000"

# 성능 기준 체크
if [[ "$RPS_BASIC" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$RPS_BASIC > 100" | bc -l) )); then
    echo "✅ 기본 성능 기준 통과 (>100 RPS)"
else
    echo "⚠️  기본 성능 개선 필요"
fi

if [[ "$FAILED_REQUESTS" =~ ^[0-9]+$ ]] && [ "$FAILED_REQUESTS" -eq 0 ]; then
    echo "✅ 안정성 테스트 통과 (실패율 0%)"
else
    echo "⚠️  안정성 개선 필요"
fi

# 테스트 결과 파일 정리
rm -f basic_test.txt load_test.txt

echo ""
echo "=== 성능 테스트 완료 ==="
echo "다음 단계: 캐싱 시스템 구축"
echo ""