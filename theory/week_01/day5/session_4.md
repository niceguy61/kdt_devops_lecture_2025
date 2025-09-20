# Week 1 Day 5 Session 4: 마이크로서비스 네트워킹 챌린지

<div align="center">

**🏗️ 3-Tier 아키텍처** • **🌐 완전한 네트워킹**

*실무급 마이크로서비스 네트워킹과 데이터 관리 통합 구현*

</div>

---

## 🕘 세션 정보

**시간**: 13:00-16:00 (3시간)  
**목표**: 네트워킹과 스토리지를 결합한 완전한 마이크로서비스 시스템 구축  
**방식**: 팀 기반 통합 실습 + 단계별 구현 + 결과 발표

---

## 🎯 세션 목표

### 📚 학습 목표
- **통합 구현**: 오전에 배운 네트워킹과 스토리지 지식을 완전히 통합
- **실무 적용**: 프로덕션 환경과 유사한 3-tier 아키텍처 구축
- **보안 강화**: 네트워크 격리와 데이터 보호가 적용된 시스템 설계
- **운영 준비**: 모니터링과 로깅이 포함된 운영 가능한 시스템 완성

### 🤝 협업 목표
- **팀 아키텍처**: 복잡한 시스템을 팀으로 설계하고 구현
- **역할 분담**: 각자의 강점을 살린 자연스러운 역할 분담
- **문제 해결**: 네트워킹과 데이터 문제를 협력하여 해결
- **지식 공유**: 구현 과정에서 배운 노하우와 팁 공유

### 🤔 왜 이 챌린지인가? (5분)

**실무 시나리오**:
- 💼 **현실 프로젝트**: 실제 기업에서 구축하는 마이크로서비스 아키텍처
- 🏗️ **복합 기술**: 네트워킹, 스토리지, 보안, 모니터링의 통합 적용
- 📊 **운영 관점**: 개발뿐만 아니라 운영까지 고려한 완전한 시스템

---

## 🏗️ 챌린지 아키텍처 개요

### 🎯 구축할 시스템
**"E-Commerce 마이크로서비스 플랫폼"**

```mermaid
graph TB
    subgraph "DMZ Network (172.20.0.0/24)"
        LB[Nginx Load Balancer<br/>172.20.0.10]
        MON[Monitoring Dashboard<br/>172.20.0.20]
    end
    
    subgraph "Frontend Network (172.21.0.0/24)"
        WEB1[React Frontend 1<br/>172.21.0.10]
        WEB2[React Frontend 2<br/>172.21.0.11]
    end
    
    subgraph "Backend Network (172.22.0.0/24)"
        API1[User API<br/>172.22.0.10]
        API2[Product API<br/>172.22.0.11]
        API3[Order API<br/>172.22.0.12]
        CACHE[Redis Cache<br/>172.22.0.20]
    end
    
    subgraph "Database Network (172.23.0.0/24)"
        DB1[User DB (PostgreSQL)<br/>172.23.0.10]
        DB2[Product DB (MongoDB)<br/>172.23.0.11]
        DB3[Order DB (MySQL)<br/>172.23.0.12]
    end
    
    subgraph "Logging Network (172.24.0.0/24)"
        ELK[ELK Stack<br/>172.24.0.10]
        PROM[Prometheus<br/>172.24.0.20]
    end
    
    Internet --> LB
    LB --> WEB1
    LB --> WEB2
    WEB1 --> API1
    WEB1 --> API2
    WEB2 --> API3
    API1 --> DB1
    API2 --> DB2
    API3 --> DB3
    API1 --> CACHE
    API2 --> CACHE
    API3 --> CACHE
    
    API1 --> ELK
    API2 --> ELK
    API3 --> ELK
    MON --> PROM
    
    style LB,MON fill:#ffebee
    style WEB1,WEB2 fill:#e3f2fd
    style API1,API2,API3,CACHE fill:#fff3e0
    style DB1,DB2,DB3 fill:#e8f5e8
    style ELK,PROM fill:#f3e5f5
```

---

## 🚀 Phase 1: 네트워크 인프라 구축 (60분)

### 📋 Phase 1 목표
**네트워크 토폴로지와 기본 인프라 완성**

#### Step 1: 네트워크 생성 (15분)
```bash
# 1. DMZ 네트워크 (외부 접근 허용)
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/24 \
  --gateway=172.20.0.1 \
  dmz-network

# 2. Frontend 네트워크
docker network create \
  --driver bridge \
  --subnet=172.21.0.0/24 \
  --gateway=172.21.0.1 \
  frontend-network

# 3. Backend 네트워크
docker network create \
  --driver bridge \
  --subnet=172.22.0.0/24 \
  --gateway=172.22.0.1 \
  backend-network

# 4. Database 네트워크 (내부 전용)
docker network create \
  --driver bridge \
  --subnet=172.23.0.0/24 \
  --gateway=172.23.0.1 \
  --internal \
  database-network

# 5. Logging 네트워크
docker network create \
  --driver bridge \
  --subnet=172.24.0.0/24 \
  --gateway=172.24.0.1 \
  logging-network

# 네트워크 확인
docker network ls
```

