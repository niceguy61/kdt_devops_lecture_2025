# Session 5: 환경별 배포 전략

## 📍 교과과정에서의 위치
이 세션은 **Week 2 > Day 4 > Session 5**로, Session 4의 의존성 관리를 바탕으로 개발, 스테이징, 프로덕션 환경별 배포 전략을 학습합니다.

## 학습 목표 (5분)
- **환경별 설정** 분리 및 **Override 파일** 활용
- **프로파일 기반** 배포 및 **환경 변수** 관리
- **CI/CD 파이프라인** 연동 및 **배포 자동화**

## 1. 이론: 환경별 배포 아키텍처 (20분)

### 환경 분리 전략

```mermaid
graph TB
    subgraph "Development"
        A[docker-compose.yml] --> B[docker-compose.dev.yml]
        B --> C[Hot Reload, Debug Mode]
    end
    
    subgraph "Staging"
        D[docker-compose.yml] --> E[docker-compose.staging.yml]
        E --> F[Production-like, Testing]
    end
    
    subgraph "Production"
        G[docker-compose.yml] --> H[docker-compose.prod.yml]
        H --> I[Optimized, Secure, Scaled]
    end
```

### 설정 계층 구조

```yaml
# 기본 설정 (docker-compose.yml)
version: '3.8'
services:
  app:
    image: myapp:latest
    environment:
      - NODE_ENV=${NODE_ENV:-development}

# 개발 환경 (docker-compose.dev.yml)
version: '3.8'
services:
  app:
    build: .
    volumes:
      - .:/app
    environment:
      - DEBUG=true

# 프로덕션 환경 (docker-compose.prod.yml)
version: '3.8'
services:
  app:
    image: myapp:${VERSION}
    deploy:
      replicas: 3
    environment:
      - DEBUG=false
```

## 2. 실습: 환경별 Compose 파일 구성 (15분)

### 기본 구조 설정

```bash
mkdir -p multi-env-deploy && cd multi-env-deploy

# 기본 Compose 파일
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # 웹 애플리케이션
  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-8080}:80"
    volumes:
      - web-content:/usr/share/nginx/html:ro
    depends_on:
      - api

  # API 서버
  api:
    build:
      context: ./api
      target: ${BUILD_TARGET:-development}
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DB_HOST=${DB_HOST:-postgres}
      - REDIS_HOST=${REDIS_HOST:-redis}
      - LOG_LEVEL=${LOG_LEVEL:-info}
    depends_on:
      - postgres
      - redis

  # 데이터베이스
  postgres:
    image: postgres:${POSTGRES_VERSION:-13}
    environment:
      - POSTGRES_DB=${POSTGRES_DB:-appdb}
      - POSTGRES_USER=${POSTGRES_USER:-user}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-password}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # 캐시
  redis:
    image: redis:${REDIS_VERSION:-alpine}
    command: redis-server ${REDIS_CONFIG:-}

volumes:
  web-content:
  postgres_data:
EOF

# 개발 환경 Override
cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  web:
    ports:
      - "8080:80"
    volumes:
      - ./web:/usr/share/nginx/html

  api:
    build:
      target: development
    volumes:
      - ./api:/app
      - /app/node_modules
    environment:
      - DEBUG=true
      - HOT_RELOAD=true
    ports:
      - "3000:3000"  # 개발 시 직접 접근

  postgres:
    ports:
      - "5432:5432"  # 개발 도구 접근
    environment:
      - POSTGRES_PASSWORD=devpassword

  redis:
    ports:
      - "6379:6379"  # 개발 도구 접근

  # 개발 전용 서비스
  adminer:
    image: adminer
    ports:
      - "8081:8080"
    depends_on:
      - postgres

  redis-commander:
    image: rediscommander/redis-commander
    ports:
      - "8082:8081"
    environment:
      - REDIS_HOSTS=local:redis:6379
    depends_on:
      - redis
EOF

# 스테이징 환경
cat > docker-compose.staging.yml << 'EOF'
version: '3.8'

services:
  web:
    ports:
      - "80:80"

  api:
    build:
      target: production
    environment:
      - DEBUG=false
      - LOG_LEVEL=warn
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  postgres:
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G

  # 모니터링 (스테이징에서 테스트)
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
EOF

# 프로덕션 환경
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  web:
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
      restart_policy:
        condition: on-failure
        max_attempts: 3

  api:
    build:
      target: production
    environment:
      - DEBUG=false
      - LOG_LEVEL=error
    deploy:
      replicas: 5
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
      restart_policy:
        condition: on-failure
        max_attempts: 3

  postgres:
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups

  redis:
    command: redis-server --requirepass ${REDIS_PASSWORD}
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M

  # 프로덕션 전용 서비스
  nginx-exporter:
    image: nginx/nginx-prometheus-exporter
    command: -nginx.scrape-uri=http://web/nginx_status

  postgres-exporter:
    image: prometheuscommunity/postgres-exporter
    environment:
      - DATA_SOURCE_NAME=postgresql://user:${POSTGRES_PASSWORD}@postgres:5432/appdb?sslmode=disable
EOF
```

