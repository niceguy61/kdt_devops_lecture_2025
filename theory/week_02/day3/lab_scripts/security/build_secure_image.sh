#!/bin/bash

# Week 2 Day 3 Lab 1: 보안 강화 이미지 빌드 스크립트
# 사용법: ./build_secure_image.sh

echo "=== 보안 강화 이미지 빌드 시작 ==="

# 작업 디렉토리 확인
if [ ! -f "app/package.json" ]; then
    echo "❌ app/package.json 파일을 찾을 수 없습니다."
    echo "실습 준비 단계를 먼저 완료해주세요."
    exit 1
fi

cd app

echo "1. 보안 강화 Dockerfile 생성..."

# 보안 강화 Dockerfile 생성
cat > Dockerfile.secure << 'EOF'
# 멀티스테이지 빌드 + 보안 강화
FROM node:18-alpine AS builder

# 보안: 최신 패키지 업데이트 및 보안 패치
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/*

WORKDIR /app

# 의존성 파일 복사 및 설치
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force && \
    npm audit fix --force

# 애플리케이션 코드 복사
COPY . .

# 보안: 불필요한 파일 제거
RUN rm -rf tests/ *.md .git/ .gitignore

# 프로덕션 스테이지
FROM node:18-alpine AS production

# 보안: 최신 패키지 업데이트
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/*

# 보안: 비root 사용자 생성
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# 보안: 파일 소유권 설정하여 복사
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/server.js ./
COPY --from=builder --chown=appuser:appgroup /app/package.json ./

# 보안: 디렉토리 권한 설정
RUN chmod 755 /app && \
    chmod 644 /app/server.js /app/package.json

# 보안: 비root 사용자로 전환
USER appuser

# 보안: 최소 권한 포트
EXPOSE 3000

# 보안: 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# 보안: dumb-init으로 PID 1 문제 해결
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
EOF

echo "✅ 보안 강화 Dockerfile 생성 완료"

echo ""
echo "2. 보안 강화 이미지 빌드..."

# 보안 강화 이미지 빌드
docker build -f Dockerfile.secure -t secure-app:v1 . --no-cache

if [ $? -eq 0 ]; then
    echo "✅ 보안 강화 이미지 빌드 성공"
else
    echo "❌ 이미지 빌드 실패"
    exit 1
fi

echo ""
echo "3. 이미지 보안 스캔..."

# Trivy 설치 확인
if ! command -v trivy &> /dev/null; then
    echo "Trivy가 설치되지 않았습니다. security_scan.sh를 먼저 실행해주세요."
    exit 1
fi

# 보안 강화 이미지 스캔
echo "   - 보안 강화 이미지 취약점 스캔 중..."
trivy image secure-app:v1 --severity HIGH,CRITICAL --format json --output ../scan-results/secure-app-scan.json

# 취약점 개수 확인
SECURE_VULNS=$(jq '.Results[]?.Vulnerabilities // [] | length' ../scan-results/secure-app-scan.json 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
echo "   - 보안 강화 이미지 취약점: ${SECURE_VULNS}개"

# 기존 이미지와 비교 (있다면)
if [ -f "../scan-results/node16-scan.json" ]; then
    NODE16_VULNS=$(jq '.Results[]?.Vulnerabilities // [] | length' ../scan-results/node16-scan.json 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    if [ "$SECURE_VULNS" -lt "$NODE16_VULNS" ]; then
        REDUCTION=$((NODE16_VULNS - SECURE_VULNS))
        PERCENTAGE=$(( (REDUCTION * 100) / NODE16_VULNS ))
        echo "   ✅ 취약점 ${REDUCTION}개 감소 (${PERCENTAGE}% 개선)"
    fi
fi

echo ""
echo "4. 이미지 구성 분석..."

# 이미지 레이어 분석
echo "   - 이미지 레이어 구조:"
docker history secure-app:v1 --format "table {{.CreatedBy}}\t{{.Size}}" | head -10

# 이미지 크기 확인
echo ""
echo "   - 이미지 크기 비교:"
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "(node:16|node:18-alpine|secure-app)"

echo ""
echo "5. 보안 설정 검증..."

# 보안 설정 검증을 위한 임시 컨테이너 실행
echo "   - 보안 설정 검증 중..."
docker run -d --name temp-secure-test secure-app:v1
sleep 5

# 사용자 확인
USER_CHECK=$(docker exec temp-secure-test whoami 2>/dev/null)
if [ "$USER_CHECK" = "appuser" ]; then
    echo "   ✅ 비root 사용자로 실행 확인: $USER_CHECK"
else
    echo "   ❌ root 사용자로 실행됨: $USER_CHECK"
fi

# 프로세스 확인
PROCESS_CHECK=$(docker exec temp-secure-test ps aux | grep node | grep -v grep)
echo "   - 실행 중인 프로세스:"
echo "     $PROCESS_CHECK"

# 파일 권한 확인
PERMISSION_CHECK=$(docker exec temp-secure-test ls -la /app/)
echo "   - 파일 권한:"
echo "$PERMISSION_CHECK" | sed 's/^/     /'

# 네트워크 포트 확인
PORT_CHECK=$(docker exec temp-secure-test netstat -tlnp 2>/dev/null | grep :3000 || echo "netstat not available")
echo "   - 리스닝 포트: $PORT_CHECK"

# 임시 컨테이너 정리
docker stop temp-secure-test > /dev/null 2>&1
docker rm temp-secure-test > /dev/null 2>&1

echo ""
echo "6. 헬스체크 기능 테스트..."

# 헬스체크 기능 테스트
echo "   - 헬스체크 기능 테스트 중..."

# 기존 테스트 컨테이너 정리
docker stop secure-app-health-test > /dev/null 2>&1
docker rm secure-app-health-test > /dev/null 2>&1

# 새 테스트 컨테이너 실행
docker run -d --name secure-app-health-test -p 3001:3000 secure-app:v1

# 애플리케이션 시작 대기
echo "   - 애플리케이션 시작 대기 중..."
sleep 15

# 초기 헬스체크 상태 확인 (아직 준비 중일 수 있음)
HEALTH_STATUS=$(docker inspect secure-app-health-test --format='{{.State.Health.Status}}' 2>/dev/null || echo "starting")
echo "   - 초기 헬스체크 상태: $HEALTH_STATUS"

# 수동 헬스체크 (포트 수정)
echo "   - 애플리케이션 시작 대기 중..."
sleep 5

# 헬스체크 재시도 로직
for i in {1..5}; do
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        echo "   ✅ 애플리케이션 헬스체크 성공 (시도 $i/5)"
        HEALTH_SUCCESS="true"
        break
    else
        echo "   ⏳ 헬스체크 시도 $i/5 실패, 5초 후 재시도..."
        sleep 5
    fi
done

if [ "$HEALTH_SUCCESS" != "true" ]; then
    echo "   ❌ 애플리케이션 헬스체크 최종 실패"
    echo "   - 컨테이너 로그 확인:"
    docker logs secure-app-health-test --tail 10 | sed 's/^/     /'
fi

# Docker 헬스체크 상태 확인 (시간 대기)
echo "   - Docker 헬스체크 상태 확인 중..."
sleep 10
HEALTH_STATUS=$(docker inspect secure-app-health-test --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
echo "   - Docker 헬스체크 상태: $HEALTH_STATUS"

# 헬스체크 로그 확인
HEALTH_LOG=$(docker inspect secure-app-health-test --format='{{range .State.Health.Log}}{{.Output}}{{end}}' 2>/dev/null)
if [ -n "$HEALTH_LOG" ]; then
    echo "   - 헬스체크 로그:"
    echo "$HEALTH_LOG" | sed 's/^/     /'
fi

# 테스트 컨테이너 정리
docker stop secure-app-health-test > /dev/null 2>&1
docker rm secure-app-health-test > /dev/null 2>&1

echo ""
echo "7. 보안 강화 리포트 생성..."

# 보안 강화 리포트 생성
cat > ../security-report.txt << EOF
=== 보안 강화 이미지 리포트 ===
빌드 일시: $(date)
이미지: secure-app:v1

=== 보안 강화 조치 ===
1. 베이스 이미지: Node.js 18 Alpine (최신 보안 패치)
2. 멀티스테이지 빌드: 불필요한 빌드 도구 제거
3. 비root 사용자: appuser (UID: 1001)
4. 파일 권한: 최소 권한 설정
5. 헬스체크: 애플리케이션 상태 모니터링
6. dumb-init: PID 1 문제 해결

=== 취약점 분석 ===
보안 강화 이미지 취약점: ${SECURE_VULNS}개
$([ -n "$NODE16_VULNS" ] && echo "기존 Node 16 대비 개선: ${REDUCTION:-0}개 감소 (${PERCENTAGE:-0}% 개선)")

=== 실행 환경 검증 ===
- 실행 사용자: ${USER_CHECK}
- 헬스체크 상태: ${HEALTH_STATUS}
- 보안 설정: 적용 완료

=== 권장사항 ===
- 정기적인 베이스 이미지 업데이트
- 취약점 스캔 자동화
- 런타임 보안 정책 적용
- 컨테이너 격리 강화

=== 다음 단계 ===
- 런타임 보안 정책 적용
- 네트워크 보안 설정
- 시크릿 관리 시스템 연동
EOF

echo "✅ 보안 강화 리포트 생성 완료"

cd ..

echo ""
echo "=== 보안 강화 이미지 빌드 완료 ==="
echo ""
echo "빌드 결과:"
echo "- 이미지명: secure-app:v1"
echo "- 취약점: ${SECURE_VULNS}개 (HIGH/CRITICAL)"
echo "- 실행 사용자: ${USER_CHECK}"
echo "- 헬스체크: 활성화"
echo ""
echo "보안 강화 조치:"
echo "- ✅ Alpine 베이스 이미지 사용"
echo "- ✅ 멀티스테이지 빌드"
echo "- ✅ 비root 사용자 실행"
echo "- ✅ 최소 권한 파일 시스템"
echo "- ✅ 헬스체크 기능"
echo "- ✅ dumb-init PID 1 처리"
echo ""
echo "생성된 파일:"
echo "- app/Dockerfile.secure: 보안 강화 Dockerfile"
echo "- security-report.txt: 보안 분석 리포트"
echo "- scan-results/secure-app-scan.json: 취약점 스캔 결과"
echo ""
echo "다음 단계: deploy_secure_container.sh로 보안 런타임 정책 적용"