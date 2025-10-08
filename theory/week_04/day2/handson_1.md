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

## 🛠️ Step 1: 환경 준비 및 Kong 설정 (15분)

### Step 1-1: 기본 환경 설정 (3분)

**🚀 자동화 스크립트 사용**
```bash
cd theory/week_04/day2/lab_scripts/handson1
./setup-environment.sh
```

**📋 스크립트 내용**: [setup-environment.sh](./lab_scripts/handson1/setup-environment.sh)

### Step 1-2: Kong 데이터베이스 설정 (4분)

**PostgreSQL 데이터베이스 시작**
```bash
docker run -d --name kong-database \
  --network api-gateway-net \
  -e POSTGRES_USER=kong \
  -e POSTGRES_DB=kong \
  -e POSTGRES_PASSWORD=kong \
  postgres:16
```

**Kong 데이터베이스 마이그레이션**
```bash
docker run --rm \
  --network api-gateway-net \
  -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=kong-database \
  -e KONG_PG_USER=kong \
  -e KONG_PG_PASSWORD=kong \
  kong:3.8 kong migrations bootstrap
```

### Step 1-3: Kong Gateway 시작 (4분)

**Kong 컨테이너 실행**
```bash
docker run -d --name kong \
  --network api-gateway-net \
  -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=kong-database \
  -e KONG_PG_USER=kong \
  -e KONG_PG_PASSWORD=kong \
  -e KONG_PROXY_ACCESS_LOG=/dev/stdout \
  -e KONG_ADMIN_ACCESS_LOG=/dev/stdout \
  -e KONG_PROXY_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_LISTEN=0.0.0.0:8001 \
  -p 8000:8000 \
  -p 8001:8001 \
  kong:3.8
```

**Kong 상태 확인**
```bash
# Kong이 완전히 시작될 때까지 대기
sleep 10

# Kong Admin API 확인
curl -i http://localhost:8001/

# 예상 출력: HTTP/1.1 200 OK
```

### Step 1-4: JWT 인증 서비스 배포 (4분)

**JWT 인증 서비스 생성**
```bash
# 간단한 JWT 인증 서비스 (Node.js)
cat > api-gateway-advanced/services/auth-service.js << 'EOF'
const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();

const SECRET_KEY = 'your-secret-key';

app.use(express.json());

// JWT 토큰 발급
app.post('/auth/login', (req, res) => {
  const { username, password } = req.body;
  
  // 간단한 인증 (실제로는 DB 확인 필요)
  if (username === 'admin' && password === 'password') {
    const token = jwt.sign(
      { username, role: 'admin' },
      SECRET_KEY,
      { expiresIn: '1h' }
    );
    res.json({ token });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// JWT 토큰 검증
app.post('/auth/verify', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    res.json({ valid: true, user: decoded });
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

app.listen(3000, () => {
  console.log('Auth service running on port 3000');
});
EOF
```

**Dockerfile 생성**
```bash
cat > api-gateway-advanced/services/Dockerfile.auth << 'EOF'
FROM node:22-alpine
WORKDIR /app
RUN npm install express jsonwebtoken
COPY auth-service.js .
CMD ["node", "auth-service.js"]
EOF
```

**인증 서비스 빌드 및 실행**
```bash
cd api-gateway-advanced/services
docker build -t auth-service -f Dockerfile.auth .

docker run -d --name auth-service \
  --network api-gateway-net \
  -p 3000:3000 \
  auth-service
```

**인증 서비스 테스트**
```bash
# 로그인 테스트
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'

# 토큰이 반환되는지 확인
```

---

## 🔐 Step 2: Kong JWT 플러그인 설정 (10분)

### Step 2-1: JWT 플러그인 활성화 (5분)

**Kong에 서비스 등록**
```bash
# Auth 서비스 등록
curl -i -X POST http://localhost:8001/services \
  --data name=auth-service \
  --data url=http://auth-service:3000

# 라우트 생성
curl -i -X POST http://localhost:8001/services/auth-service/routes \
  --data paths[]=/auth
```

