# Week 4 Day 2 Hands-on 1: 고급 API Gateway & 서비스 메시 구현

<div align="center">

**🔐 보안 강화** • **📊 모니터링** • **🚀 성능 최적화** • **🔄 로드밸런싱**

*Lab 1을 기반으로 프로덕션급 마이크로서비스 플랫폼 구축*

</div>

---

## 🕘 실습 정보
**시간**: 14:00-14:50 (50분)
**목표**: Lab 1 확장 및 고급 기능 구현
**방식**: Lab 1 기반 + 프로덕션급 기능 추가

## 🎯 실습 목표

### 📚 학습 목표
- **보안 강화**: JWT 인증, Rate Limiting, CORS 정책
- **모니터링**: 메트릭 수집, 로깅, 분산 추적
- **성능 최적화**: 캐싱, 로드밸런싱, 헬스체크
- **운영 안정성**: 서킷 브레이커, 재시도 정책

### 🛠️ 구현 목표
- **인증/인가 시스템**: JWT 기반 API 보안
- **통합 모니터링**: Prometheus + Grafana 대시보드
- **고급 라우팅**: 가중치 기반 로드밸런싱
- **장애 복구**: 자동 failover 및 헬스체크

---

## 🏗️ 확장된 아키텍처

```mermaid
graph TB
    subgraph "클라이언트 계층"
        C1[Web Client]
        C2[Mobile App]
        C3[Admin Dashboard]
    end
    
    subgraph "보안 계층"
        A1[JWT Auth Service]
        A2[Rate Limiter]
        A3[CORS Policy]
    end
    
    subgraph "API Gateway 계층"
        K1[Kong Gateway]
        K2[Load Balancer]
        K3[Circuit Breaker]
    end
    
    subgraph "서비스 메시"
        S1[User Service v1]
        S1v2[User Service v2]
        S2[Product Service]
        S3[Order Service]
        S4[Notification Service]
    end
    
    subgraph "데이터 계층"
        D1[PostgreSQL]
        D2[Redis Cache]
        D3[MongoDB]
    end
    
    subgraph "모니터링 계층"
        M1[Prometheus]
        M2[Grafana]
        M3[Jaeger Tracing]
        M4[ELK Stack]
    end
    
    C1 --> A1
    C2 --> A2
    C3 --> A3
    
    A1 --> K1
    A2 --> K2
    A3 --> K3
    
    K1 --> S1
    K1 --> S1v2
    K2 --> S2
    K3 --> S3
    K1 --> S4
    
    S1 --> D1
    S2 --> D2
    S3 --> D3
    S4 --> D2
    
    S1 -.-> M1
    S2 -.-> M1
    S3 -.-> M1
    M1 --> M2
    
    K1 -.-> M3
    S1 -.-> M4
    
    style A1 fill:#ffebee
    style A2 fill:#ffebee
    style A3 fill:#ffebee
    style K1 fill:#e3f2fd
    style K2 fill:#e3f2fd
    style K3 fill:#e3f2fd
    style S1 fill:#e8f5e8
    style S1v2 fill:#e8f5e8
    style S2 fill:#e8f5e8
    style S3 fill:#e8f5e8
    style S4 fill:#e8f5e8
    style M1 fill:#fff3e0
    style M2 fill:#fff3e0
    style M3 fill:#fff3e0
    style M4 fill:#fff3e0
```

---

## 🔐 Step 1: JWT 인증 시스템 구축 (15분)

### Step 1-1: JWT 인증 서비스 배포

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_04/day2/lab_scripts/hands_on_1
./setup-jwt-auth.sh
```

**📋 스크립트 내용**: [setup-jwt-auth.sh](./lab_scripts/hands_on_1/setup-jwt-auth.sh)

**1-1. 수동 실행 (학습용)**
```bash
# JWT 인증 서비스 생성
mkdir -p ~/microservices-lab/services/auth-service

# JWT 인증 서비스 코드 작성
cat > ~/microservices-lab/services/auth-service/app.js << 'EOF'
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const app = express();
const PORT = 3004;

app.use(express.json());

const JWT_SECRET = 'your-super-secret-key';
const users = [
  { id: 1, username: 'admin', password: '$2b$10$hash', role: 'admin' },
  { id: 2, username: 'user', password: '$2b$10$hash', role: 'user' }
];

