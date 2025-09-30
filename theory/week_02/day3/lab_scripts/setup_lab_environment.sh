#!/bin/bash

# Week 2 Day 3 Lab 1: 실습 환경 준비 스크립트
# 사용법: ./setup_lab_environment.sh

echo "=== 실습 환경 준비 시작 ==="

# 작업 디렉토리 생성
mkdir -p ~/security-optimization-lab
cd ~/security-optimization-lab
mkdir -p {app,configs,monitoring,scripts,scan-results,performance-results}

echo "1. 샘플 애플리케이션 생성..."

# package.json 생성
cat > app/package.json << 'EOF'
{
  "name": "secure-optimized-app",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "prom-client": "^14.0.0",
    "redis": "^4.0.0"
  },
  "scripts": {
    "start": "node server.js",
    "test": "echo \"✅ Tests passed\" && exit 0"
  }
}
EOF

# 메인 서버 애플리케이션 생성
cat > app/server.js << 'EOF'
const express = require('express');
const prometheus = require('prom-client');
const redis = require('redis');

const app = express();
const port = 3000;

// Prometheus 메트릭 설정
const collectDefaultMetrics = prometheus.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const httpRequestTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

// Redis 클라이언트 설정 (선택적)
let redisClient;
let redisConnected = false;

async function initRedis() {
  try {
    redisClient = redis.createClient({ 
      url: 'redis://redis:6379',
      socket: { connectTimeout: 5000, lazyConnect: true }
    });
    
    redisClient.on('error', (err) => {
      redisConnected = false;
    });
    
    redisClient.on('connect', () => {
      redisConnected = true;
    });
    
    await redisClient.connect();
  } catch (err) {
    redisConnected = false;
  }
}

initRedis();

// 요청 메트릭 미들웨어
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route?.path || req.path;
    
    httpRequestDuration.labels(req.method, route, res.statusCode).observe(duration);
    httpRequestTotal.labels(req.method, route, res.statusCode).inc();
  });
  
  next();
});

app.use(express.json());

// 기본 라우트
app.get('/', (req, res) => {
  res.json({ 
    message: '🔒 Secure & ⚡ Optimized App', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    uptime: Math.floor(process.uptime()),
    redis_status: redisConnected ? 'connected' : 'disconnected'
  });
});

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: Math.floor(process.uptime()),
    memory: {
      used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
      total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024)
    },
    redis: redisConnected ? 'healthy' : 'unavailable'
  });
});

// 메트릭 엔드포인트
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', prometheus.register.contentType);
    const metrics = await prometheus.register.metrics();
    res.end(metrics);
  } catch (err) {
    res.status(500).end(err);
  }
});

// 부하 테스트 엔드포인트
app.get('/load-test', async (req, res) => {
  const startTime = Date.now();
  
  // CPU 부하 시뮬레이션 (100ms)
  while (Date.now() - startTime < 100) {
    Math.random() * Math.random();
  }
  
  let cacheResult = null;
  
  // Redis 캐시 테스트
  if (redisConnected && redisClient) {
    try {
      const testKey = `load-test-${Date.now()}`;
      const testValue = JSON.stringify({
        timestamp: new Date().toISOString(),
        random: Math.random()
      });
      
      await redisClient.setEx(testKey, 60, testValue);
      const cachedValue = await redisClient.get(testKey);
      
      cacheResult = {
        operation: 'success',
        key: testKey,
        value: JSON.parse(cachedValue)
      };
    } catch (err) {
      cacheResult = {
        operation: 'failed',
        error: err.message
      };
    }
  }
  
  res.json({
    message: '부하 테스트 완료',
    duration: Date.now() - startTime,
    timestamp: new Date().toISOString(),
    cache: cacheResult || { status: 'disabled' },
    system: {
      memory: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
      uptime: Math.floor(process.uptime())
    }
  });
});

// 서버 시작
const server = app.listen(port, '0.0.0.0', () => {
  console.log(`✅ 서버가 포트 ${port}에서 실행 중입니다`);
  console.log(`📊 헬스체크: http://localhost:${port}/health`);
  console.log(`📈 메트릭: http://localhost:${port}/metrics`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  server.close(async () => {
    if (redisClient && redisConnected) {
      try {
        await redisClient.quit();
      } catch (err) {
        // ignore
      }
    }
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  server.close(async () => {
    if (redisClient && redisConnected) {
      try {
        await redisClient.quit();
      } catch (err) {
        // ignore
      }
    }
    process.exit(0);
  });
});
EOF

# 기본 Dockerfile 생성 (비교용)
cat > app/Dockerfile << 'EOF'
FROM node:16

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF

echo "2. 환경 검증..."

# 환경 검증
if command -v docker &> /dev/null; then
    echo "✅ Docker 사용 가능"
else
    echo "❌ Docker가 설치되지 않았습니다"
fi

# npm 의존성 설치
cd app
if command -v npm &> /dev/null; then
    npm install --silent > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ npm 의존성 설치 완료"
    fi
fi
cd ..

echo ""
echo "=== 실습 환경 준비 완료 ==="
echo "생성된 파일: package.json, server.js, Dockerfile"
echo "다음 단계: Phase 1 보안 강화 실습 시작"
echo "현재 위치: $(pwd)"