### 환경별 설정 파일

```bash
# 개발 환경 변수
cat > .env.development << 'EOF'
NODE_ENV=development
BUILD_TARGET=development
WEB_PORT=8080
LOG_LEVEL=debug

# Database
POSTGRES_VERSION=13
POSTGRES_DB=devdb
POSTGRES_USER=devuser
POSTGRES_PASSWORD=devpassword

# Redis
REDIS_VERSION=alpine
REDIS_CONFIG=

# Application
DEBUG=true
HOT_RELOAD=true
EOF

# 스테이징 환경 변수
cat > .env.staging << 'EOF'
NODE_ENV=staging
BUILD_TARGET=production
WEB_PORT=80
LOG_LEVEL=warn

# Database
POSTGRES_VERSION=13
POSTGRES_DB=stagingdb
POSTGRES_USER=staginguser
POSTGRES_PASSWORD=staging_secure_password

# Redis
REDIS_VERSION=6-alpine
REDIS_CONFIG=--maxmemory 256mb --maxmemory-policy allkeys-lru

# Application
DEBUG=false
HOT_RELOAD=false
EOF

# 프로덕션 환경 변수 (시크릿 관리)
cat > .env.production << 'EOF'
NODE_ENV=production
BUILD_TARGET=production
WEB_PORT=80
LOG_LEVEL=error

# Database (실제로는 시크릿 관리 시스템 사용)
POSTGRES_VERSION=13
POSTGRES_DB=proddb
POSTGRES_USER=produser
POSTGRES_PASSWORD=${POSTGRES_PROD_PASSWORD}

# Redis
REDIS_VERSION=6-alpine
REDIS_PASSWORD=${REDIS_PROD_PASSWORD}
REDIS_CONFIG=--maxmemory 512mb --maxmemory-policy allkeys-lru

# Application
DEBUG=false
HOT_RELOAD=false
EOF

# API 애플리케이션 구조
mkdir -p api
cat > api/Dockerfile << 'EOF'
# Multi-stage build
FROM node:16-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Development stage
FROM node:16-alpine AS development
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Production stage
FROM base AS production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

cat > api/package.json << 'EOF'
{
  "name": "multi-env-api",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
EOF

cat > api/server.js << 'EOF'
const express = require('express');
const app = express();

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    environment: process.env.NODE_ENV,
    debug: process.env.DEBUG === 'true',
    timestamp: new Date().toISOString()
  });
});

app.listen(3000, '0.0.0.0', () => {
  console.log(`API server running in ${process.env.NODE_ENV} mode`);
});
EOF
```

## 3. 실습: 배포 스크립트 자동화 (15분)

### 환경별 배포 스크립트

