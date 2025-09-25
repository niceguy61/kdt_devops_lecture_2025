# Week 1 Day 4 Lab 1: Docker Compose 실전 프로젝트

<div align="center">

**🎼 멀티 컨테이너 오케스트레이션** • **Week 1 통합 프로젝트**

*Docker Compose로 완성하는 풀스택 웹 애플리케이션*

</div>

---

## 🕘 실습 정보

**시간**: 12:00-12:50 (50분)  
**목표**: Docker Compose를 활용한 실무급 멀티 컨테이너 애플리케이션 구축  
**방식**: 프로젝트 기반 실습 + 페어 프로그래밍

---

## 🎯 실습 목표

### 📚 학습 목표
- **기본 목표**: Docker Compose로 멀티 컨테이너 애플리케이션 구축
- **응용 목표**: 환경별 설정 분리 및 프로덕션 배포 준비
- **협업 목표**: 페어 프로그래밍을 통한 실무 프로젝트 완성

---

## 🚀 Phase 1: 프로젝트 구조 설계 (30분)

### 🏗️ 풀스택 애플리케이션 아키텍처
**목표 아키텍처**:
```mermaid
graph TB
    A[Nginx<br/>Reverse Proxy] --> B[React Frontend]
    A --> C[Node.js Backend]
    C --> D[PostgreSQL<br/>Database]
    C --> E[Redis<br/>Cache]
    
    F[Prometheus<br/>Monitoring] --> C
    G[Grafana<br/>Dashboard] --> F
    
    style A fill:#e3f2fd
    style B fill:#e8f5e8
    style C fill:#fff3e0
    style D fill:#ffebee
    style E fill:#f3e5f5
```

**Step 1: 프로젝트 구조 생성**
```bash
# 메인 프로젝트 디렉토리 생성
mkdir ~/docker-fullstack && cd ~/docker-fullstack

# 서비스별 디렉토리 구조
mkdir -p {frontend,backend,nginx,monitoring}
mkdir -p {frontend/src,backend/src}

# 환경별 설정 파일 준비
touch docker-compose.yml
touch docker-compose.dev.yml
touch docker-compose.prod.yml
touch .env.example
```

**Step 2: 기본 docker-compose.yml 작성**
```yaml
# docker-compose.yml
version: '3.8'

services:
  # Frontend Service
  frontend:
    build: ./frontend
    container_name: fullstack-frontend
    depends_on:
      - backend
    networks:
      - app-network

  # Backend Service  
  backend:
    build: ./backend
    container_name: fullstack-backend
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@postgres:5432/${DB_NAME}
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis
    networks:
      - app-network

  # Database Service
  postgres:
    image: postgres:15-alpine
    container_name: fullstack-db
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backend/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - app-network

  # Cache Service
  redis:
    image: redis:7-alpine
    container_name: fullstack-cache
    volumes:
      - redis_data:/data
    networks:
      - app-network

  # Reverse Proxy
  nginx:
    build: ./nginx
    container_name: fullstack-proxy
    ports:
      - "80:80"
    depends_on:
      - frontend
      - backend
    networks:
      - app-network

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

### ✅ Phase 1 체크포인트
- [ ] 프로젝트 디렉토리 구조 생성
- [ ] 기본 docker-compose.yml 파일 작성
- [ ] 서비스 간 의존성 및 네트워크 설정
- [ ] 볼륨을 통한 데이터 영속성 설정

---

## 🌟 Phase 2: 각 서비스 구현 (60분)

### 🎨 Frontend 서비스 (React)
**Step 1: React 애플리케이션 생성**
```bash
cd frontend

# package.json 생성
cat > package.json << 'EOF'
{
  "name": "fullstack-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "serve": "serve -s build -l 3000"
  },
  "devDependencies": {
    "react-scripts": "5.0.1",
    "serve": "^14.2.0"
  }
}
EOF