#### Step 2: 볼륨 생성 (15분)
```bash
# 데이터베이스 볼륨
docker volume create user-db-data
docker volume create product-db-data
docker volume create order-db-data

# 캐시 볼륨
docker volume create redis-data

# 로그 볼륨
docker volume create elasticsearch-data
docker volume create prometheus-data

# 설정 파일 볼륨
docker volume create nginx-config
docker volume create app-config

# 볼륨 확인
docker volume ls
```

#### Step 3: 기본 서비스 배포 (30분)
```bash
# 1. Load Balancer (Nginx)
docker run -d --name nginx-lb \
  --network dmz-network \
  --ip 172.20.0.10 \
  -p 80:80 \
  -p 443:443 \
  -v nginx-config:/etc/nginx/conf.d \
  nginx:alpine

# 2. Redis Cache
docker run -d --name redis-cache \
  --network backend-network \
  --ip 172.22.0.20 \
  -v redis-data:/data \
  redis:7-alpine

# 3. PostgreSQL (User DB)
docker run -d --name user-db \
  --network database-network \
  --ip 172.23.0.10 \
  -e POSTGRES_DB=userdb \
  -e POSTGRES_USER=userapp \
  -e POSTGRES_PASSWORD=userpass123 \
  -v user-db-data:/var/lib/postgresql/data \
  postgres:15-alpine

# 4. MongoDB (Product DB)
docker run -d --name product-db \
  --network database-network \
  --ip 172.23.0.11 \
  -e MONGO_INITDB_ROOT_USERNAME=productapp \
  -e MONGO_INITDB_ROOT_PASSWORD=productpass123 \
  -v product-db-data:/data/db \
  mongo:6

# 5. MySQL (Order DB)
docker run -d --name order-db \
  --network database-network \
  --ip 172.23.0.12 \
  -e MYSQL_DATABASE=orderdb \
  -e MYSQL_USER=orderapp \
  -e MYSQL_PASSWORD=orderpass123 \
  -e MYSQL_ROOT_PASSWORD=rootpass123 \
  -v order-db-data:/var/lib/mysql \
  mysql:8.0
```

### ✅ Phase 1 체크포인트
- [ ] 5개 네트워크 생성 완료 (DMZ, Frontend, Backend, Database, Logging)
- [ ] 8개 볼륨 생성 완료 (DB 데이터, 캐시, 로그, 설정)
- [ ] 기본 인프라 서비스 5개 실행 중 (LB, Cache, 3개 DB)
- [ ] 네트워크 격리 확인 (Database는 내부 전용)
- [ ] 볼륨 마운트 확인 (데이터 영속성 보장)

---

## 🌟 Phase 2: 애플리케이션 서비스 배포 (90분)

### 📋 Phase 2 목표
**마이크로서비스 애플리케이션과 네트워크 연결 완성**

#### Step 1: API 서비스 배포 (45분)

**User API 서비스**:
```bash
# User API Dockerfile
cat > user-api.Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3001
USER node
CMD ["node", "server.js"]
EOF

# User API 소스 코드 (간단한 예시)
cat > user-api-server.js << 'EOF'
const express = require('express');
const { Pool } = require('pg');
const app = express();

const pool = new Pool({
  host: 'user-db',
  database: 'userdb',
  user: 'userapp',
  password: 'userpass123',
  port: 5432,
});

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'user-api' });
});

app.get('/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users LIMIT 10');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(3001, () => {
  console.log('User API listening on port 3001');
});
EOF

# User API 컨테이너 실행
docker run -d --name user-api \
  --network backend-network \
  --network database-network \
  --ip 172.22.0.10 \
  -e NODE_ENV=production \
  -e DB_HOST=user-db \
  -e REDIS_HOST=redis-cache \
  user-api:latest
```

**Product API 서비스**:
```bash
# Product API 컨테이너 실행
docker run -d --name product-api \
  --network backend-network \
  --network database-network \
  --ip 172.22.0.11 \
  -e NODE_ENV=production \
  -e MONGO_HOST=product-db \
  -e REDIS_HOST=redis-cache \
  product-api:latest
```

**Order API 서비스**:
```bash
# Order API 컨테이너 실행
docker run -d --name order-api \
  --network backend-network \
  --network database-network \
  --ip 172.22.0.12 \
  -e NODE_ENV=production \
  -e MYSQL_HOST=order-db \
  -e REDIS_HOST=redis-cache \
  order-api:latest
```