**보호할 서비스 생성 (예: User Service)**
```bash
# User 서비스 등록
curl -i -X POST http://localhost:8001/services \
  --data name=user-service \
  --data url=http://user-service:3001

# 라우트 생성
curl -i -X POST http://localhost:8001/services/user-service/routes \
  --data paths[]=/users
```

**JWT 플러그인 활성화**
```bash
# User 서비스에 JWT 플러그인 적용
curl -i -X POST http://localhost:8001/services/user-service/plugins \
  --data name=jwt \
  --data config.secret_is_base64=false
```

### Step 2-2: JWT Consumer 생성 (5분)

**Consumer 생성**
```bash
# Admin 사용자 생성
curl -i -X POST http://localhost:8001/consumers \
  --data username=admin
```

**JWT Credential 생성**
```bash
# JWT 자격증명 생성
curl -i -X POST http://localhost:8001/consumers/admin/jwt \
  --data key=admin-key \
  --data secret=your-secret-key \
  --data algorithm=HS256
```

**JWT 인증 테스트**
```bash
# 1. 토큰 발급
TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' | jq -r '.token')

echo "발급된 토큰: $TOKEN"

# 2. 인증 없이 접근 시도 (실패해야 함)
curl -i http://localhost:8000/users

# 3. 토큰으로 접근 (성공해야 함)
curl -i http://localhost:8000/users \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📊 Step 3: 모니터링 시스템 구축 (10분)

### Step 3-1: Prometheus 설정 (5분)

**Prometheus 설정 파일 생성**
```bash
mkdir -p api-gateway-advanced/monitoring/prometheus

cat > api-gateway-advanced/monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  # Kong 메트릭 수집
  - job_name: 'kong'
    static_configs:
      - targets: ['kong:8001']
    metrics_path: '/metrics'
    
  # 마이크로서비스 메트릭 수집
  - job_name: 'services'
    static_configs:
      - targets: 
        - 'user-service:3001'
        - 'product-service:3002'
        - 'order-service:3003'
EOF
```

**Prometheus 컨테이너 실행**
```bash
docker run -d \
  --name prometheus \
  --network api-gateway-net \
  -p 9090:9090 \
  -v api-gateway-advanced/monitoring/prometheus:/etc/prometheus \
  prom/prometheus:v2.54.1 \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus
```

**Prometheus 접속 확인**
```bash
# 웹 브라우저에서 접속
echo "Prometheus: http://localhost:9090"

# 또는 curl로 확인
curl -s http://localhost:9090/api/v1/targets | jq
```

### Step 3-2: Grafana 대시보드 구성 (5분)

**Grafana 컨테이너 실행**
```bash
docker run -d \
  --name grafana \
  --network api-gateway-net \
  -p 3001:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:11.2.2
```

**Grafana 데이터소스 설정**
```bash
# Grafana가 시작될 때까지 대기
sleep 10

# Prometheus 데이터소스 추가
curl -X POST http://admin:admin@localhost:3001/api/datasources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }'
```

**Grafana 접속**
```bash
echo "Grafana: http://localhost:3001"
echo "Username: admin"
echo "Password: admin"
```

---

## 🚀 Step 4: Rate Limiting & CORS 설정 (10분)

### Step 4-1: Rate Limiting 플러그인 (5분)

**Rate Limiting 플러그인 활성화**
```bash
# User 서비스에 Rate Limiting 적용
curl -i -X POST http://localhost:8001/services/user-service/plugins \
  --data name=rate-limiting \
  --data config.minute=10 \
  --data config.hour=100 \
  --data config.policy=local
```

**Rate Limiting 테스트**
```bash
# 반복 요청으로 제한 확인
for i in {1..15}; do
  echo "Request $i:"
  curl -i http://localhost:8000/users \
    -H "Authorization: Bearer $TOKEN"
  echo ""
  sleep 1
done

# 10번 이후 요청은 429 Too Many Requests 반환
```

### Step 4-2: CORS 정책 설정 (5분)

**CORS 플러그인 활성화**
```bash
# 전역 CORS 설정
curl -i -X POST http://localhost:8001/plugins \
  --data name=cors \
  --data config.origins=* \
  --data config.methods=GET,POST,PUT,DELETE \
  --data config.headers=Accept,Authorization,Content-Type \
  --data config.exposed_headers=X-Auth-Token \
  --data config.credentials=true \
  --data config.max_age=3600