# 간단한 React 컴포넌트
mkdir -p src
cat > src/App.js << 'EOF'
import React, { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [data, setData] = useState(null);
  const [users, setUsers] = useState([]);

  useEffect(() => {
    // API 상태 확인
    axios.get('/api/health')
      .then(response => setData(response.data))
      .catch(error => console.error('API Error:', error));

    // 사용자 목록 가져오기
    axios.get('/api/users')
      .then(response => setUsers(response.data))
      .catch(error => console.error('Users Error:', error));
  }, []);

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial' }}>
      <h1>Docker Fullstack Application</h1>
      
      <div style={{ marginBottom: '20px' }}>
        <h2>API Status</h2>
        {data ? (
          <div style={{ background: '#e8f5e8', padding: '10px', borderRadius: '5px' }}>
            <p>✅ Backend Connected</p>
            <p>Timestamp: {data.timestamp}</p>
            <p>Version: {data.version}</p>
          </div>
        ) : (
          <div style={{ background: '#ffebee', padding: '10px', borderRadius: '5px' }}>
            ❌ Backend Disconnected
          </div>
        )}
      </div>

      <div>
        <h2>Users ({users.length})</h2>
        <ul>
          {users.map(user => (
            <li key={user.id}>{user.name} - {user.email}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default App;
EOF

cat > src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
EOF

# public/index.html
mkdir -p public
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Docker Fullstack App</title>
</head>
<body>
    <div id="root"></div>
</body>
</html>
EOF

# Dockerfile
cat > Dockerfile << 'EOF'
# 빌드 스테이지
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# 프로덕션 스테이지
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY --from=builder /app/build ./build
EXPOSE 3000
CMD ["npm", "run", "serve"]
EOF
```

### 🔧 Backend 서비스 (Node.js + Express)
```bash
cd ../backend

# package.json
cat > package.json << 'EOF'
{
  "name": "fullstack-backend",
  "version": "1.0.0",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "pg": "^8.11.0",
    "redis": "^4.6.0"
  }
}
EOF

# 서버 코드
cat > src/server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const redis = require('redis');

const app = express();
const PORT = process.env.PORT || 5000;

// 미들웨어
app.use(cors());
app.use(express.json());

// 데이터베이스 연결
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

// Redis 연결
const redisClient = redis.createClient({
  url: process.env.REDIS_URL
});
redisClient.connect();

// 라우트
app.get('/api/health', async (req, res) => {
  try {
    const dbResult = await pool.query('SELECT NOW()');
    const redisResult = await redisClient.ping();
    
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: process.env.APP_VERSION || '1.0.0',
      database: dbResult.rows[0].now,
      cache: redisResult === 'PONG' ? 'connected' : 'disconnected'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/users', async (req, res) => {
  try {
    // Redis 캐시 확인
    const cached = await redisClient.get('users');
    if (cached) {
      return res.json(JSON.parse(cached));
    }

    // 데이터베이스에서 조회
    const result = await pool.query('SELECT * FROM users ORDER BY id');
    
    // Redis에 캐시 저장 (5분)
    await redisClient.setEx('users', 300, JSON.stringify(result.rows));
    
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Backend server running on port ${PORT}`);
});
EOF

# 데이터베이스 초기화 스크립트
cat > init.sql << 'EOF'
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES
    ('Alice Johnson', 'alice@example.com'),
    ('Bob Smith', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com'),
    ('Diana Prince', 'diana@example.com')
ON CONFLICT (email) DO NOTHING;
EOF

# Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
RUN adduser -D appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 5000
CMD ["npm", "start"]
EOF
```

### 🌐 Nginx 리버스 프록시
```bash
cd ../nginx

# Nginx 설정
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }
    
    upstream backend {
        server backend:5000;
    }

    server {
        listen 80;
        
        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Backend API
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
EOF

# Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
```

### ✅ Phase 2 체크포인트
- [ ] React 프론트엔드 서비스 구현
- [ ] Node.js 백엔드 API 서버 구현
- [ ] PostgreSQL 데이터베이스 초기화
- [ ] Redis 캐시 연동
- [ ] Nginx 리버스 프록시 설정

---

## 🏆 Phase 3: 환경별 설정 (20분)

### ⚙️ 환경별 Compose 파일
**개발 환경 설정**
```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  frontend:
    volumes:
      - ./frontend/src:/app/src  # 핫 리로드
    environment:
      - REACT_APP_API_URL=http://localhost/api

  backend:
    volumes:
      - ./backend/src:/app/src  # 개발 시 코드 변경 반영
    environment:
      - NODE_ENV=development
      - DEBUG=true

  postgres:
    ports:
      - "5432:5432"  # 개발 시 직접 접근 가능

  redis:
    ports:
      - "6379:6379"  # 개발 시 직접 접근 가능
```

**프로덕션 환경 설정**
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  frontend:
    restart: always
    environment:
      - NODE_ENV=production

  backend:
    restart: always
    environment:
      - NODE_ENV=production
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  postgres:
    restart: always
    deploy:
      resources:
        limits:
          memory: 1G

  redis:
    restart: always
    command: redis-server --appendonly yes

  nginx:
    restart: always
```

**환경 변수 파일**
```bash
# .env.example
NODE_ENV=development
DB_NAME=fullstack_db
DB_USER=postgres
DB_PASSWORD=password
APP_VERSION=1.0.0

# .env (실제 사용)
cp .env.example .env
```

### ✅ Phase 3 체크포인트
- [ ] 개발 환경용 Compose 오버라이드 설정
- [ ] 프로덕션 환경용 최적화 설정
- [ ] 환경 변수 파일 구성
- [ ] 리소스 제한 및 재시작 정책 설정

---

## 🎯 Phase 4: 애플리케이션 실행 및 테스트 (10분)

### 🚀 전체 스택 실행
```bash
# 개발 환경 실행
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build

# 별도 터미널에서 테스트
curl http://localhost/api/health
curl http://localhost/api/users

# 브라우저에서 http://localhost 접속 확인
```

### 📊 상태 확인
```bash
# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs backend
docker-compose logs frontend

# 네트워크 확인
docker network ls
docker network inspect fullstack_app-network
```

### ✅ Phase 4 체크포인트
- [ ] 전체 스택 정상 실행
- [ ] 프론트엔드-백엔드 통신 확인
- [ ] 데이터베이스 연결 및 데이터 조회
- [ ] Redis 캐시 동작 확인

---

## 🚀 숙련자 추가 미션 (20분)

### 🔥 고급 기능 추가
**미션 1: 모니터링 스택 추가**
```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'backend'
    static_configs:
      - targets: ['backend:5000']

# monitoring/docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - app-network

  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - app-network
```

**미션 2: 헬스체크 및 의존성 대기**
```yaml
# docker-compose.yml에 추가
services:
  backend:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
  postgres:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
```

**미션 3: 로그 수집**
```yaml
# logging/docker-compose.logging.yml
version: '3.8'

services:
  elasticsearch:
    image: elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"

  kibana:
    image: kibana:7.14.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
```

### ✅ 고급 미션 체크포인트
- [ ] Prometheus + Grafana 모니터링 구성
- [ ] 헬스체크 및 의존성 대기 설정
- [ ] 중앙화된 로그 수집 시스템 구축

---

## 📝 실습 마무리

### ✅ Week 1 통합 프로젝트 성과
- [ ] Docker Compose를 활용한 멀티 컨테이너 애플리케이션 완성
- [ ] 프론트엔드, 백엔드, 데이터베이스, 캐시 통합 구성
- [ ] 환경별 설정 분리 및 배포 전략 구현
- [ ] 리버스 프록시를 통한 서비스 통합
- [ ] 모니터링 및 로깅 시스템 구축 (고급)

### 🎯 Week 2 준비사항
- **주제**: 컨테이너 오케스트레이션 기초 (Kubernetes)
- **연결고리**: Docker Compose → Kubernetes 클러스터
- **준비사항**: 오늘 구축한 애플리케이션을 Kubernetes로 마이그레이션 준비

### 🏆 프로젝트 포트폴리오
```bash
# 프로젝트 정리
docker-compose down
docker system prune -f

# GitHub에 업로드 준비
git init
git add .
git commit -m "Week 1 Docker Fullstack Project Complete"
```

---

<div align="center">

**🎼 Docker Compose 마스터 프로젝트 완성! 🎼**

*멀티 컨테이너 오케스트레이션의 완벽한 이해와 실무 적용*

**다음**: [Week 2 - 컨테이너 오케스트레이션 기초](../../week_02/README.md)

</div>