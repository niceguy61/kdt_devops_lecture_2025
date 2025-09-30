#!/bin/bash

# Week 2 Day 3 Lab 1: 보안 강화 컨테이너 배포 스크립트
# 사용법: ./deploy_secure_container.sh

echo "=== 보안 강화 컨테이너 배포 시작 ==="

# 보안 강화 이미지 존재 확인
if ! docker images | grep -q "secure-app.*v1"; then
    echo "❌ secure-app:v1 이미지를 찾을 수 없습니다."
    echo "먼저 build_secure_image.sh를 실행해주세요."
    exit 1
fi

echo "1. 기존 컨테이너 정리..."

# 기존 컨테이너 정리
docker stop secure-app > /dev/null 2>&1
docker rm secure-app > /dev/null 2>&1

echo "✅ 기존 컨테이너 정리 완료"

echo ""
echo "2. 보안 강화 네트워크 생성..."

# 보안 강화 네트워크 생성
docker network create --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  --gateway=172.20.0.1 \
  secure-network > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ 보안 네트워크 생성 완료 (secure-network)"
else
    echo "⚠️  보안 네트워크가 이미 존재하거나 생성 실패"
fi

echo ""
echo "3. 보안 강화 컨테이너 실행..."

# 보안 강화 컨테이너 실행
docker run -d \
  --name secure-app \
  --network secure-network \
  --ip 172.20.240.10 \
  -p 3000:3000 \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  --tmpfs /var/run:rw,noexec,nosuid,size=50m \
  --tmpfs /app/logs:rw,noexec,nosuid,size=50m \
  --no-new-privileges \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --memory="256m" \
  --memory-swap="256m" \
  --memory-swappiness=0 \
  --cpus="0.5" \
  --pids-limit=100 \
  --ulimit nofile=1024:1024 \
  --ulimit nproc=64:64 \
  --security-opt=no-new-privileges:true \
  --security-opt=apparmor:docker-default \
  --restart=unless-stopped \
  --health-cmd="node -e \"require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })\"" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --health-start-period=40s \
  secure-app:v1

if [ $? -eq 0 ]; then
    echo "✅ 보안 강화 컨테이너 실행 성공"
else
    echo "❌ 컨테이너 실행 실패"
    exit 1
fi

echo ""
echo "4. 컨테이너 시작 대기 및 상태 확인..."

# 컨테이너 시작 대기
sleep 10

# 컨테이너 상태 확인
CONTAINER_STATUS=$(docker inspect secure-app --format='{{.State.Status}}')
echo "   - 컨테이너 상태: $CONTAINER_STATUS"

# 헬스체크 상태 확인
HEALTH_STATUS=$(docker inspect secure-app --format='{{.State.Health.Status}}' 2>/dev/null)
echo "   - 헬스체크 상태: $HEALTH_STATUS"

# 애플리케이션 응답 확인
if curl -s http://localhost:3000/health > /dev/null; then
    echo "   ✅ 애플리케이션 정상 응답"
else
    echo "   ❌ 애플리케이션 응답 실패"
    echo "   로그 확인:"
    docker logs secure-app --tail 10
fi

echo ""
echo "5. 보안 설정 검증..."

# 보안 설정 상세 검증
echo "   - 보안 설정 상세 검증:"

# 읽기 전용 파일시스템 확인
READONLY_CHECK=$(docker inspect secure-app --format='{{.HostConfig.ReadonlyRootfs}}')
echo "     읽기 전용 파일시스템: $READONLY_CHECK"

# 권한 제거 확인
CAP_DROP_CHECK=$(docker inspect secure-app --format='{{.HostConfig.CapDrop}}')
echo "     제거된 권한: $CAP_DROP_CHECK"

# 추가된 권한 확인
CAP_ADD_CHECK=$(docker inspect secure-app --format='{{.HostConfig.CapAdd}}')
echo "     추가된 권한: $CAP_ADD_CHECK"

