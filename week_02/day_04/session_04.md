# Session 4: 의존성과 헬스체크

## 📍 교과과정에서의 위치
이 세션은 **Week 2 > Day 4 > Session 4**로, Session 3의 데이터 관리를 바탕으로 서비스 의존성과 헬스체크를 통한 안정적인 서비스 시작 순서를 학습합니다.

## 학습 목표 (5분)
- **서비스 의존성** 관리 및 **시작 순서** 제어
- **헬스체크** 구현 및 **장애 감지** 자동화
- **재시작 정책** 설정 및 **복구 전략** 수립

## 1. 이론: 서비스 의존성 관리 (20분)

### 의존성 유형과 패턴

```mermaid
graph TB
    subgraph "의존성 레벨"
        A[Level 1: Infrastructure] --> B[Database, Cache, Message Queue]
        C[Level 2: Core Services] --> D[Auth, User, Config Services]
        E[Level 3: Business Logic] --> F[Order, Payment, Inventory]
        G[Level 4: API Gateway] --> H[Routing, Load Balancing]
        I[Level 5: Frontend] --> J[Web UI, Mobile API]
    end
    
    B --> D
    D --> F
    F --> H
    H --> I
```

### depends_on vs healthcheck

```yaml
# 기본 의존성 (컨테이너 시작만 대기)
services:
  web:
    depends_on:
      - db
  db:
    image: postgres

# 헬스체크 기반 의존성 (서비스 준비 완료 대기)
services:
  web:
    depends_on:
      db:
        condition: service_healthy
  db:
    image: postgres
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "user"]
      interval: 10s
      timeout: 5s
      retries: 5
```

## 2. 실습: 의존성 체인 구현 (15분)

### 복잡한 의존성 구조

```bash
mkdir -p dependency-demo && cd dependency-demo

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Level 1: Infrastructure
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d appdb"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    volumes:
      - redis_data:/data

  rabbitmq:
    image: rabbitmq:3-management
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: secret
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 30s
      timeout: 10s
      retries: 5
    ports:
      - "15672:15672"

  # Level 2: Core Services
  auth-service:
    build: ./services/auth
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  config-service:
    build: ./services/config
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      - DB_HOST=postgres
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3002/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Level 3: Business Services
  user-service:
    build: ./services/user
    depends_on:
      auth-service:
        condition: service_healthy
      config-service:
        condition: service_healthy
    environment:
      - AUTH_SERVICE_URL=http://auth-service:3001
      - CONFIG_SERVICE_URL=http://config-service:3002
      - DB_HOST=postgres
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3003/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  order-service:
    build: ./services/order
    depends_on:
      user-service:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    environment:
      - USER_SERVICE_URL=http://user-service:3003
      - RABBITMQ_URL=amqp://admin:secret@rabbitmq:5672
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3004/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  # Level 4: API Gateway
  api-gateway:
    build: ./gateway
    depends_on:
      user-service:
        condition: service_healthy
      order-service:
        condition: service_healthy
    ports:
      - "8080:3000"
    environment:
      - USER_SERVICE_URL=http://user-service:3003
      - ORDER_SERVICE_URL=http://order-service:3004
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
  redis_data:
EOF

# 서비스 디렉토리 생성
mkdir -p {services/{auth,config,user,order},gateway}
```

### 헬스체크 구현

