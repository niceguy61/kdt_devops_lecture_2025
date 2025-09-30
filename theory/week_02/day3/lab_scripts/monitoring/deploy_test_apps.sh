#!/bin/bash

# Week 2 Day 3 Lab 1: 테스트 애플리케이션 배포 스크립트
# 사용법: ./deploy_test_apps.sh

echo "=== 테스트 애플리케이션 배포 시작 ==="

echo "1. 에러 생성 애플리케이션 생성..."

# 에러 생성 애플리케이션 생성
mkdir -p test-apps
cat > test-apps/error-app.js << 'EOF'
const express = require('express');
const prometheus = require('prom-client');

const app = express();
const port = 4000;

// Prometheus 메트릭 설정
const collectDefaultMetrics = prometheus.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

const httpRequestTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const errorCounter = new prometheus.Counter({
  name: 'application_errors_total',
  help: 'Total number of application errors',
  labelNames: ['error_type', 'endpoint']
});

const databaseConnections = new prometheus.Gauge({
  name: 'database_connections_active',
  help: 'Number of active database connections'
});

const queueSize = new prometheus.Gauge({
  name: 'message_queue_size',
  help: 'Current message queue size'
});

// 시뮬레이션 데이터
let dbConnections = 0;
let messageQueue = 0;

// 메트릭 미들웨어
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

// 정상 엔드포인트
app.get('/', (req, res) => {
  res.json({ 
    message: 'Error Test App', 
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    uptime: process.uptime(),
    db_connections: dbConnections,
    queue_size: messageQueue
  });
});

// 에러 생성 엔드포인트들
app.get('/error/500', (req, res) => {
  errorCounter.labels('internal_server_error', '/error/500').inc();
  res.status(500).json({ error: 'Internal Server Error', message: 'Simulated server error' });
});

app.get('/error/404', (req, res) => {
  errorCounter.labels('not_found', '/error/404').inc();
  res.status(404).json({ error: 'Not Found', message: 'Resource not found' });
});

app.get('/error/timeout', (req, res) => {
  // 5초 지연 후 타임아웃 에러
  setTimeout(() => {
    errorCounter.labels('timeout', '/error/timeout').inc();
    res.status(408).json({ error: 'Request Timeout', message: 'Request took too long' });
  }, 5000);
});

app.get('/error/random', (req, res) => {
  const errors = [
    { status: 400, type: 'bad_request', message: 'Bad Request' },
    { status: 401, type: 'unauthorized', message: 'Unauthorized' },
    { status: 403, type: 'forbidden', message: 'Forbidden' },
    { status: 429, type: 'rate_limit', message: 'Too Many Requests' },
    { status: 503, type: 'service_unavailable', message: 'Service Unavailable' }
  ];
  
  const error = errors[Math.floor(Math.random() * errors.length)];
  errorCounter.labels(error.type, '/error/random').inc();
  res.status(error.status).json({ error: error.message, type: error.type });
});

// 부하 생성 엔드포인트
app.get('/load/cpu', (req, res) => {
  const start = Date.now();
  // CPU 집약적 작업 시뮬레이션
  while (Date.now() - start < 2000) {
    Math.random() * Math.random();
  }
  res.json({ message: 'CPU load test completed', duration: Date.now() - start });
});

app.get('/load/memory', (req, res) => {
  // 메모리 사용량 증가 시뮬레이션
  const bigArray = new Array(1000000).fill('memory test data');
  setTimeout(() => {
    res.json({ 
      message: 'Memory load test completed', 
      allocated: bigArray.length,
      memory_usage: process.memoryUsage()
    });
  }, 1000);
});

// 데이터베이스 연결 시뮬레이션
app.get('/db/connect', (req, res) => {
  dbConnections += Math.floor(Math.random() * 5) + 1;
  databaseConnections.set(dbConnections);
  res.json({ message: 'Database connections increased', active_connections: dbConnections });
});

app.get('/db/disconnect', (req, res) => {
  dbConnections = Math.max(0, dbConnections - Math.floor(Math.random() * 3) - 1);
  databaseConnections.set(dbConnections);
  res.json({ message: 'Database connections decreased', active_connections: dbConnections });
});

// 메시지 큐 시뮬레이션
app.post('/queue/add', (req, res) => {
  const count = req.body.count || 1;
  messageQueue += count;
  queueSize.set(messageQueue);
  res.json({ message: 'Messages added to queue', queue_size: messageQueue });
});