```

**CORS 테스트**
```bash
# OPTIONS 요청으로 CORS 확인
curl -i -X OPTIONS http://localhost:8000/users \
  -H "Origin: http://example.com" \
  -H "Access-Control-Request-Method: GET"

# 응답 헤더에 Access-Control-Allow-Origin 확인
```

---

## 🔄 Step 5: 고급 라우팅 & 로드밸런싱 (5분)

### Step 5-1: 가중치 기반 로드밸런싱

**User Service v2 배포 (카나리 배포용)**
```bash
# User Service v2 컨테이너 실행
docker run -d \
  --name user-service-v2 \
  --network api-gateway-net \
  -p 3005:3001 \
  -e SERVICE_VERSION=v2 \
  user-service:v2
```

**Kong Upstream 설정**
```bash
# Upstream 생성
curl -i -X POST http://localhost:8001/upstreams \
  --data name=user-service-upstream

# v1 타겟 추가 (가중치 90%)
curl -i -X POST http://localhost:8001/upstreams/user-service-upstream/targets \
  --data target=user-service:3001 \
  --data weight=90

# v2 타겟 추가 (가중치 10%)
curl -i -X POST http://localhost:8001/upstreams/user-service-upstream/targets \
  --data target=user-service-v2:3001 \
  --data weight=10
```

**서비스 업데이트**
```bash
# 기존 서비스를 Upstream으로 변경
curl -i -X PATCH http://localhost:8001/services/user-service \
  --data host=user-service-upstream
```

**로드밸런싱 테스트**
```bash
# 여러 번 요청하여 v1과 v2 응답 비율 확인
for i in {1..20}; do
  curl -s http://localhost:8000/users \
    -H "Authorization: Bearer $TOKEN" | jq -r '.version'
done | sort | uniq -c

# 약 90% v1, 10% v2 응답 확인
```

---

## ✅ 실습 체크포인트

### 🔐 보안 기능 확인
- [ ] **JWT 인증**: 토큰 없이 접근 시 401 오류
- [ ] **Rate Limiting**: 제한 초과 시 429 오류
- [ ] **CORS**: OPTIONS 요청에 적절한 헤더 반환

### 📊 모니터링 확인
- [ ] **Prometheus**: 메트릭 수집 정상 동작
- [ ] **Grafana**: 대시보드 접속 및 데이터 표시

### 🚀 고급 기능 확인
- [ ] **로드밸런싱**: v1과 v2 간 가중치 기반 분산
- [ ] **헬스체크**: 장애 서비스 자동 제외

---

## 🧹 실습 정리

**환경 정리 스크립트 실행**
```bash
cd theory/week_04/day2/lab_scripts/handson1
./cleanup.sh
```

**📋 스크립트 내용**: [cleanup.sh](./lab_scripts/handson1/cleanup.sh)

---

## 💡 실습 회고

### 🤝 팀 회고 (10분)
1. **보안 강화**: JWT 인증과 Rate Limiting의 실무 적용 방안은?
2. **모니터링**: Prometheus와 Grafana를 활용한 운영 전략은?
3. **고급 라우팅**: 카나리 배포의 장단점과 실무 활용 사례는?
4. **성능 최적화**: 추가로 적용할 수 있는 최적화 방법은?

### 📊 학습 성과
- **보안 역량**: API 보안의 다층 방어 전략 이해
- **운영 역량**: 프로덕션급 모니터링 시스템 구축
- **아키텍처**: 고급 라우팅과 로드밸런싱 패턴 습득
- **실무 연계**: 실제 운영 환경에 적용 가능한 기술 습득

---

<div align="center">

**🔐 보안 강화** • **📊 통합 모니터링** • **🚀 성능 최적화** • **🔄 고급 라우팅**

*프로덕션급 마이크로서비스 플랫폼 구축 완료*

</div>