```bash
# 배포 스크립트
cat > deploy.sh << 'EOF'
#!/bin/bash

ENVIRONMENT=${1:-development}
ACTION=${2:-up}

# 환경 검증
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    echo "Error: Invalid environment. Use: development, staging, or production"
    exit 1
fi

echo "🚀 Deploying to $ENVIRONMENT environment..."

# 환경 변수 로드
if [ -f ".env.$ENVIRONMENT" ]; then
    export $(cat .env.$ENVIRONMENT | grep -v '^#' | xargs)
    echo "✅ Environment variables loaded from .env.$ENVIRONMENT"
else
    echo "⚠️  No .env.$ENVIRONMENT file found, using defaults"
fi

# Compose 파일 구성
COMPOSE_FILES="-f docker-compose.yml"

if [ -f "docker-compose.$ENVIRONMENT.yml" ]; then
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.$ENVIRONMENT.yml"
    echo "✅ Using docker-compose.$ENVIRONMENT.yml override"
fi

# 환경별 특별 처리
case $ENVIRONMENT in
    "development")
        echo "🔧 Development mode: enabling hot reload and debug tools"
        ;;
    "staging")
        echo "🧪 Staging mode: production-like environment for testing"
        ;;
    "production")
        echo "🏭 Production mode: optimized and secured deployment"
        # 프로덕션 전용 검증
        if [ -z "$POSTGRES_PROD_PASSWORD" ]; then
            echo "❌ POSTGRES_PROD_PASSWORD not set for production"
            exit 1
        fi
        ;;
esac

# Docker Compose 실행
case $ACTION in
    "up")
        docker-compose $COMPOSE_FILES up -d
        ;;
    "down")
        docker-compose $COMPOSE_FILES down
        ;;
    "restart")
        docker-compose $COMPOSE_FILES restart
        ;;
    "logs")
        docker-compose $COMPOSE_FILES logs -f
        ;;
    "ps")
        docker-compose $COMPOSE_FILES ps
        ;;
    *)
        echo "Available actions: up, down, restart, logs, ps"
        exit 1
        ;;
esac

echo "✅ Deployment action '$ACTION' completed for $ENVIRONMENT"
EOF

chmod +x deploy.sh

# 환경 검증 스크립트
cat > validate-env.sh << 'EOF'
#!/bin/bash

ENVIRONMENT=${1:-development}

echo "🔍 Validating $ENVIRONMENT environment..."

# 필수 파일 확인
required_files=("docker-compose.yml" ".env.$ENVIRONMENT")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        exit 1
    fi
done

# 환경 변수 로드 및 검증
source .env.$ENVIRONMENT

required_vars=("NODE_ENV" "POSTGRES_DB" "POSTGRES_USER")
for var in "${required_vars[@]}"; do
    if [ -n "${!var}" ]; then
        echo "✅ $var is set"
    else
        echo "❌ $var is not set"
        exit 1
    fi
done

# 환경별 특별 검증
case $ENVIRONMENT in
    "production")
        if [ "$POSTGRES_PASSWORD" = "password" ]; then
            echo "❌ Using default password in production!"
            exit 1
        fi
        echo "✅ Production security checks passed"
        ;;
esac

echo "✅ Environment validation completed"
EOF

chmod +x validate-env.sh

# 헬스체크 스크립트
cat > health-check.sh << 'EOF'
#!/bin/bash

ENVIRONMENT=${1:-development}
BASE_URL="http://localhost"

# 환경별 포트 설정
case $ENVIRONMENT in
    "development") PORT=8080 ;;
    "staging"|"production") PORT=80 ;;
esac

echo "🏥 Health checking $ENVIRONMENT environment at $BASE_URL:$PORT"

# 서비스 헬스체크
services=("web" "api")
for service in "${services[@]}"; do
    echo "Checking $service..."
    
    case $service in
        "web")
            if curl -f -s "$BASE_URL:$PORT" > /dev/null; then
                echo "✅ Web service is healthy"
            else
                echo "❌ Web service is unhealthy"
            fi
            ;;
        "api")
            api_port=$([[ $ENVIRONMENT == "development" ]] && echo "3000" || echo "$PORT")
            if curl -f -s "$BASE_URL:$api_port/health" > /dev/null; then
                echo "✅ API service is healthy"
            else
                echo "❌ API service is unhealthy"
            fi
            ;;
    esac
done

echo "✅ Health check completed"
EOF

chmod +x health-check.sh
```

