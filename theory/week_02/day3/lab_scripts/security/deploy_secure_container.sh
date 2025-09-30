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
echo "2. 보안 강화 컨테이너 실행..."

# 보안 강화 컨테이너 실행 (호환성 버전)
docker run -d \
  --name secure-app \
  -p 3000:3000 \
  --read-only \
  --tmpfs /tmp:rw,size=100m \
  --tmpfs /var/run:rw,size=50m \
  --memory="256m" \
  --cpus="0.5" \
  --restart=unless-stopped \
  secure-app:v1

if [ $? -eq 0 ]; then
    echo "✅ 보안 강화 컨테이너 실행 성공"
else
    echo "❌ 컨테이너 실행 실패"
    exit 1
fi

echo ""
echo "3. 컨테이너 시작 대기 및 상태 확인..."

# 컨테이너 시작 대기
sleep 10

# 컨테이너 상태 확인
CONTAINER_STATUS=$(docker inspect secure-app --format='{{.State.Status}}')
echo "   - 컨테이너 상태: $CONTAINER_STATUS"

# 애플리케이션 응답 확인
if curl -s http://localhost:3000/health > /dev/null; then
    echo "   ✅ 애플리케이션 정상 응답"
else
    echo "   ❌ 애플리케이션 응답 실패"
    echo "   로그 확인:"
    docker logs secure-app --tail 10
fi

echo ""
echo "4. 보안 설정 검증..."

# 보안 설정 상세 검증
echo "   - 보안 설정 상세 검증:"

# 읽기 전용 파일시스템 확인
READONLY_CHECK=$(docker inspect secure-app --format='{{.HostConfig.ReadonlyRootfs}}')
echo "     읽기 전용 파일시스템: $READONLY_CHECK"

# 리소스 제한 확인
MEMORY_LIMIT=$(docker inspect secure-app --format='{{.HostConfig.Memory}}')
echo "     메모리 제한: $((MEMORY_LIMIT / 1024 / 1024))MB"

echo ""
echo "5. 런타임 보안 테스트..."

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

# 프로세스 실행 사용자 확인
RUNNING_USER=$(docker exec secure-app whoami)
echo "   - 실행 사용자: $RUNNING_USER"

echo ""
echo "6. 성능 및 리소스 사용량 확인..."

# 리소스 사용량 확인
echo "   - 현재 리소스 사용량:"
docker stats secure-app --no-stream --format "     CPU: {{.CPUPerc}}, Memory: {{.MemUsage}} ({{.MemPerc}})"

echo ""
echo "=== 보안 강화 컨테이너 배포 완료 ==="
echo ""
echo "배포 결과:"
echo "- 컨테이너명: secure-app"
echo "- 상태: $CONTAINER_STATUS"
echo "- 실행 사용자: $RUNNING_USER"
echo ""
echo "보안 강화 조치:"
echo "- ✅ 읽기 전용 파일시스템"
echo "- ✅ 리소스 제한 (CPU 0.5, Memory 256MB)"
echo "- ✅ tmpfs 마운트 (임시 파일용)"
echo ""
echo "접속 정보:"
echo "- 애플리케이션: http://localhost:3000"
echo "- 헬스체크: http://localhost:3000/health"
echo "- 메트릭: http://localhost:3000/metrics"
echo ""
echo "관리 명령어:"
echo "- 상태 확인: docker ps | grep secure-app"
echo "- 로그 확인: docker logs secure-app"
echo "- 리소스 확인: docker stats secure-app"
echo "- 정리: docker stop secure-app && docker rm secure-app"