#### Step 2: Frontend 서비스 배포 (30분)
```bash
# Frontend 1 (Primary)
docker run -d --name frontend-1 \
  --network frontend-network \
  --network backend-network \
  --ip 172.21.0.10 \
  -e REACT_APP_USER_API=http://user-api:3001 \
  -e REACT_APP_PRODUCT_API=http://product-api:3002 \
  -e REACT_APP_ORDER_API=http://order-api:3003 \
  ecommerce-frontend:latest

# Frontend 2 (Replica)
docker run -d --name frontend-2 \
  --network frontend-network \
  --network backend-network \
  --ip 172.21.0.11 \
  -e REACT_APP_USER_API=http://user-api:3001 \
  -e REACT_APP_PRODUCT_API=http://product-api:3002 \
  -e REACT_APP_ORDER_API=http://order-api:3003 \
  ecommerce-frontend:latest
```

#### Step 3: 로드 밸런서 설정 (15분)
```bash
# Nginx 설정 파일 생성
cat > nginx.conf << 'EOF'
upstream frontend {
    server 172.21.0.10:3000;
    server 172.21.0.11:3000;
}

upstream api {
    server 172.22.0.10:3001;
    server 172.22.0.11:3002;
    server 172.22.0.12:3003;
}

server {
    listen 80;
    
    location / {
        proxy_pass http://frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /api/ {
        proxy_pass http://api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Nginx 설정 적용
docker cp nginx.conf nginx-lb:/etc/nginx/conf.d/default.conf
docker exec nginx-lb nginx -s reload
```

### ✅ Phase 2 체크포인트
- [ ] 3개 API 서비스 실행 중 (User, Product, Order)
- [ ] 2개 Frontend 서비스 실행 중 (로드 밸런싱 준비)
- [ ] 로드 밸런서 설정 완료 (Nginx 업스트림 구성)
- [ ] 서비스 간 네트워크 연결 확인 (API ↔ DB, Frontend ↔ API)
- [ ] 헬스체크 엔드포인트 동작 확인

---

## 🔍 Phase 3: 모니터링과 로깅 시스템 (30분)

### 📋 Phase 3 목표
**운영을 위한 관측성 시스템 구축**

#### Step 1: Prometheus 모니터링 (15분)
```bash
# Prometheus 설정 파일
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'user-api'
    static_configs:
      - targets: ['172.22.0.10:3001']
  
  - job_name: 'product-api'
    static_configs:
      - targets: ['172.22.0.11:3002']
  
  - job_name: 'order-api'
    static_configs:
      - targets: ['172.22.0.12:3003']
  
  - job_name: 'nginx'
    static_configs:
      - targets: ['172.20.0.10:80']
EOF

# Prometheus 실행
docker run -d --name prometheus \
  --network logging-network \
  --network backend-network \
  --network dmz-network \
  --ip 172.24.0.20 \
  -p 9090:9090 \
  -v prometheus-data:/prometheus \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

#### Step 2: ELK 스택 로깅 (15분)
```bash
# Elasticsearch
docker run -d --name elasticsearch \
  --network logging-network \
  --ip 172.24.0.10 \
  -e "discovery.type=single-node" \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  -v elasticsearch-data:/usr/share/elasticsearch/data \
  elasticsearch:8.5.0

# Kibana
docker run -d --name kibana \
  --network logging-network \
  --network dmz-network \
  -p 5601:5601 \
  -e "ELASTICSEARCH_HOSTS=http://elasticsearch:9200" \
  kibana:8.5.0

# Logstash (로그 수집)
docker run -d --name logstash \
  --network logging-network \
  --network backend-network \
  -p 5044:5044 \
  logstash:8.5.0
```

### ✅ Phase 3 체크포인트
- [ ] Prometheus 모니터링 시스템 실행 중
- [ ] ELK 스택 로깅 시스템 실행 중 (Elasticsearch, Kibana, Logstash)
- [ ] 모니터링 대시보드 접근 가능 (Prometheus: 9090, Kibana: 5601)
- [ ] 서비스 메트릭 수집 확인
- [ ] 로그 수집 파이프라인 동작 확인

---

## 🧪 Phase 4: 시스템 테스트와 검증 (30분)

### 📋 Phase 4 목표
**전체 시스템의 동작과 성능 검증**

#### Step 1: 연결성 테스트 (10분)
```bash
# 1. 외부에서 로드 밸런서 접근 테스트
curl -I http://localhost/health

# 2. Frontend에서 API 호출 테스트
docker exec frontend-1 curl -I http://user-api:3001/health
docker exec frontend-1 curl -I http://product-api:3002/health
docker exec frontend-1 curl -I http://order-api:3003/health

# 3. API에서 데이터베이스 연결 테스트
docker exec user-api curl -I http://user-db:5432
docker exec product-api curl -I http://product-db:27017
docker exec order-api curl -I http://order-db:3306

