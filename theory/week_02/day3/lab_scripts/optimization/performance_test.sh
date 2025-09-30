#!/bin/bash

# Week 2 Day 3 Lab 1: 성능 벤치마크 테스트 스크립트
# 사용법: ./performance_test.sh

echo "=== 성능 벤치마크 테스트 시작 ==="

# Apache Bench 설치 확인
if ! command -v ab &> /dev/null; then
    echo "1. Apache Bench 설치 중..."
    sudo apt-get update -qq
    sudo apt-get install -y apache2-utils
    echo "✅ Apache Bench 설치 완료"
else
    echo "✅ Apache Bench 이미 설치됨"
fi

# 애플리케이션 상태 확인
echo ""
echo "2. 애플리케이션 상태 확인..."

if ! curl -s http://localhost:3000/health > /dev/null; then
    echo "❌ 애플리케이션이 실행되지 않았습니다."
    echo "먼저 최적화된 애플리케이션을 실행해주세요:"
    echo "docker run -d --name optimized-app -p 3000:3000 optimized-app:v1"
    exit 1
fi

echo "✅ 애플리케이션 정상 동작 확인"

# 결과 디렉토리 생성
mkdir -p performance-results

echo ""
echo "3. 기본 성능 테스트 실행..."

# 기본 엔드포인트 성능 테스트
echo "   - 기본 엔드포인트 테스트 (1000 요청, 동시 연결 10개)"
ab -n 1000 -c 10 -g performance-results/basic-test.dat http://localhost:3000/ > performance-results/basic-test.txt 2>&1

# 결과 추출
BASIC_RPS=$(grep "Requests per second" performance-results/basic-test.txt | awk '{print $4}')
BASIC_TIME=$(grep "Time per request.*mean" performance-results/basic-test.txt | head -1 | awk '{print $4}')

echo "   결과: ${BASIC_RPS} req/sec, 평균 응답시간: ${BASIC_TIME}ms"

echo ""
echo "4. 부하 테스트 실행..."

# 부하 테스트 (적당한 요청과 동시 연결)
echo "   - 부하 테스트 (1000 요청, 동시 연결 20개)"
ab -n 1000 -c 20 -g performance-results/load-test.dat http://localhost:3000/load-test > performance-results/load-test.txt 2>&1

# 결과 추출
LOAD_RPS=$(grep "Requests per second" performance-results/load-test.txt | awk '{print $4}')
LOAD_TIME=$(grep "Time per request.*mean" performance-results/load-test.txt | head -1 | awk '{print $4}')

echo "   결과: ${LOAD_RPS} req/sec, 평균 응답시간: ${LOAD_TIME}ms"

echo ""
echo "5. 스트레스 테스트 실행..."

# 스트레스 테스트 (높은 동시 연결)
echo "   - 스트레스 테스트 (500 요청, 동시 연결 50개)"
ab -n 500 -c 50 -g performance-results/stress-test.dat http://localhost:3000/ > performance-results/stress-test.txt 2>&1

# 결과 추출
STRESS_RPS=$(grep "Requests per second" performance-results/stress-test.txt | awk '{print $4}')
STRESS_TIME=$(grep "Time per request.*mean" performance-results/stress-test.txt | head -1 | awk '{print $4}')

echo "   결과: ${STRESS_RPS} req/sec, 평균 응답시간: ${STRESS_TIME}ms"

echo ""
echo "6. 리소스 사용량 모니터링..."

# 컨테이너 리소스 사용량 확인
echo "   - 현재 리소스 사용량:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}" | grep -E "(CONTAINER|optimized-app)"

echo ""
echo "7. 메트릭 수집 확인..."

# 애플리케이션 메트릭 확인
if curl -s http://localhost:3000/metrics > /dev/null; then
    METRICS_COUNT=$(curl -s http://localhost:3000/metrics | wc -l)
    echo "   - 수집된 메트릭: ${METRICS_COUNT}개"
    
    # 주요 메트릭 확인
    echo "   - HTTP 요청 총계:"
    curl -s http://localhost:3000/metrics | grep "http_requests_total" | head -3
    
    echo "   - 응답 시간 히스토그램:"
    curl -s http://localhost:3000/metrics | grep "http_request_duration_seconds" | head -3
else
    echo "   ❌ 메트릭 엔드포인트 접근 실패"
fi

echo ""
echo "8. 성능 분석 및 리포트 생성..."

# 성능 분석 리포트 생성
cat > performance-results/performance-report.txt << EOF
=== 성능 테스트 리포트 ===
테스트 일시: $(date)
애플리케이션: optimized-app:v1

=== 테스트 결과 요약 ===
1. 기본 성능 테스트 (1000 req, 10 concurrent):
   - 처리량: ${BASIC_RPS} req/sec
   - 평균 응답시간: ${BASIC_TIME}ms

2. 부하 테스트 (1000 req, 20 concurrent):
   - 처리량: ${LOAD_RPS} req/sec
   - 평균 응답시간: ${LOAD_TIME}ms

3. 스트레스 테스트 (500 req, 50 concurrent):
   - 처리량: ${STRESS_RPS} req/sec
   - 평균 응답시간: ${STRESS_TIME}ms

=== 리소스 사용량 ===
$(docker stats --no-stream --format "{{.Container}}: CPU {{.CPUPerc}}, Memory {{.MemUsage}} ({{.MemPerc}})" | grep optimized-app)

=== 권장사항 ===
- 기본 성능이 목표치를 만족하는지 확인
- 부하 증가 시 응답시간 증가 패턴 분석
- 리소스 제한 설정의 적절성 검토
- 캐싱 시스템 도입으로 성능 개선 가능

=== 상세 결과 파일 ===
- basic-test.txt: 기본 성능 테스트 상세 결과
- load-test.txt: 부하 테스트 상세 결과
- stress-test.txt: 스트레스 테스트 상세 결과
- *.dat: 그래프 생성용 데이터 파일
EOF

echo "✅ 성능 분석 리포트 생성 완료"

echo ""
echo "9. 성능 최적화 권장사항..."

# 성능 기반 권장사항 제공
echo "=== 성능 최적화 권장사항 ==="

# RPS 기반 권장사항
if (( $(echo "$BASIC_RPS > 100" | bc -l) )); then
    echo "✅ 기본 처리량이 양호합니다 (${BASIC_RPS} req/sec)"
else
    echo "⚠️  기본 처리량이 낮습니다. 다음을 고려해보세요:"
    echo "   - 애플리케이션 코드 최적화"
    echo "   - 리소스 제한 증가"
    echo "   - 캐싱 시스템 도입"
fi

# 응답시간 기반 권장사항
if (( $(echo "$BASIC_TIME < 100" | bc -l) )); then
    echo "✅ 응답시간이 양호합니다 (${BASIC_TIME}ms)"
else
    echo "⚠️  응답시간이 높습니다. 다음을 고려해보세요:"
    echo "   - 데이터베이스 쿼리 최적화"
    echo "   - 비동기 처리 도입"
    echo "   - CDN 사용 검토"
fi

echo ""
echo "=== 성능 벤치마크 테스트 완료 ==="
echo ""
echo "생성된 파일:"
echo "- performance-results/performance-report.txt: 종합 성능 리포트"
echo "- performance-results/basic-test.txt: 기본 테스트 상세 결과"
echo "- performance-results/load-test.txt: 부하 테스트 상세 결과"
echo "- performance-results/stress-test.txt: 스트레스 테스트 상세 결과"
echo ""
echo "다음 단계: 캐싱 시스템 구축으로 성능 개선"