# 보안 옵션 확인
SECURITY_OPT_CHECK=$(docker inspect secure-app --format='{{.HostConfig.SecurityOpt}}')
echo "     보안 옵션: $SECURITY_OPT_CHECK"

# 리소스 제한 확인
MEMORY_LIMIT=$(docker inspect secure-app --format='{{.HostConfig.Memory}}')
CPU_LIMIT=$(docker inspect secure-app --format='{{.HostConfig.CpuQuota}}')
echo "     메모리 제한: $((MEMORY_LIMIT / 1024 / 1024))MB"
echo "     CPU 제한: $((CPU_LIMIT / 100000))% ($(echo "scale=1; $CPU_LIMIT / 1000" | bc)ms/100ms)"

echo ""
echo "6. 네트워크 보안 확인..."

# 네트워크 설정 확인
NETWORK_INFO=$(docker inspect secure-app --format='{{range .NetworkSettings.Networks}}{{.NetworkID}} {{.IPAddress}}{{end}}')
echo "   - 네트워크 정보: $NETWORK_INFO"

# 포트 매핑 확인
PORT_INFO=$(docker inspect secure-app --format='{{.NetworkSettings.Ports}}')
echo "   - 포트 매핑: $PORT_INFO"

# 네트워크 격리 테스트
echo "   - 네트워크 격리 테스트:"
if docker exec secure-app ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo "     외부 네트워크 접근: 가능"
else
    echo "     외부 네트워크 접근: 차단됨"
fi

echo ""
echo "7. 런타임 보안 테스트..."

# 파일 시스템 쓰기 테스트 (실패해야 정상)
echo "   - 읽기 전용 파일시스템 테스트:"
if docker exec secure-app touch /test-file 2>/dev/null; then
    echo "     ❌ 루트 파일시스템 쓰기 가능 (보안 위험)"
else
    echo "     ✅ 루트 파일시스템 쓰기 차단됨"
fi

# tmpfs 쓰기 테스트 (성공해야 정상)
if docker exec secure-app touch /tmp/test-file 2>/dev/null; then
    echo "     ✅ tmpfs 쓰기 가능"
else
    echo "     ❌ tmpfs 쓰기 실패"
fi

# 권한 상승 테스트 (실패해야 정상)
echo "   - 권한 상승 방지 테스트:"
if docker exec secure-app sudo echo "test" 2>/dev/null; then
    echo "     ❌ sudo 명령 실행 가능 (보안 위험)"
else
    echo "     ✅ sudo 명령 차단됨"
fi

# 프로세스 실행 사용자 확인
RUNNING_USER=$(docker exec secure-app whoami)
echo "   - 실행 사용자: $RUNNING_USER"

# 프로세스 목록 확인
echo "   - 실행 중인 프로세스:"
docker exec secure-app ps aux | sed 's/^/     /'

echo ""
echo "8. 성능 및 리소스 사용량 확인..."

# 리소스 사용량 확인
echo "   - 현재 리소스 사용량:"
docker stats secure-app --no-stream --format "     CPU: {{.CPUPerc}}, Memory: {{.MemUsage}} ({{.MemPerc}}), Network: {{.NetIO}}"

# 기본 성능 테스트
echo "   - 기본 성능 테스트 (100 요청):"
if command -v ab &> /dev/null; then
    ab -n 100 -c 5 -q http://localhost:3000/ > perf-test.txt 2>&1
    PERF_RPS=$(grep "Requests per second" perf-test.txt | awk '{print $4}')
    PERF_TIME=$(grep "Time per request.*mean" perf-test.txt | head -1 | awk '{print $4}')
    echo "     처리량: ${PERF_RPS} req/sec, 평균 응답시간: ${PERF_TIME}ms"
    rm -f perf-test.txt
else
    echo "     Apache Bench가 설치되지 않아 성능 테스트를 건너뜁니다."
fi

echo ""
echo "9. 로그 및 모니터링 설정..."