# 4. 캐시 연결 테스트
docker exec user-api redis-cli -h redis-cache ping
```

#### Step 2: 성능 테스트 (10분)
```bash
# Apache Bench를 이용한 부하 테스트
docker run --rm --network dmz-network \
  httpd:alpine \
  ab -n 1000 -c 10 http://172.20.0.10/

# 네트워크 성능 테스트
docker run --rm --network backend-network \
  nicolaka/netshoot \
  iperf3 -c 172.22.0.20 -t 30
```

#### Step 3: 장애 복구 테스트 (10분)
```bash
# 1. 컨테이너 장애 시뮬레이션
docker stop frontend-1
curl http://localhost/  # 여전히 동작해야 함 (frontend-2)

# 2. 컨테이너 복구
docker start frontend-1

# 3. 데이터베이스 장애 시뮬레이션
docker stop user-db
# API에서 적절한 에러 처리 확인

# 4. 데이터베이스 복구
docker start user-db
# 데이터 영속성 확인
```

### ✅ Phase 4 체크포인트
- [ ] 모든 서비스 간 연결성 확인 완료
- [ ] 로드 밸런싱 동작 확인 (Frontend 이중화)
- [ ] 데이터 영속성 확인 (볼륨 마운트 정상)
- [ ] 네트워크 격리 확인 (Database 내부 전용)
- [ ] 장애 복구 시나리오 테스트 완료

---

## 🎤 결과 발표 및 공유 (30분)

### 📊 팀별 발표 (5분 × 4팀 = 20분)

#### 발표 구성
1. **아키텍처 소개** (1분)
   - 구축한 시스템의 전체 구조
   - 네트워크 토폴로지와 보안 설계

2. **구현 하이라이트** (2분)
   - 가장 어려웠던 부분과 해결 방법
   - 창의적으로 구현한 부분
   - 팀 협업에서 효과적이었던 방법

3. **성능 및 테스트 결과** (1분)
   - 부하 테스트 결과
   - 장애 복구 테스트 결과
   - 모니터링 데이터 분석

4. **배운 점과 개선 방안** (1분)
   - 구현 과정에서 배운 핵심 인사이트
   - 프로덕션 환경 적용 시 개선할 점
   - 다음 단계 발전 방향

### 🏆 우수 사례 공유 (10분)

**평가 기준**:
- **아키텍처 완성도**: 네트워크 설계와 보안 적용
- **구현 품질**: 코드 품질과 설정 완성도
- **팀워크**: 협업 과정과 역할 분담
- **창의성**: 독창적인 아이디어와 해결 방법
- **문제 해결**: 어려운 상황의 극복 과정

**공유할 우수 사례**:
- 가장 안정적인 네트워크 아키텍처
- 가장 효율적인 모니터링 구성
- 가장 창의적인 문제 해결 방법
- 가장 효과적인 팀 협업 사례

---

## 📝 세션 마무리

### ✅ 챌린지 완주 성과
- [ ] **완전한 3-tier 아키텍처 구축**: DMZ, Frontend, Backend, Database 계층 완성 ✅
- [ ] **네트워크 보안 적용**: 계층별 격리와 접근 제어 구현 ✅
- [ ] **데이터 영속성 보장**: 볼륨을 활용한 안전한 데이터 관리 ✅
- [ ] **고가용성 구현**: 로드 밸런싱과 이중화 구성 ✅
- [ ] **운영 시스템 구축**: 모니터링과 로깅 시스템 통합 ✅
- [ ] **팀 협업 완성**: 복잡한 시스템을 팀으로 성공적 구축 ✅

### 🎯 실무 역량 완성
- **시스템 아키텍트**: 복잡한 마이크로서비스 아키텍처 설계 능력
- **네트워크 엔지니어**: 고급 네트워킹과 보안 구성 능력
- **데이터 관리자**: 영속성과 백업을 고려한 데이터 관리 능력
- **운영 엔지니어**: 모니터링과 장애 대응 시스템 구축 능력
- **팀 리더**: 복잡한 프로젝트의 팀 협업 리더십

### 🔮 다음 세션 준비
- **주제**: 주간 회고 & Week 2 준비 - Docker Compose 심화 학습
- **성과 정리**: 오늘 구축한 시스템을 Docker Compose로 재구성
- **포트폴리오**: 완성된 마이크로서비스 시스템을 포트폴리오에 추가

---

<div align="center">

**🏗️ 마이크로서비스 네트워킹 챌린지 완벽 완주!**

*3-tier 아키텍처부터 운영 시스템까지, 실무급 마이크로서비스 플랫폼 완성*

**이전**: [Session 3 - 고급 네트워킹과 보안](./session_3.md) | **다음**: [Session 5 - 주간 회고 & 다음 주 준비](./session_5.md)

</div>