// 로그인 엔드포인트
app.post('/auth/login', async (req, res) => {
  const { username, password } = req.body;
  const user = users.find(u => u.username === username);
  
  if (user && await bcrypt.compare(password, user.password)) {
    const token = jwt.sign(
      { userId: user.id, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: '1h' }
    );
    res.json({ token, user: { id: user.id, username: user.username, role: user.role } });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// 토큰 검증 엔드포인트
app.post('/auth/verify', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    res.json({ valid: true, user: decoded });
  } catch (error) {
    res.status(401).json({ valid: false, error: 'Invalid token' });
  }
});

app.listen(PORT, () => {
  console.log(`Auth Service running on port ${PORT}`);
});
EOF

# 컨테이너 실행
docker run -d \
  --name auth-service \
  --network microservices-net \
  -p 3004:3004 \
  -v ~/microservices-lab/services/auth-service:/app \
  -w /app \
  node:16-alpine \
  sh -c "npm install jsonwebtoken bcrypt express && npm start"
```

### Step 1-2: Kong JWT 플러그인 설정

```bash
# Kong에 JWT 플러그인 활성화
curl -X POST http://localhost:8001/plugins \
  --data "name=jwt" \
  --data "config.secret_is_base64=false"

# JWT 소비자 생성
curl -X POST http://localhost:8001/consumers \
  --data "username=api-client"

# JWT 자격증명 생성
curl -X POST http://localhost:8001/consumers/api-client/jwt \
  --data "key=your-super-secret-key"
```

---

## 📊 Step 2: 모니터링 시스템 구축 (15분)

### Step 2-1: Prometheus 메트릭 수집

**🚀 자동화 스크립트 사용**
```bash
./setup-monitoring.sh
```

**📋 스크립트 내용**: [setup-monitoring.sh](./lab_scripts/hands_on_1/setup-monitoring.sh)

**2-1. 수동 실행 (학습용)**
```bash
# Prometheus 설정 파일 생성
mkdir -p ~/microservices-lab/monitoring/prometheus

cat > ~/microservices-lab/monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'kong'
    static_configs:
      - targets: ['kong-gateway:8001']
    metrics_path: '/metrics'
    
  - job_name: 'microservices'
    consul_sd_configs:
      - server: 'consul-server:8500'
    relabel_configs:
      - source_labels: [__meta_consul_service]
        target_label: service
EOF

# Prometheus 컨테이너 실행
docker run -d \
  --name prometheus \
  --network microservices-net \
  -p 9090:9090 \
  -v ~/microservices-lab/monitoring/prometheus:/etc/prometheus \
  prom/prometheus:latest \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.console.templates=/etc/prometheus/consoles
```

### Step 2-2: Grafana 대시보드 구성

```bash
# Grafana 컨테이너 실행
docker run -d \
  --name grafana \
  --network microservices-net \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:latest

# Grafana 데이터소스 설정 (Prometheus)
sleep 10
curl -X POST http://admin:admin@localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }'
```

---

## 🚀 Step 3: 고급 라우팅 & 로드밸런싱 (10분)

### Step 3-1: 가중치 기반 로드밸런싱

**🚀 자동화 스크립트 사용**
```bash
./setup-advanced-routing.sh
```

**📋 스크립트 내용**: [setup-advanced-routing.sh](./lab_scripts/hands_on_1/setup-advanced-routing.sh)

**3-1. 수동 실행 (학습용)**
```bash
# User Service v2 배포 (카나리 배포용)
docker run -d \
  --name user-service-v2 \
  --network microservices-net \
  -p 3005:3001 \
  -e SERVICE_VERSION=v2 \
  -v ~/microservices-lab/services/user-service:/app \
  -w /app \
  node:16-alpine \
  sh -c "npm install && npm start"

# Kong 업스트림 생성 (로드밸런싱)
curl -X POST http://localhost:8001/upstreams \
  --data "name=user-service-upstream"

# 타겟 추가 (가중치 설정)
curl -X POST http://localhost:8001/upstreams/user-service-upstream/targets \
  --data "target=user-service:3001" \
  --data "weight=80"

curl -X POST http://localhost:8001/upstreams/user-service-upstream/targets \
  --data "target=user-service-v2:3001" \
  --data "weight=20"

# 서비스 업데이트 (업스트림 사용)
curl -X PATCH http://localhost:8001/services/user-service \
  --data "host=user-service-upstream"
```

### Step 3-2: Rate Limiting & CORS 설정

```bash
# Rate Limiting 플러그인 추가
curl -X POST http://localhost:8001/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=100" \
  --data "config.hour=1000"

# CORS 플러그인 추가
curl -X POST http://localhost:8001/plugins \
  --data "name=cors" \
  --data "config.origins=*" \
  --data "config.methods=GET,POST,PUT,DELETE" \
  --data "config.headers=Accept,Authorization,Content-Type,X-Requested-With"
```

---

## ⚖️ Step 4: 서킷 브레이커 & 헬스체크 (10분)

### Step 4-1: 고급 헬스체크 구현

**🚀 자동화 스크립트 사용**
```bash
./setup-circuit-breaker.sh
```

**📋 스크립트 내용**: [setup-circuit-breaker.sh](./lab_scripts/hands_on_1/setup-circuit-breaker.sh)

**4-1. 수동 실행 (학습용)**
```bash
# 각 서비스에 상세 헬스체크 추가
services=("user-service" "product-service" "order-service")

for service in "${services[@]}"; do
  curl -X POST http://localhost:8001/services/${service}/plugins \
    --data "name=request-termination" \
    --data "config.status_code=503" \
    --data "config.message=Service Unavailable"
done

# Kong 헬스체크 설정
curl -X POST http://localhost:8001/upstreams/user-service-upstream/health \
  --data "threshold=0.5"
```

### Step 4-2: 자동 장애 복구 설정

```bash
# 재시도 정책 설정
curl -X POST http://localhost:8001/plugins \
  --data "name=request-transformer" \
  --data "config.add.headers=X-Retry-Count:3"

# 타임아웃 설정
curl -X PATCH http://localhost:8001/services/user-service \
  --data "connect_timeout=5000" \
  --data "write_timeout=5000" \
  --data "read_timeout=5000"
```

---

## 🔍 고급 모니터링 및 디버깅

### 분산 추적 (Jaeger)
```bash
# Jaeger 올인원 컨테이너 실행
docker run -d \
  --name jaeger \
  --network microservices-net \
  -p 16686:16686 \
  -p 14268:14268 \
  jaegertracing/all-in-one:latest

# Kong Zipkin 플러그인 (Jaeger 호환)
curl -X POST http://localhost:8001/plugins \
  --data "name=zipkin" \
  --data "config.http_endpoint=http://jaeger:9411/api/v1/spans"
```

### 실시간 로그 모니터링
```bash
# 모든 서비스 로그 실시간 확인
docker logs -f user-service &
docker logs -f product-service &
docker logs -f order-service &
docker logs -f kong-gateway &
```

---

## ✅ 실습 체크포인트

### 🔐 보안 기능 확인
- [ ] JWT 토큰 생성 및 검증 동작
- [ ] Rate Limiting 정책 적용 확인
- [ ] CORS 정책 동작 검증
- [ ] 인증 없는 요청 차단 확인

### 📊 모니터링 시스템 확인
- [ ] Prometheus 메트릭 수집 동작
- [ ] Grafana 대시보드 접근 가능
- [ ] 서비스별 메트릭 시각화
- [ ] 알림 규칙 동작 확인

### 🚀 성능 최적화 확인
- [ ] 로드밸런싱 가중치 동작
- [ ] 카나리 배포 트래픽 분산
- [ ] 헬스체크 기반 자동 복구
- [ ] 서킷 브레이커 동작 확인

### ⚖️ 장애 복구 확인
- [ ] 서비스 다운 시 자동 failover
- [ ] 재시도 정책 동작
- [ ] 타임아웃 설정 적용
- [ ] 분산 추적 데이터 수집

---

## 🚀 추가 도전 과제

### 고급 보안 강화
1. **mTLS 구현**: 서비스 간 상호 TLS 인증
2. **API 키 관리**: Kong의 Key Auth 플러그인
3. **IP 화이트리스트**: 특정 IP만 접근 허용
4. **요청 크기 제한**: 대용량 요청 차단

### 성능 최적화
1. **캐싱 전략**: Redis 기반 응답 캐싱
2. **압축 설정**: Gzip 압축으로 대역폭 절약
3. **연결 풀링**: 데이터베이스 연결 최적화
4. **CDN 연동**: 정적 자원 캐싱

### 고급 모니터링
1. **커스텀 메트릭**: 비즈니스 메트릭 수집
2. **알림 규칙**: Slack/Email 알림 연동
3. **대시보드 커스터마이징**: 실시간 비즈니스 대시보드
4. **로그 분석**: ELK 스택으로 로그 분석

---

## 🧹 실습 정리
```bash
# 추가된 컨테이너들 정리
docker stop auth-service prometheus grafana jaeger user-service-v2
docker rm auth-service prometheus grafana jaeger user-service-v2

# 기본 Lab 1 환경은 유지 (다음 실습 활용)
```

---

## 💡 실습 회고

### 🤝 팀 회고 (10분)
1. **보안 강화**: JWT 인증과 Rate Limiting의 실무 적용 경험
2. **모니터링**: Prometheus + Grafana 조합의 효과성
3. **성능 최적화**: 로드밸런싱과 캐싱의 성능 향상 체감
4. **운영 안정성**: 서킷 브레이커와 헬스체크의 중요성

### 📊 학습 성과
- **프로덕션급 설정**: 실제 운영 환경에 적용 가능한 고급 기능 습득
- **통합 모니터링**: 전체 시스템의 상태를 한눈에 파악하는 관측성 구축
- **보안 강화**: API 보안의 다층 방어 전략 이해
- **성능 튜닝**: 실무에서 중요한 성능 최적화 기법 체험

---

<div align="center">

**🔐 보안 강화** • **📊 실시간 모니터링** • **🚀 성능 최적화** • **⚖️ 자동 복구**

*Lab 1의 기본 구조를 프로덕션급 마이크로서비스 플랫폼으로 발전*

</div>
