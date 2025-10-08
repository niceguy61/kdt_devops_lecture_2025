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
**작업 위치**: `theory/week_04/day2/lab_scripts/handson1`

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

## 🛠️ Step 1: 환경 준비 및 Kong 설정 (15분)

### Step 1-1: 기본 환경 설정 (3분)

**작업 디렉토리 이동**
```bash
cd theory/week_04/day2/lab_scripts/handson1
```

**환경 설정 스크립트 실행**
```bash
./setup-environment.sh
```

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
sleep 10
curl -i http://localhost:8001/
```

### Step 1-4: JWT 인증 서비스 배포 (4분)

**JWT 인증 서비스 생성**
```bash
cat > services/auth-service.js << 'EOF'
const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();

const SECRET_KEY = 'your-secret-key';

app.use(express.json());

app.post('/auth/login', (req, res) => {
  const { username, password } = req.body;
  
  if (username === 'admin' && password === 'password') {
    const token = jwt.sign(
      { username, role: 'admin', iss: 'admin-key' },
      SECRET_KEY,
      { expiresIn: '1h' }
    );
    res.json({ token });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

app.listen(3000, () => console.log('Auth service running on port 3000'));
EOF
```

**Dockerfile 생성**
```bash
cat > services/Dockerfile.auth << 'EOF'
FROM node:22-alpine
WORKDIR /app
RUN npm install express jsonwebtoken
COPY auth-service.js .
CMD ["node", "auth-service.js"]
EOF
```

**빌드 및 실행**
```bash
docker build -t auth-service -f services/Dockerfile.auth services/

docker run -d --name auth-service \
  --network api-gateway-net \
  -p 3000:3000 \
  auth-service
```

**User 서비스 생성**
```bash
cat > services/user-service.js << 'EOF'
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({
    users: [
      { id: 1, name: 'Alice', email: 'alice@example.com' },
      { id: 2, name: 'Bob', email: 'bob@example.com' }
    ],
    version: 'v1'
  });
});

app.listen(3001, () => console.log('User service running on port 3001'));
EOF

cat > services/Dockerfile.user << 'EOF'
FROM node:22-alpine
WORKDIR /app
RUN npm install express
COPY user-service.js .
CMD ["node", "user-service.js"]
EOF

docker build -t user-service -f services/Dockerfile.user services/

docker run -d --name user-service \
  --network api-gateway-net \
  -p 3001:3001 \
  user-service
```

---

## 🔐 Step 2: Kong JWT 플러그인 설정 (10분)

### Step 2-1: JWT 플러그인 활성화 (5분)

**Kong에 서비스 등록**
```bash
curl -s -X POST http://localhost:8001/services \
  --data name=auth-service \
  --data url=http://auth-service:3000

curl -s -X POST http://localhost:8001/services/auth-service/routes \
  --data paths[]=/auth

curl -s -X POST http://localhost:8001/services \
  --data name=user-service \
  --data url=http://user-service:3001

curl -s -X POST http://localhost:8001/services/user-service/routes \
  --data paths[]=/users
```

**JWT 플러그인 활성화**
```bash
curl -s -X POST http://localhost:8001/services/user-service/plugins \
  --data name=jwt \
  --data config.secret_is_base64=false \
  --data config.claims_to_verify=exp
```

### Step 2-2: JWT Consumer 생성 (5분)

**Consumer 및 Credential 생성**
```bash
curl -s -X POST http://localhost:8001/consumers \
  --data username=admin

curl -s -X POST http://localhost:8001/consumers/admin/jwt \
  --data key=admin-key \
  --data secret=your-secret-key \
  --data algorithm=HS256
```

**JWT 인증 테스트**
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' | jq -r '.token')

echo "인증 없이 접근:"
curl -s http://localhost:8000/users | jq -r '.message'

echo -e "\n토큰으로 접근:"
curl -s http://localhost:8000/users \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

## 📊 Step 3: 모니터링 시스템 구축 (10분)

### Step 3-1: Prometheus 설정 (5분)

**Prometheus 설정 파일 생성**
```bash
cat > monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'kong'
    static_configs:
      - targets: ['kong:8001']
    metrics_path: '/metrics'
EOF

docker run -d --name prometheus \
  --network api-gateway-net \
  -p 9090:9090 \
  -v $(pwd)/monitoring/prometheus:/etc/prometheus \
  prom/prometheus:v2.54.1 \
  --config.file=/etc/prometheus/prometheus.yml
```

### Step 3-2: Grafana 설정 (5분)

**Grafana 실행 및 데이터소스 추가**
```bash
docker run -d --name grafana \
  --network api-gateway-net \
  -p 3002:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:11.2.2

sleep 10

curl -s -X POST http://admin:admin@localhost:3002/api/datasources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }'

echo "Grafana: http://localhost:3002 (admin/admin)"
```

---

## 🚀 Step 4: Rate Limiting & CORS 설정 (10분)

### Step 4-1: Rate Limiting (5분)

**Rate Limiting 플러그인 활성화**
```bash
curl -s -X POST http://localhost:8001/services/user-service/plugins \
  --data name=rate-limiting \
  --data config.minute=5 \
  --data config.policy=local
```

**테스트**
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' | jq -r '.token')

for i in {1..7}; do
  echo "Request $i:"
  curl -s -w "HTTP %{http_code}\n" http://localhost:8000/users \
    -H "Authorization: Bearer $TOKEN" -o /dev/null
  sleep 1
done
```

### Step 4-2: CORS 설정 (5분)

**CORS 플러그인 활성화**
```bash
curl -s -X POST http://localhost:8001/plugins \
  --data name=cors \
  --data "config.origins=*" \
  --data "config.methods=GET" \
  --data "config.methods=POST" \
  --data "config.credentials=true"
```

---

## 🔄 Step 5: 고급 라우팅 & 로드밸런싱 (5분)

**User Service v2 생성**
```bash
cat > services/user-service-v2.js << 'EOF'
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({
    users: [
      { id: 1, name: 'Alice', email: 'alice@example.com' },
      { id: 2, name: 'Bob', email: 'bob@example.com' },
      { id: 3, name: 'Charlie', email: 'charlie@example.com' }
    ],
    version: 'v2'
  });
});

app.listen(3001, () => console.log('User service v2 running'));
EOF

cat > services/Dockerfile.user-v2 << 'EOF'
FROM node:22-alpine
WORKDIR /app
RUN npm install express
COPY user-service-v2.js user-service.js
CMD ["node", "user-service.js"]
EOF

docker build -t user-service:v2 -f services/Dockerfile.user-v2 services/

docker run -d --name user-service-v2 \
  --network api-gateway-net \
  user-service:v2
```

**Upstream 설정**
```bash
curl -s -X POST http://localhost:8001/upstreams \
  --data name=user-service-upstream

curl -s -X POST http://localhost:8001/upstreams/user-service-upstream/targets \
  --data target=user-service:3001 \
  --data weight=90

curl -s -X POST http://localhost:8001/upstreams/user-service-upstream/targets \
  --data target=user-service-v2:3001 \
  --data weight=10

curl -s -X PATCH http://localhost:8001/services/user-service \
  --data host=user-service-upstream
```

**로드밸런싱 테스트**
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' | jq -r '.token')

for i in {1..20}; do
  curl -s http://localhost:8000/users \
    -H "Authorization: Bearer $TOKEN" | jq -r '.version'
  sleep 0.2
done | sort | uniq -c
```

---

## 🧹 실습 정리

```bash
./cleanup.sh
```

---

<div align="center">

**🔐 보안 강화** • **📊 통합 모니터링** • **🚀 성능 최적화** • **🔄 고급 라우팅**

*프로덕션급 마이크로서비스 플랫폼 구축 완료*

</div>
