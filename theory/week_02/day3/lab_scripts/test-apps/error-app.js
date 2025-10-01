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
