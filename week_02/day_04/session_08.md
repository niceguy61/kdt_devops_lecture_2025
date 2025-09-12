# Session 8: Day 4 종합 프로젝트

## 📍 교과과정에서의 위치
이 세션은 **Week 2 > Day 4 > Session 8**로, Day 4에서 학습한 모든 Docker Compose 기술을 통합하여 완전한 프로덕션급 애플리케이션 스택을 구축합니다.

## 학습 목표 (5분)
- **Day 4 전체 내용** 통합 및 **엔터프라이즈급** 애플리케이션 구축
- **프로덕션 배포** 고려사항 및 **운영 자동화**
- **Docker Compose** 모범 사례 및 **차세대 기술** 연결

## 1. 이론: 프로덕션 배포 고려사항 (15분)

### 엔터프라이즈 아키텍처

```mermaid
graph TB
    subgraph "Load Balancer Tier"
        A[Nginx LB] --> B[SSL Termination]
    end
    
    subgraph "Application Tier"
        C[Web Services] --> D[API Gateway]
        D --> E[Microservices]
    end
    
    subgraph "Data Tier"
        F[Primary DB] --> G[Read Replicas]
        H[Cache Cluster] --> I[Message Queue]
    end
    
    subgraph "Operations Tier"
        J[Monitoring] --> K[Logging]
        L[Backup] --> M[Security]
    end
    
    B --> C
    E --> F
    E --> H
    C --> J
```

### 프로덕션 체크리스트

```
보안:
├── 시크릿 관리 (외부 시크릿 저장소)
├── 네트워크 격리 (방화벽, VPN)
├── 이미지 스캔 (취약점 검사)
└── 접근 제어 (RBAC, 인증)

성능:
├── 리소스 제한 (CPU, 메모리)
├── 헬스체크 (liveness, readiness)
├── 스케일링 (수평, 수직)
└── 캐싱 (Redis, CDN)

가용성:
├── 다중화 (replica, failover)
├── 백업 (데이터, 설정)
├── 모니터링 (메트릭, 알림)
└── 복구 (disaster recovery)

운영:
├── 로깅 (중앙 집중식)
├── 배포 (CI/CD, 롤링)
├── 설정 관리 (환경별)
└── 문서화 (runbook)
```

## 2. 실습: 완전한 애플리케이션 스택 구축 (30분)

### 프로젝트 구조 생성

```bash
mkdir -p enterprise-stack && cd enterprise-stack

# 디렉토리 구조
mkdir -p {
  services/{web,api,auth,notification},
  infrastructure/{nginx,postgres,redis,rabbitmq},
  monitoring/{prometheus,grafana,elasticsearch},
  config/{dev,staging,prod},
  scripts,
  docs
}
```

### 메인 Compose 파일

```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

x-common-variables: &common-variables
  NODE_ENV: ${NODE_ENV:-production}
  LOG_LEVEL: ${LOG_LEVEL:-info}
  
x-restart-policy: &restart-policy
  restart: unless-stopped

services:
  # Load Balancer
  nginx:
    <<: *restart-policy
    build: ./infrastructure/nginx
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - ./config/${NODE_ENV:-prod}/nginx.conf:/etc/nginx/nginx.conf:ro
      - ssl_certs:/etc/nginx/ssl:ro
    depends_on:
      - web
      - api
    networks:
      - frontend

  # Web Application
  web:
    <<: *restart-policy
    build: 
      context: ./services/web
      target: ${BUILD_TARGET:-production}
    environment:
      <<: *common-variables
      API_URL: http://api:3000
    volumes:
      - web_uploads:/app/uploads
    networks:
      - frontend
      - backend
    deploy:
      replicas: ${WEB_REPLICAS:-3}
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  # API Gateway
  api:
    <<: *restart-policy
    build: ./services/api
    environment:
      <<: *common-variables
      DB_HOST: postgres-primary
      REDIS_HOST: redis-primary
      RABBITMQ_URL: amqp://guest:guest@rabbitmq:5672
    networks:
      - backend
      - database
    depends_on:
      postgres-primary:
        condition: service_healthy
      redis-primary:
        condition: service_healthy
    deploy:
      replicas: ${API_REPLICAS:-2}

  # Authentication Service
  auth-service:
    <<: *restart-policy
    build: ./services/auth
    environment:
      <<: *common-variables
      JWT_SECRET: ${JWT_SECRET}
      DB_HOST: postgres-primary
    networks:
      - backend
      - database
    depends_on:
      postgres-primary:
        condition: service_healthy

  # Notification Service
  notification-service:
    <<: *restart-policy
    build: ./services/notification
    environment:
      <<: *common-variables
      RABBITMQ_URL: amqp://guest:guest@rabbitmq:5672
      SMTP_HOST: ${SMTP_HOST}
    networks:
      - backend
    depends_on:
      - rabbitmq

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
  database:
    driver: bridge
    internal: true

volumes:
  ssl_certs:
  web_uploads:
EOF
```

