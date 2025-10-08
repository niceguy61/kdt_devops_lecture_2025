#!/bin/bash

# Week 4 Day 2 Lab 1: User Service 배포
# 사용법: ./deploy-user-service.sh

echo "=== User Service 배포 시작 ==="

# 기존 컨테이너 정리
echo "1. 기존 User Service 컨테이너 정리 중..."
docker stop user-service user-db 2>/dev/null || true
docker rm user-service user-db 2>/dev/null || true

# 디렉토리 생성
echo "2. 서비스 디렉토리 생성 중..."
mkdir -p ~/microservices-lab/services/user-service
mkdir -p ~/microservices-lab/data/postgres

# PostgreSQL 데이터베이스 실행
echo "3. PostgreSQL 데이터베이스 실행 중..."
docker run -d \
  --name user-db \
  --network microservices-net \
  -e POSTGRES_DB=userdb \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=password \
  -v ~/microservices-lab/data/postgres:/var/lib/postgresql/data \
  postgres:13

# User Service 코드 생성
echo "4. User Service 코드 생성 중..."
cat > ~/microservices-lab/services/user-service/app.js << 'EOF'
const express = require('express');
const consul = require('consul')({
  host: 'consul-server',
  port: 8500
});
const app = express();
const PORT = 3001;

app.use(express.json());

// 사용자 목록 (임시 데이터)
let users = [
  { id: 1, name: 'Alice', email: 'alice@example.com', role: 'admin' },
  { id: 2, name: 'Bob', email: 'bob@example.com', role: 'user' },
  { id: 3, name: 'Charlie', email: 'charlie@example.com', role: 'user' }
];

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'user-service',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// 사용자 목록 조회
app.get('/users', (req, res) => {
  console.log('GET /users - 사용자 목록 조회');
  res.json(users);
});

// 사용자 상세 조회
app.get('/users/:id', (req, res) => {
  const userId = parseInt(req.params.id);
  console.log(`GET /users/${userId} - 사용자 상세 조회`);
  
  const user = users.find(u => u.id === userId);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json(user);
});

// 새 사용자 생성
app.post('/users', (req, res) => {
  const { name, email, role = 'user' } = req.body;
  const newUser = {
    id: users.length + 1,
    name,
    email,
    role
  };
  users.push(newUser);
  console.log('POST /users - 새 사용자 생성:', newUser);
  res.status(201).json(newUser);
});

// 서버 시작 및 Consul 등록
app.listen(PORT, () => {
  console.log(`User Service running on port ${PORT}`);
  
  // Consul 등록 재시도 함수
  const registerWithConsul = (retries = 5) => {
    consul.agent.service.register({
      id: 'user-service-1',
      name: 'user-service',
      tags: ['api', 'users', 'v1'],
      address: 'user-service',
      port: PORT,
      check: {
        http: `http://user-service:${PORT}/health`,
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
        console.log('✅ Service registered with Consul');
      }
    });
  };
  
  // 2초 후 Consul 등록 시도 (Consul 서버 준비 대기)
  setTimeout(() => registerWithConsul(), 2000);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('Shutting down User Service...');
  consul.agent.service.deregister('user-service-1', () => {
    process.exit(0);
  });
});
EOF

# package.json 생성
cat > ~/microservices-lab/services/user-service/package.json << 'EOF'
{
  "name": "user-service",
  "version": "1.0.0",
  "description": "User management microservice",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "consul": "^0.40.0"
  }
}
EOF

# PostgreSQL 시작 대기
echo "5. PostgreSQL 시작 대기 중..."
sleep 5

# User Service 컨테이너 실행
echo "6. User Service 컨테이너 실행 중..."
docker run -d \
  --name user-service \
  --network microservices-net \
  -p 3001:3001 \
  -v ~/microservices-lab/services/user-service:/app \
  -w /app \
  node:16-alpine \
  sh -c "npm install && npm start"

# 서비스 시작 대기
echo "7. User Service 시작 대기 중..."
sleep 10

# 서비스 상태 확인
echo "8. User Service 상태 확인 중..."
if curl -s http://localhost:3001/health | grep -q "healthy"; then
    echo "✅ User Service 정상 실행"
    echo ""
    echo "서비스 정보:"
    echo "- 포트: 3001"
    echo "- 헬스체크: http://localhost:3001/health"
    echo "- API 엔드포인트: http://localhost:3001/users"
    echo ""
    echo "테스트:"
    curl -s http://localhost:3001/users | jq -r '.[] | "- \(.name) (\(.email))"'
else
    echo "❌ User Service 시작 실패"
    docker logs user-service
    exit 1
fi

echo ""
echo "=== User Service 배포 완료 ==="
