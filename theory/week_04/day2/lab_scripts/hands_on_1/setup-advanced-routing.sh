#!/bin/bash

# Week 4 Day 2 Hands-on 1: 고급 라우팅 & 로드밸런싱 설정
# 사용법: ./setup-advanced-routing.sh

echo "=== 고급 라우팅 & 로드밸런싱 설정 시작 ==="

# 기존 v2 서비스 정리
echo "1. 기존 v2 서비스 정리 중..."
docker stop user-service-v2 product-service-v2 2>/dev/null || true
docker rm user-service-v2 product-service-v2 2>/dev/null || true

# User Service v2 배포 (카나리 배포용)
echo "2. User Service v2 배포 중..."
mkdir -p ~/microservices-lab/services/user-service-v2

# User Service v2 코드 생성 (v1과 약간 다른 응답)
cat > ~/microservices-lab/services/user-service-v2/app.js << 'EOF'
const express = require('express');
const consul = require('consul')({
  host: 'consul-server',
  port: 8500
});
const app = express();
const PORT = 3001;

app.use(express.json());

// 사용자 목록 (v2 - 추가 필드 포함)
let users = [
  { 
    id: 1, 
    name: 'Alice', 
    email: 'alice@example.com', 
    role: 'admin',
    version: 'v2',
    lastLogin: '2024-01-15T10:30:00Z',
    preferences: { theme: 'dark', language: 'en' }
  },
  { 
    id: 2, 
    name: 'Bob', 
    email: 'bob@example.com', 
    role: 'user',
    version: 'v2',
    lastLogin: '2024-01-14T15:20:00Z',
    preferences: { theme: 'light', language: 'ko' }
  },
  { 
    id: 3, 
    name: 'Charlie', 
    email: 'charlie@example.com', 
    role: 'user',
    version: 'v2',
    lastLogin: '2024-01-13T09:45:00Z',
    preferences: { theme: 'auto', language: 'en' }
  }
];

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'user-service',
    version: 'v2.0.0',
    timestamp: new Date().toISOString(),
    features: ['enhanced-profiles', 'preferences', 'last-login']
  });
});

// 사용자 목록 조회 (v2 - 향상된 응답)
app.get('/users', (req, res) => {
  console.log('GET /users - 사용자 목록 조회 (v2)');
  res.json({
    version: 'v2',
    count: users.length,
    users: users,
    metadata: {
      timestamp: new Date().toISOString(),
      server: 'user-service-v2'
    }
  });
});

// 사용자 상세 조회
app.get('/users/:id', (req, res) => {
  const userId = parseInt(req.params.id);
  console.log(`GET /users/${userId} - 사용자 상세 조회 (v2)`);
  
  const user = users.find(u => u.id === userId);
  if (!user) {
    return res.status(404).json({ 
      error: 'User not found',
      version: 'v2'
    });
  }
  res.json({
    version: 'v2',
    user: user,
    metadata: {
      timestamp: new Date().toISOString(),
      server: 'user-service-v2'
    }
  });
});

// 새 사용자 생성
app.post('/users', (req, res) => {
  const { name, email, role = 'user', preferences = {} } = req.body;
  const newUser = {
    id: users.length + 1,
    name,
    email,
    role,
    version: 'v2',
    lastLogin: null,
    preferences: preferences
  };
  users.push(newUser);
  console.log('POST /users - 새 사용자 생성 (v2):', newUser);
  res.status(201).json({
    version: 'v2',
    user: newUser,
    metadata: {
      timestamp: new Date().toISOString(),
      server: 'user-service-v2'
    }
  });
});

// 서버 시작 및 Consul 등록
app.listen(PORT, () => {
  console.log(`User Service v2 running on port ${PORT}`);
  
  // Consul 등록
  const registerWithConsul = (retries = 5) => {
    consul.agent.service.register({
      id: 'user-service-v2-1',
      name: 'user-service',
      tags: ['api', 'users', 'v2', 'canary'],
      address: 'user-service-v2',
      port: PORT,
      meta: {
        version: 'v2.0.0',
        features: 'enhanced-profiles,preferences,last-login'
      },
      check: {
        http: `http://user-service-v2:${PORT}/health`,
        interval: '10s',
        timeout: '3s'
      }
    }, (err) => {
      if (err) {
        console.error('Consul registration failed:', err.message);
        if (retries > 0) {
          console.log(`Retrying Consul registration... (${retries} attempts left)`);
          setTimeout(() => registerWithConsul(retries - 1), 2000);
        }
      } else {
        console.log('✅ User Service v2 registered with Consul');
      }
    });
  };
  
  setTimeout(() => registerWithConsul(), 2000);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('Shutting down User Service v2...');
  consul.agent.service.deregister('user-service-v2-1', () => {
    process.exit(0);
  });
});
EOF

# package.json 복사
cp ~/microservices-lab/services/user-service/package.json ~/microservices-lab/services/user-service-v2/