app.post('/queue/process', (req, res) => {
  const processed = Math.min(messageQueue, Math.floor(Math.random() * 10) + 1);
  messageQueue = Math.max(0, messageQueue - processed);
  queueSize.set(messageQueue);
  res.json({ message: 'Messages processed', processed: processed, remaining: messageQueue });
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

// 주기적으로 랜덤 메트릭 업데이트
setInterval(() => {
  // 데이터베이스 연결 수 변동
  dbConnections += Math.floor(Math.random() * 3) - 1;
  dbConnections = Math.max(0, Math.min(50, dbConnections));
  databaseConnections.set(dbConnections);
  
  // 큐 크기 변동
  messageQueue += Math.floor(Math.random() * 5) - 2;
  messageQueue = Math.max(0, Math.min(100, messageQueue));
  queueSize.set(messageQueue);
}, 10000);

const server = app.listen(port, '0.0.0.0', () => {
  console.log(`Error Test App running on port ${port}`);
  console.log(`Health check: http://localhost:${port}/health`);
  console.log(`Metrics: http://localhost:${port}/metrics`);
});

process.on('SIGTERM', () => {
  server.close(() => {
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  server.close(() => {
    process.exit(0);
  });
});
EOF

echo "2. 테스트 애플리케이션 package.json 생성..."

cat > test-apps/package.json << 'EOF'
{
  "name": "error-test-app",
  "version": "1.0.0",
  "main": "error-app.js",
  "dependencies": {
    "express": "^4.18.0",
    "prom-client": "^14.0.0"
  },
  "scripts": {
    "start": "node error-app.js"
  }
}
EOF

echo "3. 테스트 애플리케이션 Dockerfile 생성..."

cat > test-apps/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 4000

CMD ["npm", "start"]
EOF

echo "4. 테스트 애플리케이션 이미지 빌드..."

cd test-apps
docker build -t error-test-app:v1 .
cd ..

echo "5. 테스트 애플리케이션 실행..."

docker run -d \
  --name error-test-app \
  -p 4000:4000 \
  --restart=unless-stopped \
  error-test-app:v1

sleep 5

echo "6. 애플리케이션 상태 확인..."

if curl -s http://localhost:4000/health > /dev/null; then
    echo "✅ 에러 테스트 앱 정상 동작"
else
    echo "❌ 에러 테스트 앱 실행 실패"
fi

echo "7. Prometheus 설정 업데이트..."

# Prometheus 설정에 새 애플리케이션 추가
cat >> monitoring/prometheus.yml << 'EOF'

  - job_name: 'error-app'
    static_configs:
      - targets: ['host.docker.internal:4000']
    metrics_path: '/metrics'
    scrape_interval: 10s
EOF

# Prometheus 설정 리로드
curl -X POST http://localhost:9090/-/reload > /dev/null 2>&1

echo "8. 테스트 스크립트 생성..."

cat > test_error_scenarios.sh << 'EOF'
#!/bin/bash

echo "=== 에러 시나리오 테스트 시작 ==="

echo "1. 다양한 에러 생성..."
curl -s http://localhost:4000/error/500 > /dev/null &
curl -s http://localhost:4000/error/404 > /dev/null &
curl -s http://localhost:4000/error/random > /dev/null &

echo "2. 부하 생성..."
for i in {1..5}; do
  curl -s http://localhost:4000/load/cpu > /dev/null &
  curl -s http://localhost:4000/load/memory > /dev/null &
done

echo "3. 데이터베이스 연결 시뮬레이션..."
curl -s http://localhost:4000/db/connect > /dev/null
curl -s http://localhost:4000/db/connect > /dev/null

echo "4. 메시지 큐 시뮬레이션..."
curl -s -X POST -H "Content-Type: application/json" -d '{"count":10}' http://localhost:4000/queue/add > /dev/null
curl -s -X POST http://localhost:4000/queue/process > /dev/null

echo "5. 랜덤 에러 생성 (30초간)..."
for i in {1..30}; do
  curl -s http://localhost:4000/error/random > /dev/null &
  sleep 1
done

wait

echo "✅ 에러 시나리오 테스트 완료"
echo "Prometheus에서 메트릭 확인: http://localhost:9090"
echo "Grafana에서 대시보드 확인: http://localhost:3001"
EOF

chmod +x test_error_scenarios.sh

echo ""
echo "=== 테스트 애플리케이션 배포 완료 ==="
echo ""
echo "배포된 애플리케이션:"
echo "- 메인 앱: http://localhost:3000 (기존)"
echo "- 에러 테스트 앱: http://localhost:4000 (신규)"
echo ""
echo "에러 테스트 엔드포인트:"
echo "- GET /error/500 - 서버 에러"
echo "- GET /error/404 - 찾을 수 없음"
echo "- GET /error/timeout - 타임아웃"
echo "- GET /error/random - 랜덤 에러"
echo "- GET /load/cpu - CPU 부하"
echo "- GET /load/memory - 메모리 부하"
echo "- GET /db/connect - DB 연결 증가"
echo "- POST /queue/add - 큐에 메시지 추가"
echo ""
echo "메트릭 확인:"
echo "- 에러 테스트 앱 메트릭: http://localhost:4000/metrics"
echo "- Prometheus 타겟: http://localhost:9090/targets"
echo ""
echo "테스트 실행:"
echo "./test_error_scenarios.sh"