### CI/CD 파이프라인 통합

```bash
# GitHub Actions 워크플로우
mkdir -p .github/workflows

cat > .github/workflows/deploy.yml << 'EOF'
name: Multi-Environment Deploy

on:
  push:
    branches:
      - main
      - develop
      - staging
  pull_request:
    branches:
      - main

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Validate environments
        run: |
          ./validate-env.sh development
          ./validate-env.sh staging

  deploy-dev:
    if: github.ref == 'refs/heads/develop'
    needs: test
    runs-on: ubuntu-latest
    environment: development
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Development
        run: |
          ./deploy.sh development up
          sleep 30
          ./health-check.sh development

  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    needs: test
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Staging
        run: |
          ./deploy.sh staging up
          sleep 60
          ./health-check.sh staging

  deploy-prod:
    if: github.ref == 'refs/heads/main'
    needs: test
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Production
        env:
          POSTGRES_PROD_PASSWORD: ${{ secrets.POSTGRES_PROD_PASSWORD }}
          REDIS_PROD_PASSWORD: ${{ secrets.REDIS_PROD_PASSWORD }}
        run: |
          ./validate-env.sh production
          ./deploy.sh production up
          sleep 90
          ./health-check.sh production
EOF

# Docker Compose 프로파일 활용
cat > docker-compose.profiles.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:alpine
    profiles: ["web", "full"]

  api:
    build: ./api
    profiles: ["api", "full"]

  postgres:
    image: postgres:13
    profiles: ["db", "full"]

  # 개발 도구들
  adminer:
    image: adminer
    profiles: ["dev-tools"]
    ports:
      - "8081:8080"

  # 모니터링 도구들
  prometheus:
    image: prom/prometheus
    profiles: ["monitoring"]
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    profiles: ["monitoring"]
    ports:
      - "3001:3000"
EOF
```

## 4. 실습: 환경별 배포 테스트 (10분)

### 배포 시나리오 테스트

```bash
# 배포 테스트 스크립트
cat > test-deployments.sh << 'EOF'
#!/bin/bash

echo "🧪 Testing multi-environment deployments..."

# 1. 개발 환경 배포
echo "1. Testing Development Environment"
./validate-env.sh development
./deploy.sh development up
sleep 30
./health-check.sh development
./deploy.sh development down

# 2. 스테이징 환경 배포
echo "2. Testing Staging Environment"
./validate-env.sh staging
./deploy.sh staging up
sleep 30
./health-check.sh staging
./deploy.sh staging down

# 3. 프로파일 기반 배포 테스트
echo "3. Testing Profile-based Deployment"
export COMPOSE_PROFILES=web,api,db
docker-compose -f docker-compose.profiles.yml up -d
sleep 20
docker-compose -f docker-compose.profiles.yml ps
docker-compose -f docker-compose.profiles.yml down

# 4. 개발 도구 포함 배포
echo "4. Testing with Development Tools"
export COMPOSE_PROFILES=full,dev-tools
docker-compose -f docker-compose.profiles.yml up -d
sleep 20
curl -s http://localhost:8081 > /dev/null && echo "✅ Adminer accessible"
docker-compose -f docker-compose.profiles.yml down

echo "✅ All deployment tests completed"
EOF

chmod +x test-deployments.sh

# 환경 비교 스크립트
cat > compare-environments.sh << 'EOF'
#!/bin/bash

echo "📊 Environment Configuration Comparison"
echo "======================================"

environments=("development" "staging" "production")

for env in "${environments[@]}"; do
    echo ""
    echo "🏷️  $env Environment:"
    echo "-------------------"
    
    if [ -f ".env.$env" ]; then
        echo "Environment Variables:"
        grep -E "^(NODE_ENV|LOG_LEVEL|DEBUG)" .env.$env || echo "  (not configured)"
        
        echo "Database Configuration:"
        grep -E "^POSTGRES_" .env.$env || echo "  (not configured)"
        
        echo "Redis Configuration:"
        grep -E "^REDIS_" .env.$env || echo "  (not configured)"
    else
        echo "❌ Configuration file not found"
    fi
done

echo ""
echo "📋 Compose File Analysis:"
echo "========================"

for env in "${environments[@]}"; do
    if [ -f "docker-compose.$env.yml" ]; then
        echo ""
        echo "$env overrides:"
        echo "- Services: $(grep -c "^  [a-zA-Z]" docker-compose.$env.yml)"
        echo "- Ports exposed: $(grep -c "ports:" docker-compose.$env.yml)"
        echo "- Volumes: $(grep -c "volumes:" docker-compose.$env.yml)"
        echo "- Deploy config: $(grep -c "deploy:" docker-compose.$env.yml)"
    fi
done
EOF

chmod +x compare-environments.sh

# 실행 및 검증
./compare-environments.sh
./test-deployments.sh
```