```bash
# Auth Service
cat > services/auth/package.json << 'EOF'
{
  "name": "auth-service",
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.8.0",
    "redis": "^4.5.0"
  }
}
EOF

cat > services/auth/server.js << 'EOF'
const express = require('express');
const { Client } = require('pg');
const redis = require('redis');

const app = express();
app.use(express.json());

let dbConnected = false;
let redisConnected = false;

// Database connection
const db = new Client({
  host: process.env.DB_HOST,
  database: 'appdb',
  user: 'user',
  password: 'password'
});

db.connect()
  .then(() => {
    dbConnected = true;
    console.log('Database connected');
  })
  .catch(console.error);

// Redis connection
const redisClient = redis.createClient({
  host: process.env.REDIS_HOST
});

redisClient.connect()
  .then(() => {
    redisConnected = true;
    console.log('Redis connected');
  })
  .catch(console.error);

// Health check endpoint
app.get('/health', (req, res) => {
  const health = {
    service: 'auth-service',
    status: 'healthy',
    timestamp: new Date().toISOString(),
    dependencies: {
      database: dbConnected ? 'connected' : 'disconnected',
      redis: redisConnected ? 'connected' : 'disconnected'
    }
  };

  const isHealthy = dbConnected && redisConnected;
  res.status(isHealthy ? 200 : 503).json(health);
});

// Readiness check
app.get('/ready', (req, res) => {
  if (dbConnected && redisConnected) {
    res.json({ status: 'ready' });
  } else {
    res.status(503).json({ status: 'not ready' });
  }
});

app.listen(3001, '0.0.0.0', () => {
  console.log('Auth service running on port 3001');
});
EOF

cat > services/auth/Dockerfile << 'EOF'
FROM node:alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3001
CMD ["node", "server.js"]
EOF

# 다른 서비스들도 유사한 구조로 생성
for service in config user order; do
  cp -r services/auth/* services/$service/
  port=$((3001 + $(echo "auth config user order" | tr ' ' '\n' | grep -n $service | cut -d: -f1)))
  sed -i "s/auth-service/${service}-service/g" services/$service/server.js
  sed -i "s/3001/$port/g" services/$service/server.js
  sed -i "s/3001/$port/g" services/$service/Dockerfile
done
```

## 3. 실습: 재시작 정책과 복구 전략 (15분)

### 재시작 정책 설정

```bash
cat > docker-compose.restart.yml << 'EOF'
version: '3.8'

services:
  # 항상 재시작 (중요한 인프라)
  postgres:
    image: postgres:13
    restart: always
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password

  # 실패 시에만 재시작 (최대 3회)
  redis:
    image: redis:alpine
    restart: on-failure:3

  # 수동으로 중지하지 않는 한 재시작
  api-gateway:
    build: ./gateway
    restart: unless-stopped
    ports:
      - "8080:3000"

  # 재시작 안함 (일회성 작업)
  migration:
    image: migrate/migrate
    restart: "no"
    command: >
      -path=/migrations 
      -database postgres://user:password@postgres:5432/appdb?sslmode=disable 
      up

  # 조건부 재시작 (헬스체크 실패 시)
  web-service:
    build: ./services/web
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
EOF
```

### 장애 시나리오 테스트

```bash
# 장애 테스트 스크립트
cat > test-failures.sh << 'EOF'
#!/bin/bash

echo "=== 장애 시나리오 테스트 ==="

# 1. 데이터베이스 장애 시뮬레이션
echo "1. 데이터베이스 중지 테스트"
docker-compose stop postgres
sleep 10

echo "서비스 상태 확인:"
docker-compose ps

echo "헬스체크 상태:"
curl -s http://localhost:8080/health | jq '.dependencies.database' || echo "API Gateway 응답 없음"

# 2. 데이터베이스 복구
echo "2. 데이터베이스 복구"
docker-compose start postgres
sleep 30

echo "복구 후 상태:"
curl -s http://localhost:8080/health | jq '.dependencies.database'

# 3. 서비스 재시작 테스트
echo "3. 서비스 재시작 테스트"
docker-compose restart user-service
sleep 20

echo "재시작 후 상태:"
docker-compose ps | grep user-service

# 4. 연쇄 장애 테스트
echo "4. 연쇄 장애 테스트"
docker-compose stop redis rabbitmq
sleep 10

echo "연쇄 장애 상태:"
docker-compose ps

# 복구
docker-compose start redis rabbitmq
sleep 30
echo "전체 복구 완료"
EOF

chmod +x test-failures.sh
```

### 자동 복구 시스템