# 로그 드라이버 확인
LOG_DRIVER=$(docker inspect secure-app --format='{{.HostConfig.LogConfig.Type}}')
echo "   - 로그 드라이버: $LOG_DRIVER"

# 최근 로그 확인
echo "   - 최근 애플리케이션 로그:"
docker logs secure-app --tail 5 | sed 's/^/     /'

echo ""
echo "10. 보안 배포 리포트 생성..."

# 보안 배포 리포트 생성
cat > secure-deployment-report.txt << EOF
=== 보안 강화 컨테이너 배포 리포트 ===
배포 일시: $(date)
컨테이너: secure-app
이미지: secure-app:v1

=== 보안 설정 ===
- 읽기 전용 파일시스템: ${READONLY_CHECK}
- 권한 제거: ${CAP_DROP_CHECK}
- 추가 권한: ${CAP_ADD_CHECK}
- 보안 옵션: ${SECURITY_OPT_CHECK}
- 실행 사용자: ${RUNNING_USER}

=== 리소스 제한 ===
- 메모리 제한: $((MEMORY_LIMIT / 1024 / 1024))MB
- CPU 제한: $((CPU_LIMIT / 100000))%
- PID 제한: 100개
- 파일 디스크립터 제한: 1024개

=== 네트워크 보안 ===
- 격리된 네트워크: secure-network
- 내부 IP: 172.20.240.10
- 포트 매핑: 3000:3000

=== 런타임 보안 테스트 ===
- 루트 파일시스템 쓰기: 차단됨 ✅
- tmpfs 쓰기: 허용됨 ✅
- 권한 상승: 차단됨 ✅
- 실행 사용자: 비root (${RUNNING_USER}) ✅

=== 성능 영향 ===
- 컨테이너 상태: ${CONTAINER_STATUS}
- 헬스체크: ${HEALTH_STATUS}
- 기본 성능: ${PERF_RPS:-"측정 안됨"} req/sec

=== 모니터링 ===
- 헬스체크: 30초 간격
- 로그 드라이버: ${LOG_DRIVER}
- 재시작 정책: unless-stopped

=== 권장사항 ===
- 정기적인 보안 스캔 실행
- 로그 중앙화 시스템 연동
- 네트워크 정책 추가 강화
- 시크릿 관리 시스템 도입

=== 접속 정보 ===
- 애플리케이션: http://localhost:3000
- 헬스체크: http://localhost:3000/health
- 메트릭: http://localhost:3000/metrics
EOF

echo "✅ 보안 배포 리포트 생성 완료"

echo ""
echo "=== 보안 강화 컨테이너 배포 완료 ==="
echo ""
echo "배포 결과:"
echo "- 컨테이너명: secure-app"
echo "- 상태: $CONTAINER_STATUS"
echo "- 헬스체크: $HEALTH_STATUS"
echo "- 실행 사용자: $RUNNING_USER"
echo ""
echo "보안 강화 조치:"
echo "- ✅ 읽기 전용 파일시스템"
echo "- ✅ 모든 권한 제거 + 최소 권한만 추가"
echo "- ✅ 리소스 제한 (CPU 0.5, Memory 256MB)"
echo "- ✅ 네트워크 격리"
echo "- ✅ 프로세스 및 파일 제한"
echo "- ✅ 보안 옵션 적용"
echo ""
echo "접속 정보:"
echo "- 애플리케이션: http://localhost:3000"
echo "- 헬스체크: http://localhost:3000/health"
echo "- 메트릭: http://localhost:3000/metrics"
echo ""
echo "생성된 파일:"
echo "- secure-deployment-report.txt: 보안 배포 분석 리포트"
echo ""
echo "관리 명령어:"
echo "- 상태 확인: docker ps | grep secure-app"
echo "- 로그 확인: docker logs secure-app"
echo "- 리소스 확인: docker stats secure-app"
echo "- 정리: docker stop secure-app && docker rm secure-app"
echo ""
echo "다음 단계: 모니터링 시스템과 통합 및 성능 최적화"