### 데이터베이스 클러스터

```bash
cat > docker-compose.database.yml << 'EOF'
version: '3.8'

services:
  # PostgreSQL Primary
  postgres-primary:
    image: postgres:13
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-appdb}
      POSTGRES_USER: ${POSTGRES_USER:-admin}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: ${REPLICATION_PASSWORD}
    volumes:
      - postgres_primary_data:/var/lib/postgresql/data
      - ./infrastructure/postgres/primary.conf:/etc/postgresql/postgresql.conf
      - ./infrastructure/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - database
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-admin}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # PostgreSQL Read Replica
  postgres-replica:
    image: postgres:13
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-admin}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_PRIMARY_HOST: postgres-primary
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: ${REPLICATION_PASSWORD}
    volumes:
      - postgres_replica_data:/var/lib/postgresql/data
    networks:
      - database
    depends_on:
      postgres-primary:
        condition: service_healthy

  # Redis Primary
  redis-primary:
    image: redis:6-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    volumes:
      - redis_primary_data:/data
    networks:
      - database
    healthcheck:
      test: ["CMD", "redis-cli", "--no-auth-warning", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Replica
  redis-replica:
    image: redis:6-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD} --replicaof redis-primary 6379 --masterauth ${REDIS_PASSWORD}
    volumes:
      - redis_replica_data:/data
    networks:
      - database
    depends_on:
      redis-primary:
        condition: service_healthy

  # RabbitMQ
  rabbitmq:
    image: rabbitmq:3-management
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER:-admin}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD}
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - backend
    ports:
      - "15672:15672"  # Management UI

volumes:
  postgres_primary_data:
  postgres_replica_data:
  redis_primary_data:
  redis_replica_data:
  rabbitmq_data:
EOF
```

### 모니터링 스택

```bash
cat > docker-compose.monitoring.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus:/etc/prometheus:ro
      - prometheus_data:/prometheus
    networks:
      - monitoring
      - backend
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD:-admin}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana:/etc/grafana/provisioning:ro
    networks:
      - monitoring
    ports:
      - "3000:3000"

  elasticsearch:
    image: elasticsearch:7.17.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    networks:
      - monitoring

  kibana:
    image: kibana:7.17.0
    environment:
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200
    networks:
      - monitoring
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch

networks:
  monitoring:
    driver: bridge

volumes:
  prometheus_data:
  grafana_data:
  elasticsearch_data:
EOF
```

### 배포 자동화 스크립트

```bash
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
set -e

ENVIRONMENT=${1:-production}
ACTION=${2:-deploy}

echo "🚀 Enterprise Stack Deployment"
echo "Environment: $ENVIRONMENT"
echo "Action: $ACTION"

# 환경 설정 로드
if [ -f "config/$ENVIRONMENT/.env" ]; then
    source config/$ENVIRONMENT/.env
    echo "✅ Environment variables loaded"
else
    echo "❌ Environment file not found: config/$ENVIRONMENT/.env"
    exit 1
fi

# 보안 검증
if [ "$ENVIRONMENT" = "production" ]; then
    required_secrets=("POSTGRES_PASSWORD" "REDIS_PASSWORD" "JWT_SECRET")
    for secret in "${required_secrets[@]}"; do
        if [ -z "${!secret}" ]; then
            echo "❌ Required secret not set: $secret"
            exit 1
        fi
    done
fi

# Compose 파일 구성
COMPOSE_FILES="-f docker-compose.yml -f docker-compose.database.yml"

if [ "$MONITORING_ENABLED" = "true" ]; then
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.monitoring.yml"
fi

case $ACTION in
    "deploy")
        echo "🔄 Deploying services..."
        docker-compose $COMPOSE_FILES up -d
        ;;
    "update")
        echo "🔄 Updating services..."
        docker-compose $COMPOSE_FILES pull
        docker-compose $COMPOSE_FILES up -d --force-recreate
        ;;
    "scale")
        SERVICE=${3:-web}
        REPLICAS=${4:-3}
        echo "📈 Scaling $SERVICE to $REPLICAS replicas..."
        docker-compose $COMPOSE_FILES up -d --scale $SERVICE=$REPLICAS
        ;;
    "stop")
        echo "🛑 Stopping services..."
        docker-compose $COMPOSE_FILES stop
        ;;
    "down")
        echo "🗑️ Removing services..."
        docker-compose $COMPOSE_FILES down
        ;;
    *)
        echo "Available actions: deploy, update, scale, stop, down"
        exit 1
        ;;
esac

echo "✅ Action '$ACTION' completed for $ENVIRONMENT environment"
EOF

chmod +x scripts/deploy.sh
```

