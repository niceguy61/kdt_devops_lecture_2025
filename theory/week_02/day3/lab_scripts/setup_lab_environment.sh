#!/bin/bash

echo "=== 실습 환경 준비 시작 ==="

mkdir -p security-optimization-lab
cd security-optimization-lab
mkdir -p {app,configs,monitoring,scripts,scan-results,performance-results}

echo "1. 샘플 애플리케이션 생성..."

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
    "test": "echo \"Tests passed\" && exit 0"
  }
}
EOF

cat > app/server.js << 'EOF'
const express = require('express');
const prometheus = require('prom-client');
const redis = require('redis');

const app = express();
const port = 3000;

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

app.get('/', (req, res) => {
  res.json({ 
    message: 'Secure & Optimized App', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    uptime: Math.floor(process.uptime()),
    redis_status: redisConnected ? 'connected' : 'disconnected'
  });
});

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

app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', prometheus.register.contentType);
    const metrics = await prometheus.register.metrics();
    res.end(metrics);
  } catch (err) {
    res.status(500).end(err);
  }
});

app.get('/load-test', async (req, res) => {
  const startTime = Date.now();
  
  while (Date.now() - startTime < 100) {
    Math.random() * Math.random();
  }
  
  let cacheResult = null;
  
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
    message: 'Load test completed',
    duration: Date.now() - startTime,
    timestamp: new Date().toISOString(),
    cache: cacheResult || { status: 'disabled' },
    system: {
      memory: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
      uptime: Math.floor(process.uptime())
    }
  });
});

const server = app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
  console.log(`Health check: http://localhost:${port}/health`);
  console.log(`Metrics: http://localhost:${port}/metrics`);
});

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

if command -v docker &> /dev/null; then
    echo "Docker available"
else
    echo "Docker not found"
fi

cd app
if command -v npm &> /dev/null; then
    npm install --silent > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "npm dependencies installed"
    fi
fi
cd ..

echo ""
echo "=== Setup complete ==="
echo "Files created: package.json, server.js, Dockerfile"
echo "Next: ../security/security_scan.sh"
echo "Working directory: $(pwd)"