```bash
# 모니터링 및 자동 복구 서비스
cat > docker-compose.monitoring.yml << 'EOF'
version: '3.8'

services:
  # 헬스체크 모니터
  health-monitor:
    image: alpine
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./monitor.sh:/monitor.sh:ro
    command: sh /monitor.sh
    depends_on:
      - api-gateway

  # 로그 수집기
  log-collector:
    image: fluent/fluent-bit
    restart: unless-stopped
    volumes:
      - ./fluent-bit.conf:/fluent-bit/etc/fluent-bit.conf:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    ports:
      - "24224:24224"

  # 알림 서비스
  alerting:
    build: ./alerting
    restart: unless-stopped
    environment:
      - WEBHOOK_URL=http://localhost:9093/webhook
    volumes:
      - ./alerts:/alerts
EOF

# 헬스 모니터 스크립트
cat > monitor.sh << 'EOF'
#!/bin/sh

apk add --no-cache curl docker-cli

while true; do
    echo "$(date): Health monitoring check"
    
    # API Gateway 헬스체크
    if ! curl -f -s http://api-gateway:3000/health > /dev/null; then
        echo "API Gateway unhealthy, restarting..."
        docker restart dependency-demo_api-gateway_1
    fi
    
    # 개별 서비스 헬스체크
    for service in auth-service config-service user-service order-service; do
        container_name="dependency-demo_${service}_1"
        if [ "$(docker inspect -f '{{.State.Health.Status}}' $container_name 2>/dev/null)" = "unhealthy" ]; then
            echo "$service is unhealthy, restarting..."
            docker restart $container_name
        fi
    done
    
    sleep 30
done
EOF

# Fluent Bit 설정
cat > fluent-bit.conf << 'EOF'
[SERVICE]
    Flush         1
    Log_Level     info
    Daemon        off

[INPUT]
    Name              tail
    Path              /var/lib/docker/containers/*/*-json.log
    Parser            docker
    Tag               docker.*
    Refresh_Interval  5

[OUTPUT]
    Name  stdout
    Match *
EOF
```

## 4. 실습: 점진적 배포 (Graceful Deployment) (10분)

### 무중단 배포 전략

```bash
# 블루-그린 배포 시뮬레이션
cat > docker-compose.blue-green.yml << 'EOF'
version: '3.8'

services:
  # 로드 밸런서
  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx-blue-green.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app-blue
      - app-green

  # Blue 환경 (현재 운영)
  app-blue:
    build: ./app
    environment:
      - VERSION=blue
      - COLOR=blue
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3

  # Green 환경 (새 버전)
  app-green:
    build: ./app
    environment:
      - VERSION=green
      - COLOR=green
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
EOF

# Nginx 설정 (Blue-Green)
cat > nginx-blue-green.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream app_blue {
        server app-blue:3000;
    }
    
    upstream app_green {
        server app-green:3000;
    }
    
    # 기본적으로 Blue 환경으로 라우팅
    upstream app_backend {
        server app-blue:3000 weight=100;
        server app-green:3000 weight=0;
    }
    
    server {
        listen 80;
        
        location / {
            proxy_pass http://app_backend;
            proxy_set_header Host $host;
        }
        
        # 헬스체크 엔드포인트
        location /health {
            proxy_pass http://app_backend/health;
        }
        
        # Blue 환경 직접 접근
        location /blue {
            proxy_pass http://app_blue/;
        }
        
        # Green 환경 직접 접근
        location /green {
            proxy_pass http://app_green/;
        }
    }
}
EOF

# 배포 스크립트
cat > deploy.sh << 'EOF'
#!/bin/bash

CURRENT_ENV=${1:-blue}
NEW_ENV=${2:-green}

echo "Starting deployment from $CURRENT_ENV to $NEW_ENV"

# 1. 새 환경 헬스체크
echo "Checking $NEW_ENV environment health..."
timeout 60 bash -c "
    while ! curl -f -s http://localhost:8080/$NEW_ENV/health; do
        echo 'Waiting for $NEW_ENV to be healthy...'
        sleep 5
    done
"

# 2. 점진적 트래픽 전환
echo "Starting gradual traffic shift..."
for weight in 10 25 50 75 100; do
    echo "Shifting ${weight}% traffic to $NEW_ENV"
    
    # Nginx 설정 업데이트 (실제로는 동적 설정 변경)
    sed -i "s/weight=100/weight=$((100-weight))/g" nginx-blue-green.conf
    sed -i "s/weight=0/weight=${weight}/g" nginx-blue-green.conf
    
    # Nginx 리로드
    docker-compose exec nginx nginx -s reload
    
    # 헬스체크
    sleep 10
    if ! curl -f -s http://localhost:8080/health; then
        echo "Health check failed, rolling back..."
        # 롤백 로직
        exit 1
    fi
done

echo "Deployment completed successfully"
EOF

chmod +x deploy.sh
```