### 헬스체크 및 검증

```bash
cat > scripts/health-check.sh << 'EOF'
#!/bin/bash

echo "🏥 Enterprise Stack Health Check"

services=(
    "http://localhost/health:Load Balancer"
    "http://localhost:3000/api/health:Grafana"
    "http://localhost:9090/-/healthy:Prometheus"
    "http://localhost:5601/api/status:Kibana"
)

all_healthy=true

for service in "${services[@]}"; do
    IFS=':' read -r url name <<< "$service"
    
    if curl -f -s --max-time 10 "$url" > /dev/null 2>&1; then
        echo "✅ $name is healthy"
    else
        echo "❌ $name is unhealthy"
        all_healthy=false
    fi
done

# 데이터베이스 연결 테스트
if docker-compose exec -T postgres-primary pg_isready -U admin > /dev/null 2>&1; then
    echo "✅ PostgreSQL Primary is healthy"
else
    echo "❌ PostgreSQL Primary is unhealthy"
    all_healthy=false
fi

# Redis 연결 테스트
if docker-compose exec -T redis-primary redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis Primary is healthy"
else
    echo "❌ Redis Primary is unhealthy"
    all_healthy=false
fi

if $all_healthy; then
    echo "🎉 All services are healthy!"
    exit 0
else
    echo "⚠️ Some services are unhealthy"
    exit 1
fi
EOF

chmod +x scripts/health-check.sh
```

## 3. Q&A 및 정리 (5분)

### 최종 검증 및 문서화

```bash
# 환경 설정 파일 생성
mkdir -p config/prod
cat > config/prod/.env << 'EOF'
NODE_ENV=production
BUILD_TARGET=production
WEB_PORT=80
SSL_PORT=443
WEB_REPLICAS=3
API_REPLICAS=2
MONITORING_ENABLED=true

# Database
POSTGRES_DB=proddb
POSTGRES_USER=admin
POSTGRES_PASSWORD=secure_db_password
REPLICATION_PASSWORD=secure_repl_password

# Cache
REDIS_PASSWORD=secure_redis_password

# Message Queue
RABBITMQ_USER=admin
RABBITMQ_PASSWORD=secure_rabbitmq_password

# Security
JWT_SECRET=super_secure_jwt_secret

# External Services
SMTP_HOST=smtp.example.com
GRAFANA_PASSWORD=secure_grafana_password
EOF

# 최종 문서 생성
cat > README.md << 'EOF'
# Enterprise Docker Compose Stack

## 아키텍처 개요
- **Load Balancer**: Nginx (SSL termination, reverse proxy)
- **Application**: Web + API + Microservices
- **Database**: PostgreSQL (Primary-Replica)
- **Cache**: Redis (Primary-Replica)
- **Message Queue**: RabbitMQ
- **Monitoring**: Prometheus + Grafana + ELK Stack

## 배포 방법
```bash
# 프로덕션 배포
./scripts/deploy.sh production deploy

# 서비스 스케일링
./scripts/deploy.sh production scale web 5

# 헬스체크
./scripts/health-check.sh
```

## 모니터링 접속 정보
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Kibana**: http://localhost:5601
- **RabbitMQ**: http://localhost:15672

## 보안 고려사항
- 모든 패스워드는 환경 변수로 관리
- 데이터베이스는 내부 네트워크로 격리
- SSL 인증서 적용 (프로덕션)
- 정기적인 보안 업데이트 필요

## 백업 전략
- 데이터베이스: 일일 자동 백업
- 설정 파일: Git 버전 관리
- 볼륨 데이터: 정기적 스냅샷
EOF

echo "✅ Enterprise Stack 구축 완료!"
echo "📖 문서: README.md"
echo "🚀 배포: ./scripts/deploy.sh production deploy"
echo "🏥 헬스체크: ./scripts/health-check.sh"
```

## 💡 핵심 키워드
- **엔터프라이즈 아키텍처**: 다중화, 보안, 모니터링
- **프로덕션 배포**: 자동화, 검증, 롤백
- **운영 자동화**: 스크립트, CI/CD, 모니터링
- **확장성**: 스케일링, 로드 밸런싱, 클러스터링

## 📚 참고 자료
- [Docker Compose 프로덕션 가이드](https://docs.docker.com/compose/production/)
- [Kubernetes 마이그레이션](https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/)

## 🔧 실습 체크리스트
- [ ] 엔터프라이즈급 멀티 서비스 스택 구축
- [ ] 데이터베이스 클러스터링 구현
- [ ] 통합 모니터링 시스템 구성
- [ ] 배포 자동화 스크립트 작성
- [ ] 프로덕션 보안 및 운영 고려사항 적용
