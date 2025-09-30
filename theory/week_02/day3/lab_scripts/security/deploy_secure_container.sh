#!/bin/bash

# Week 2 Day 3 Lab 1 - Phase 1: 보안 강화 컨테이너 배포 스크립트
# 사용법: ./deploy_secure_container.sh

echo "=== 보안 강화 컨테이너 배포 시작 ==="
echo ""

# 기존 컨테이너 정리
echo "1. 기존 컨테이너 정리 중..."
if docker ps -a | grep -q "secure-app"; then
    docker stop secure-app >/dev/null 2>&1
    docker rm secure-app >/dev/null 2>&1
    echo "✅ 기존 컨테이너 정리 완료"
fi

echo ""
echo "2. 보안 강화 컨테이너 실행 중..."

# 보안 강화된 컨테이너 실행
docker run -d \
  --name secure-app \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  --tmpfs /var/run:rw,noexec,nosuid,size=50m \
  --no-new-privileges \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --memory="256m" \
  --cpus="0.5" \
  --memory-swappiness=0 \
  --security-opt=no-new-privileges:true \
  -p 3000:3000 \
  secure-app:v1

if [ $? -eq 0 ]; then
    echo "✅ 보안 강화 컨테이너 실행 성공"
else
    echo "❌ 컨테이너 실행 실패"
    exit 1
fi

echo ""
echo "3. 보안 설정 검증 중..."

# 보안 설정 확인
echo "=== 보안 설정 확인 ==="
echo "읽기 전용 파일시스템: $(docker inspect secure-app --format '{{.HostConfig.ReadonlyRootfs}}')"
echo "권한 제거: $(docker inspect secure-app --format '{{.HostConfig.CapDrop}}')"
echo "보안 옵션: $(docker inspect secure-app --format '{{.HostConfig.SecurityOpt}}')"
echo "메모리 제한: $(docker inspect secure-app --format '{{.HostConfig.Memory}}')"
echo "CPU 제한: $(docker inspect secure-app --format '{{.HostConfig.CpuQuota}}')"

echo ""
echo "4. 애플리케이션 동작 확인 중..."
sleep 5

# 헬스 체크
HEALTH_CHECK=$(curl -s http://localhost:3000/health 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ 애플리케이션 정상 동작 확인"
    echo "헬스 체크 결과: $HEALTH_CHECK"
else
    echo "❌ 애플리케이션 응답 없음"
    echo "컨테이너 로그 확인:"
    docker logs secure-app --tail 10
fi

echo ""
echo "5. 보안 테스트 수행 중..."

# 권한 상승 테스트 (실패해야 정상)
echo "권한 상승 테스트 (실패해야 정상):"
docker exec secure-app whoami 2>/dev/null || echo "✅ 비root 사용자로 실행 중"

# 파일 시스템 쓰기 테스트 (실패해야 정상)
echo "파일 시스템 쓰기 테스트 (실패해야 정상):"
docker exec secure-app touch /test-file 2>/dev/null && echo "❌ 파일 시스템이 쓰기 가능" || echo "✅ 읽기 전용 파일 시스템 적용됨"

echo ""
echo "=== 보안 강화 컨테이너 배포 완료 ==="
echo ""
echo "접속 정보:"
echo "- 애플리케이션: http://localhost:3000"
echo "- 헬스 체크: http://localhost:3000/health"
echo "- 메트릭: http://localhost:3000/metrics"
echo ""
echo "다음 단계: Phase 2 성능 최적화"
echo ""