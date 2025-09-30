#!/bin/bash

# Week 2 Day 3 Lab 1: 이미지 최적화 자동화 스크립트
# 사용법: ./optimize_image.sh

echo "=== 컨테이너 이미지 최적화 시작 ==="

# 작업 디렉토리 확인
if [ ! -f "app/package.json" ]; then
    echo "❌ app/package.json 파일을 찾을 수 없습니다."
    echo "실습 준비 단계를 먼저 완료해주세요."
    exit 1
fi

cd app

echo "1. 기본 이미지 크기 확인..."

# 기본 Node.js 이미지 크기 확인
docker pull node:16 > /dev/null 2>&1
docker pull node:18-alpine > /dev/null 2>&1

echo "=== 베이스 이미지 크기 비교 ==="
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "(node:16|node:18-alpine)"

echo ""
echo "2. 최적화된 Dockerfile 생성..."

# 최적화된 Dockerfile 생성
cat > Dockerfile.optimized << 'EOF'
# 멀티스테이지 빌드 + 보안 + 최적화 통합
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# 테스트 실행 (빌드 검증)
RUN npm run test

FROM node:18-alpine AS runner
# 보안: 최신 패키지 업데이트 및 필수 도구만 설치
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/*

# 보안: 비root 사용자 생성
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# 최적화: 필요한 파일만 선별적으로 복사
COPY --from=deps --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/server.js ./
COPY --from=builder --chown=appuser:appgroup /app/package.json ./

# 최적화: 불필요한 파일 제거 (이미 builder 단계에서 처리)
# 보안: 비root 사용자로 전환
USER appuser

# 최적화: 최소 권한 포트
EXPOSE 3000

# 보안 + 최적화: dumb-init으로 PID 1 문제 해결
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
EOF

echo "✅ 최적화된 Dockerfile 생성 완료"

echo ""
echo "3. 최적화된 이미지 빌드..."

# 최적화된 이미지 빌드
docker build -f Dockerfile.optimized -t optimized-app:v1 . --no-cache

if [ $? -eq 0 ]; then
    echo "✅ 최적화된 이미지 빌드 성공"
else
    echo "❌ 이미지 빌드 실패"
    exit 1
fi

echo ""
echo "4. 이미지 크기 비교 분석..."

# 이미지 크기 비교
echo "=== 이미지 크기 최적화 결과 ==="
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" | grep -E "(node:16|node:18-alpine|optimized-app)"

# 크기 계산 및 비교
NODE16_SIZE=$(docker images node:16 --format "{{.Size}}" | head -1)
OPTIMIZED_SIZE=$(docker images optimized-app:v1 --format "{{.Size}}" | head -1)

echo ""
echo "=== 최적화 효과 ==="
echo "기존 Node 16 이미지: $NODE16_SIZE"
echo "최적화된 이미지: $OPTIMIZED_SIZE"

# 레이어 분석
echo ""
echo "5. 이미지 레이어 분석..."
echo "=== 최적화된 이미지 레이어 구조 ==="
docker history optimized-app:v1 --format "table {{.CreatedBy}}\t{{.Size}}" | head -10

echo ""
echo "6. 보안 스캔 (최적화 후)..."

# 최적화된 이미지 보안 스캔
if command -v trivy &> /dev/null; then
    echo "최적화된 이미지 취약점 스캔 중..."
    trivy image optimized-app:v1 --severity HIGH,CRITICAL --format json --output ../scan-results/optimized-app-scan.json
    
    OPTIMIZED_VULNS=$(jq '.Results[]?.Vulnerabilities // [] | length' ../scan-results/optimized-app-scan.json 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    echo "최적화된 이미지 취약점: ${OPTIMIZED_VULNS}개"
else
    echo "⚠️  Trivy가 설치되지 않아 보안 스캔을 건너뜁니다."
fi

echo ""
echo "7. 최적화 검증 테스트..."

# 최적화된 이미지 실행 테스트
echo "최적화된 이미지 실행 테스트..."
docker run -d --name test-optimized -p 3001:3000 optimized-app:v1

# 애플리케이션 시작 대기
sleep 5

# 헬스체크
if curl -s http://localhost:3001/health > /dev/null; then
    echo "✅ 최적화된 애플리케이션 정상 동작 확인"
    
    # 간단한 성능 테스트
    echo "기본 응답 시간 측정..."
    curl -w "응답 시간: %{time_total}초\n" -s -o /dev/null http://localhost:3001/
else
    echo "❌ 애플리케이션 동작 확인 실패"
fi

# 테스트 컨테이너 정리
docker stop test-optimized > /dev/null 2>&1
docker rm test-optimized > /dev/null 2>&1

echo ""
echo "=== 이미지 최적화 완료 ==="
echo ""
echo "최적화 결과:"
echo "- 멀티스테이지 빌드로 불필요한 빌드 도구 제거"
echo "- Alpine 베이스로 이미지 크기 최소화"
echo "- 보안 강화 (비root 사용자, 최신 패키지)"
echo "- 레이어 최적화로 빌드 캐시 효율성 향상"
echo ""
echo "생성된 이미지: optimized-app:v1"
echo "다음 단계: 성능 벤치마크 테스트"

cd ..