## 5. Q&A 및 정리 (5분)

### 환경별 배포 전략 검증

```bash
# 최종 검증 및 정리
echo "=== 환경별 배포 전략 검증 ==="

# 모든 환경 설정 검증
for env in development staging production; do
    echo "Validating $env environment..."
    ./validate-env.sh $env
done

# 배포 스크립트 테스트
echo "Testing deployment scripts..."
./deploy.sh development ps
./deploy.sh staging ps  
# ./deploy.sh production ps  # 프로덕션은 실제 시크릿 필요

# 정리 및 요약
cat > session5-summary.md << 'EOF'
# Session 5 요약: 환경별 배포 전략

## 구현한 환경 구조
```
Base: docker-compose.yml (공통 설정)
├── Development: docker-compose.dev.yml + .env.development
├── Staging: docker-compose.staging.yml + .env.staging
└── Production: docker-compose.prod.yml + .env.production
```

## 환경별 특징
### Development
- 소스 코드 마운트 (Hot Reload)
- 디버그 도구 포함 (Adminer, Redis Commander)
- 모든 포트 노출
- 개발용 패스워드

### Staging
- 프로덕션과 유사한 설정
- 모니터링 도구 포함
- 리소스 제한 적용
- 보안 강화된 패스워드

### Production
- 최적화된 이미지 사용
- 스케일링 설정 (replicas)
- 엄격한 리소스 제한
- 시크릿 관리 시스템 연동

## 배포 자동화
1. **환경 검증**: validate-env.sh
2. **배포 실행**: deploy.sh
3. **헬스체크**: health-check.sh
4. **CI/CD 통합**: GitHub Actions

## 설정 관리 전략
- **환경 변수**: .env.{environment} 파일
- **Override 파일**: docker-compose.{environment}.yml
- **프로파일**: 선택적 서비스 실행
- **시크릿**: 외부 시크릿 관리 시스템

## 보안 고려사항
- 프로덕션 시크릿 분리
- 환경별 네트워크 격리
- 리소스 제한 적용
- 최소 권한 원칙
EOF

echo "Session 5 완료! 요약: session5-summary.md"
```

## 💡 핵심 키워드
- **환경 분리**: Development, Staging, Production
- **Override 파일**: docker-compose.{env}.yml
- **프로파일**: 선택적 서비스 실행
- **배포 자동화**: 스크립트, CI/CD 파이프라인

## 📚 참고 자료
- [Compose Override](https://docs.docker.com/compose/extends/)
- [환경 변수](https://docs.docker.com/compose/environment-variables/)
- [프로파일](https://docs.docker.com/compose/profiles/)

## 🔧 실습 체크리스트
- [ ] 환경별 Compose 파일 구성
- [ ] 환경 변수 및 시크릿 관리
- [ ] 배포 스크립트 자동화
- [ ] CI/CD 파이프라인 통합
- [ ] 환경별 배포 테스트 및 검증