# User Service v2 컨테이너 실행
docker run -d \
  --name user-service-v2 \
  --network microservices-net \
  -p 3005:3001 \
  -v ~/microservices-lab/services/user-service-v2:/app \
  -w /app \
  node:16-alpine \
  sh -c "npm install && npm start"

# 서비스 시작 대기
echo "3. User Service v2 시작 대기 중..."
sleep 10

# Kong 업스트림 생성 (로드밸런싱)
echo "4. Kong 업스트림 및 로드밸런싱 설정 중..."

# 기존 업스트림 삭제 (있다면)
curl -s -X DELETE http://localhost:8001/upstreams/user-service-upstream 2>/dev/null || true

# 새 업스트림 생성
curl -s -X POST http://localhost:8001/upstreams \
  --data "name=user-service-upstream" \
  --data "algorithm=round-robin" \
  --data "healthchecks.active.healthy.interval=5" \
  --data "healthchecks.active.healthy.successes=3" \
  --data "healthchecks.active.unhealthy.interval=5" \
  --data "healthchecks.active.unhealthy.http_failures=3" > /dev/null

# 타겟 추가 (가중치 설정 - v1: 80%, v2: 20%)
curl -s -X POST http://localhost:8001/upstreams/user-service-upstream/targets \
  --data "target=user-service:3001" \
  --data "weight=80" > /dev/null

curl -s -X POST http://localhost:8001/upstreams/user-service-upstream/targets \
  --data "target=user-service-v2:3001" \
  --data "weight=20" > /dev/null

# 기존 user-service 서비스 업데이트 (업스트림 사용)
curl -s -X PATCH http://localhost:8001/services/user-service \
  --data "host=user-service-upstream" \
  --data "port=80" > /dev/null

# Rate Limiting 플러그인 추가
echo "5. Rate Limiting 플러그인 설정 중..."
curl -s -X POST http://localhost:8001/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=100" \
  --data "config.hour=1000" \
  --data "config.policy=local" > /dev/null

# CORS 플러그인 추가
echo "6. CORS 플러그인 설정 중..."
curl -s -X POST http://localhost:8001/plugins \
  --data "name=cors" \
  --data "config.origins=*" \
  --data "config.methods=GET,POST,PUT,DELETE,OPTIONS" \
  --data "config.headers=Accept,Authorization,Content-Type,X-Requested-With" \
  --data "config.credentials=true" > /dev/null

# Request Transformer 플러그인 (헤더 추가)
echo "7. Request Transformer 플러그인 설정 중..."
curl -s -X POST http://localhost:8001/plugins \
  --data "name=request-transformer" \
  --data "config.add.headers=X-Gateway-Version:Kong-3.4" \
  --data "config.add.headers=X-Request-ID:\$(uuid)" > /dev/null

# Response Transformer 플러그인 (응답 헤더 추가)
curl -s -X POST http://localhost:8001/plugins \
  --data "name=response-transformer" \
  --data "config.add.headers=X-Response-Time:\$(latency)" \
  --data "config.add.headers=X-Served-By:Kong-Gateway" > /dev/null

# 상태 확인
echo "8. 고급 라우팅 설정 상태 확인 중..."

# User Service v2 상태 확인
if curl -s http://localhost:3005/health | grep -q "v2"; then
    echo "✅ User Service v2 정상 실행"
else
    echo "❌ User Service v2 시작 실패"
fi

# 업스트림 상태 확인
upstream_status=$(curl -s http://localhost:8001/upstreams/user-service-upstream/health)
if echo "$upstream_status" | grep -q "HEALTHY"; then
    echo "✅ 업스트림 헬스체크 정상"
else
    echo "⚠️ 업스트림 헬스체크 대기 중"
fi

# 로드밸런싱 테스트
echo ""
echo "=== 로드밸런싱 테스트 (5회 요청) ==="
for i in {1..5}; do
    response=$(curl -s http://localhost:8000/api/users)
    if echo "$response" | grep -q '"version"'; then
        version=$(echo "$response" | jq -r '.version // "v1"' 2>/dev/null || echo "v1")
        echo "요청 $i: $version"
    else
        echo "요청 $i: v1 (기본)"
    fi
done

echo ""
echo "=== 고급 라우팅 & 로드밸런싱 설정 완료 ==="
echo ""
echo "설정된 기능:"
echo "- ✅ 카나리 배포: v1 (80%) + v2 (20%)"
echo "- ✅ Rate Limiting: 100/분, 1000/시간"
echo "- ✅ CORS 정책: 모든 오리진 허용"
echo "- ✅ 헤더 변환: 요청/응답 헤더 추가"
echo "- ✅ 헬스체크: 자동 장애 감지"
echo ""
echo "테스트 방법:"
echo "- 로드밸런싱: curl http://localhost:8000/api/users"
echo "- Rate Limit: 빠른 연속 요청으로 테스트"
echo "- CORS: 브라우저에서 크로스 오리진 요청"
echo "- 업스트림 상태: http://localhost:8001/upstreams/user-service-upstream/health"
