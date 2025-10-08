#!/bin/bash

# Week 4 Day 2 Hands-on 1: JWT 인증 시스템 구축
# 사용법: ./setup-jwt-auth.sh

echo "=== JWT 인증 시스템 구축 시작 ==="

# 기존 인증 서비스 정리
echo "1. 기존 인증 서비스 정리 중..."
docker stop auth-service 2>/dev/null || true
docker rm auth-service 2>/dev/null || true

# 인증 서비스 디렉토리 생성
echo "2. 인증 서비스 디렉토리 생성 중..."
mkdir -p ~/microservices-lab/services/auth-service

# JWT 인증 서비스 코드 생성
echo "3. JWT 인증 서비스 코드 생성 중..."
cat > ~/microservices-lab/services/auth-service/app.js << 'EOF'
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const consul = require('consul')({
  host: 'consul-server',
  port: 8500
});

const app = express();
const PORT = 3004;
const JWT_SECRET = 'microservices-jwt-secret-2024';

app.use(express.json());

// 테스트용 사용자 데이터 (실제로는 데이터베이스 사용)
const users = [
  { 
    id: 1, 
    username: 'admin', 
    password: '$2b$10$rOzJqQnQjQjQjQjQjQjQjOzJqQnQjQjQjQjQjQjQjOzJqQnQjQjQjQ', // 'admin123'
    role: 'admin',
    email: 'admin@example.com'
  },
  { 
    id: 2, 
    username: 'user', 
    password: '$2b$10$rOzJqQnQjQjQjQjQjQjQjOzJqQnQjQjQjQjQjQjQjOzJqQnQjQjQjQ', // 'user123'
    role: 'user',
    email: 'user@example.com'
  }
];

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'auth-service',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// 로그인 엔드포인트
app.post('/auth/login', async (req, res) => {
  const { username, password } = req.body;
  
  console.log(`Login attempt: ${username}`);
  
  // 간단한 인증 (실제로는 bcrypt 사용)
  const user = users.find(u => u.username === username);
  
  if (user && (password === 'admin123' || password === 'user123')) {
    const token = jwt.sign(
      { 
        userId: user.id, 
        username: user.username, 
        role: user.role,
        email: user.email
      },
      JWT_SECRET,
      { expiresIn: '1h' }
    );
    
    res.json({ 
      success: true,
      token, 
      user: { 
        id: user.id, 
        username: user.username, 
        role: user.role,
        email: user.email
      } 
    });
  } else {
    res.status(401).json({ 
      success: false,
      error: 'Invalid credentials' 
    });
  }
});

// 토큰 검증 엔드포인트
app.post('/auth/verify', (req, res) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.startsWith('Bearer ') 
    ? authHeader.slice(7) 
    : authHeader;
  
  if (!token) {
    return res.status(401).json({ 
      valid: false, 
      error: 'No token provided' 
    });
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    res.json({ 
      valid: true, 
      user: decoded 
    });
  } catch (error) {
    res.status(401).json({ 
      valid: false, 
      error: 'Invalid or expired token' 
    });
  }
});

// 사용자 정보 조회 (인증 필요)
app.get('/auth/me', (req, res) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.startsWith('Bearer ') 
    ? authHeader.slice(7) 
    : authHeader;
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = users.find(u => u.id === decoded.userId);
    
    if (user) {
      res.json({
        id: user.id,
        username: user.username,
        role: user.role,
        email: user.email
      });
    } else {
      res.status(404).json({ error: 'User not found' });
    }
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

// 서버 시작 및 Consul 등록
app.listen(PORT, () => {
  console.log(`Auth Service running on port ${PORT}`);
  
  // Consul 등록
  const registerWithConsul = (retries = 5) => {
    consul.agent.service.register({
      id: 'auth-service-1',
      name: 'auth-service',
      tags: ['auth', 'jwt', 'security', 'v1'],
      address: 'auth-service',
      port: PORT,
      check: {
        http: `http://auth-service:${PORT}/health`,
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
        console.log('✅ Auth Service registered with Consul');
      }
    });
  };
  
  setTimeout(() => registerWithConsul(), 2000);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('Shutting down Auth Service...');
  consul.agent.service.deregister('auth-service-1', () => {
    process.exit(0);
  });
});
EOF

# package.json 생성
cat > ~/microservices-lab/services/auth-service/package.json << 'EOF'
{
  "name": "auth-service",
  "version": "1.0.0",
  "description": "JWT Authentication microservice",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.0",
    "bcrypt": "^5.1.0",
    "consul": "^0.40.0"
  }
}
EOF

# 인증 서비스 컨테이너 실행
echo "4. JWT 인증 서비스 컨테이너 실행 중..."
docker run -d \
  --name auth-service \
  --network microservices-net \
  -p 3004:3004 \
  -v ~/microservices-lab/services/auth-service:/app \
  -w /app \
  node:16-alpine \
  sh -c "npm install && npm start"

# 서비스 시작 대기
echo "5. 인증 서비스 시작 대기 중..."
sleep 15

# Kong JWT 플러그인 설정
echo "6. Kong JWT 플러그인 설정 중..."

# JWT 플러그인 활성화
curl -s -X POST http://localhost:8001/plugins \
  --data "name=jwt" \
  --data "config.secret_is_base64=false" \
  --data "config.key_claim_name=iss" \
  --data "config.claims_to_verify=exp" > /dev/null

# JWT 소비자 생성
curl -s -X POST http://localhost:8001/consumers \
  --data "username=microservices-client" > /dev/null

# JWT 자격증명 생성
curl -s -X POST http://localhost:8001/consumers/microservices-client/jwt \
  --data "key=microservices-jwt-secret-2024" \
  --data "secret=microservices-jwt-secret-2024" > /dev/null

# 인증 서비스 상태 확인
echo "7. 인증 서비스 상태 확인 중..."
if curl -s http://localhost:3004/health | grep -q "healthy"; then
    echo "✅ JWT 인증 서비스 정상 실행"
    echo ""
    echo "서비스 정보:"
    echo "- 포트: 3004"
    echo "- 헬스체크: http://localhost:3004/health"
    echo "- 로그인: POST http://localhost:3004/auth/login"
    echo "- 토큰 검증: POST http://localhost:3004/auth/verify"
    echo ""
    echo "테스트 계정:"
    echo "- 관리자: admin / admin123"
    echo "- 사용자: user / user123"
    echo ""
    echo "로그인 테스트:"
    curl -s -X POST http://localhost:3004/auth/login \
      -H "Content-Type: application/json" \
      -d '{"username":"admin","password":"admin123"}' | \
      jq -r '"토큰: " + .token[:50] + "..."' 2>/dev/null || echo "로그인 API 준비 중..."
else
    echo "❌ JWT 인증 서비스 시작 실패"
    docker logs auth-service
    exit 1
fi

echo ""
echo "=== JWT 인증 시스템 구축 완료 ==="