## 5. Q&A 및 정리 (5분)

### 의존성 및 헬스체크 검증

```bash
# 전체 시스템 시작 및 검증
echo "=== 의존성 체인 시작 ==="
docker-compose up -d

# 시작 순서 확인
echo "서비스 시작 순서 모니터링:"
for i in {1..10}; do
    echo "Check $i:"
    docker-compose ps --format "table {{.Name}}\t{{.Status}}"
    sleep 10
done

# 헬스체크 상태 확인
echo "=== 헬스체크 상태 ==="
for service in postgres redis auth-service config-service user-service order-service api-gateway; do
    status=$(docker inspect dependency-demo_${service}_1 --format '{{.State.Health.Status}}' 2>/dev/null || echo "no healthcheck")
    echo "$service: $status"
done

# 의존성 테스트
./test-failures.sh

# 정리 및 요약
cat > session4-summary.md << 'EOF'
# Session 4 요약: 의존성과 헬스체크

## 구현한 기능
1. **의존성 체인**: 5단계 서비스 의존성 구조
2. **헬스체크**: 각 서비스별 상태 모니터링
3. **재시작 정책**: 장애 상황별 복구 전략
4. **자동 복구**: 모니터링 기반 자동 재시작
5. **점진적 배포**: 블루-그린 배포 전략

## 의존성 레벨
```
Level 1: postgres, redis, rabbitmq (Infrastructure)
Level 2: auth-service, config-service (Core)
Level 3: user-service, order-service (Business)
Level 4: api-gateway (Gateway)
Level 5: nginx (Frontend)
```

## 헬스체크 전략
- **Infrastructure**: 기본 연결성 확인
- **Services**: HTTP 엔드포인트 + 의존성 확인
- **Gateway**: 다운스트림 서비스 상태 집계

## 재시작 정책
- **always**: 중요한 인프라 서비스
- **on-failure**: 일시적 장애 복구
- **unless-stopped**: 일반 애플리케이션 서비스
- **no**: 일회성 작업

## 장애 복구 패턴
1. **Circuit Breaker**: 장애 전파 차단
2. **Retry Logic**: 일시적 장애 재시도
3. **Graceful Degradation**: 기능 축소 운영
4. **Auto Healing**: 자동 복구 시스템
EOF

echo "Session 4 완료! 요약: session4-summary.md"
```

## 💡 핵심 키워드
- **서비스 의존성**: depends_on, condition, 시작 순서
- **헬스체크**: 상태 모니터링, 자동 복구
- **재시작 정책**: always, on-failure, unless-stopped
- **점진적 배포**: 블루-그린, 카나리, 롤링 업데이트

## 📚 참고 자료
- [Compose 의존성](https://docs.docker.com/compose/compose-file/#depends_on)
- [헬스체크](https://docs.docker.com/compose/compose-file/#healthcheck)
- [재시작 정책](https://docs.docker.com/compose/compose-file/#restart)

## 🔧 실습 체크리스트
- [ ] 다단계 서비스 의존성 구현
- [ ] 헬스체크 기반 서비스 준비 확인
- [ ] 재시작 정책 설정 및 테스트
- [ ] 장애 시나리오 테스트 및 복구
- [ ] 점진적 배포 전략 구현
