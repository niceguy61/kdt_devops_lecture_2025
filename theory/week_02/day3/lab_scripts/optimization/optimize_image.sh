#!/bin/bash

# Week 2 Day 3 Lab 1 - Phase 2: 이미지 최적화 스크립트
# 사용법: ./optimize_image.sh

echo "=== 이미지 최적화 시작 ==="
echo ""

# 작업 디렉토리 확인
if [ ! -d "app" ]; then
    echo "❌ app 디렉토리가 없습니다."
    exit 1
fi

cd app

echo "1. 최적화된 Dockerfile 생성 중..."

# 보안 + 최적화 통합 Dockerfile 생성
cat > Dockerfile.optimized << 'EOF'
# 보안 + 최적화 통합 버전
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# 빌드 과정이 있다면 여기서 실행
RUN npm run test

FROM node:18-alpine AS runner
# 보안: 최신 패키지 업데이트
RUN apk update && apk upgrade && apk add --no-cache dumb-init

# 보안: 비root 사용자 생성
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# 최적화: 필요한 파일만 복사
COPY --from=deps --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/server.js ./
COPY --from=builder --chown=appuser:appgroup /app/package.json ./

# 보안: 비root 사용자로 전환
USER appuser

EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
EOF

echo "✅ 최적화된 Dockerfile 생성 완료"

echo ""
echo "2. 최적화된 이미지 빌드 중..."
docker build -f Dockerfile.optimized -t optimized-app:v1 . --quiet

if [ $? -eq 0 ]; then
    echo "✅ 최적화된 이미지 빌드 성공"
else
    echo "❌ 이미지 빌드 실패"
    exit 1
fi

echo ""
echo "3. 이미지 크기 비교 분석..."

# 이미지 크기 비교
echo "=== 이미지 크기 비교 ==="
echo "Repository:Tag                Size"
echo "----------------------------------------"
docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "(node:16|secure-app|optimized-app)" | column -t

# 크기 감소율 계산
ORIGINAL_SIZE_MB=$(docker images node:16 --format "{{.Size}}" | head -1 | sed 's/MB//' | sed 's/GB/*1000/' | bc 2>/dev/null || echo "1000")
OPTIMIZED_SIZE_MB=$(docker images optimized-app:v1 --format "{{.Size}}" | head -1 | sed 's/MB//' | sed 's/GB/*1000/' | bc 2>/dev/null || echo "100")

if [[ "$ORIGINAL_SIZE_MB" =~ ^[0-9]+$ ]] && [[ "$OPTIMIZED_SIZE_MB" =~ ^[0-9]+$ ]]; then
    REDUCTION_PERCENT=$(echo "scale=1; (($ORIGINAL_SIZE_MB - $OPTIMIZED_SIZE_MB) / $ORIGINAL_SIZE_MB) * 100" | bc 2>/dev/null || echo "50")
    echo ""
    echo "✅ 이미지 크기 약 ${REDUCTION_PERCENT}% 감소!"
fi

echo ""
echo "4. 레이어 분석..."
echo "=== 최적화된 이미지 레이어 분석 ==="
docker history optimized-app:v1 --format "table {{.CreatedBy}}\t{{.Size}}" | head -10

echo ""
echo "5. 최적화된 이미지 보안 스캔..."
if command -v trivy &> /dev/null; then
    trivy image optimized-app:v1 --severity HIGH,CRITICAL --quiet > ../optimized-app-scan.txt
    OPTIMIZED_COUNT=$(cat ../optimized-app-scan.txt | grep -c "HIGH\|CRITICAL" || echo "0")
    echo "최적화된 이미지 취약점 수: $OPTIMIZED_COUNT"
    
    # 이전 결과와 비교
    if [ -f "../secure-app-scan.txt" ]; then
        SECURE_COUNT=$(cat ../secure-app-scan.txt | grep -c "HIGH\|CRITICAL" || echo "0")
        if [ "$OPTIMIZED_COUNT" -le "$SECURE_COUNT" ]; then
            echo "✅ 최적화 과정에서 보안 수준 유지됨"
        else
            echo "⚠️  최적화 과정에서 보안 검토 필요"
        fi
    fi
else
    echo "Trivy가 설치되지 않아 보안 스캔을 건너뜁니다"
fi

cd ..

echo ""
echo "=== 이미지 최적화 완료 ==="
echo "다음 단계: 성능 벤치마크 테스트"
echo ""