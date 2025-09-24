# Week 1 Day 3 Lab 1: Dockerfile & 이미지 빌드 실습

<div align="center">

**🏗️ 커스텀 이미지 제작** • **Dockerfile 실전 활용**

*나만의 Docker 이미지 만들기부터 최적화까지*

</div>

---

## 🕘 실습 정보

**시간**: 13:00-15:00 (120분)  
**목표**: Dockerfile 작성부터 이미지 최적화까지 완전 습득  
**방식**: 단계별 빌드 + 페어 프로그래밍 + 최적화 실습

---

## 🎯 실습 목표

### 📚 학습 목표
- **기본 목표**: Dockerfile 작성 및 이미지 빌드 완전 습득
- **응용 목표**: 멀티스테이지 빌드와 이미지 최적화 기법 적용
- **협업 목표**: 페어 프로그래밍을 통한 Dockerfile 리뷰 및 개선

---

## 🚀 Phase 1: 첫 번째 Dockerfile 작성 (40분)

### 🛠️ 필수 도구 설치 확인

#### 📝 텍스트 에디터 설치
**VS Code (추천)**
- **Windows**: [VS Code Windows](https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user)
- **macOS**: [VS Code macOS](https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal)
- **Linux**: [VS Code Linux](https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64)

**또는 기본 에디터 사용**
```bash
# Windows
notepad Dockerfile

# macOS
nano Dockerfile
# 또는
open -a TextEdit Dockerfile

# Linux
vim Dockerfile
# 또는
nano Dockerfile
```

#### 🔧 Git 설치 (선택사항)
**자동 설치 스크립트**
```bash
# Windows (PowerShell)
winget install Git.Git

# macOS
brew install git

# Linux (Ubuntu/Debian)
sudo apt-get install -y git

# 설치 확인
git --version
```

### 📝 간단한 웹 애플리케이션 만들기
**Step 1: 프로젝트 구조 생성**
```bash
# 작업 디렉토리 생성
mkdir ~/docker-webapp && cd ~/docker-webapp

# 간단한 HTML 파일 생성
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Docker App</title>
</head>
<body>
    <h1>Hello from Docker!</h1>
    <p>This is my first custom Docker image.</p>
</body>
</html>
EOF
```

**Step 2: 기본 Dockerfile 작성**
```dockerfile
# Dockerfile
FROM nginx:alpine

# 메타데이터 추가
LABEL maintainer="student@example.com"
LABEL description="My first Docker web application"

# HTML 파일 복사
COPY index.html /usr/share/nginx/html/

# 포트 노출
EXPOSE 80

# 기본 명령어는 베이스 이미지에서 상속
```

**Step 3: 이미지 빌드 및 실행**
```bash
# 이미지 빌드
docker build -t my-webapp:v1 .

# 빌드 과정 확인
docker images | grep my-webapp

# 컨테이너 실행
docker run -d -p 8080:80 --name webapp-v1 my-webapp:v1

# 브라우저에서 localhost:8080 확인
```

### ✅ Phase 1 체크포인트
- [ ] 필수 도구 (텍스트 에디터) 설치 확인
- [ ] Dockerfile 기본 문법 이해 및 작성
- [ ] docker build 명령어로 이미지 빌드 성공
- [ ] 커스텀 이미지로 컨테이너 실행 확인
- [ ] 웹 브라우저에서 결과 확인

---

## 🌟 Phase 2: Node.js 애플리케이션 빌드 (50분)

### 🔧 실제 애플리케이션 구축
**Step 1: Node.js 프로젝트 생성**
```bash
# 새 프로젝트 디렉토리
mkdir ~/docker-node-app && cd ~/docker-node-app

# package.json 생성
cat > package.json << 'EOF'
{
  "name": "docker-node-app",
  "version": "1.0.0",
  "description": "Simple Node.js app for Docker",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# 서버 파일 생성
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.json({
        message: 'Hello from Docker Node.js App!',
        timestamp: new Date().toISOString(),
        version: process.env.APP_VERSION || '1.0.0'
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
EOF
```

**Step 2: 최적화된 Dockerfile 작성**
```dockerfile
# Dockerfile
FROM node:18-alpine

# 작업 디렉토리 설정
WORKDIR /app

# package.json 먼저 복사 (캐시 최적화)
COPY package*.json ./

# 의존성 설치
RUN npm install --production && npm cache clean --force

# 애플리케이션 코드 복사
COPY . .

# 비root 사용자 생성 및 사용
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 && \
    chown -R nextjs:nodejs /app
USER nextjs

# 환경 변수 설정
ENV NODE_ENV=production
ENV APP_VERSION=1.0.0

# 포트 노출
EXPOSE 3000

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# 실행 명령
CMD ["npm", "start"]
```

**Step 3: .dockerignore 파일 생성**
```bash
# .dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
```

**Step 4: 빌드 및 테스트**
```bash
# 이미지 빌드
docker build -t node-app:v1 .

# 컨테이너 실행
docker run -d -p 3000:3000 --name node-app-v1 node-app:v1

# API 테스트
curl http://localhost:3000
curl http://localhost:3000/health

# 로그 확인
docker logs node-app-v1
```

### ✅ Phase 2 체크포인트
- [ ] Node.js 애플리케이션 Dockerfile 작성
- [ ] 레이어 캐싱 최적화 적용
- [ ] 보안을 위한 비root 사용자 설정
- [ ] .dockerignore로 불필요한 파일 제외
- [ ] 헬스체크 기능 추가

---

## 🏆 Phase 3: 멀티스테이지 빌드 실습 (20분)

### 🔄 빌드 최적화
**Step 1: 멀티스테이지 Dockerfile**
```dockerfile
# Dockerfile.multi
# 빌드 스테이지
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build 2>/dev/null || echo "No build script, skipping..."

# 프로덕션 스테이지
FROM node:18-alpine AS production
WORKDIR /app

# 프로덕션 의존성만 설치
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 빌드된 파일만 복사
COPY --from=builder /app/server.js ./
COPY --from=builder /app/package.json ./

# 사용자 설정
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 && \
    chown -R nextjs:nodejs /app
USER nextjs

EXPOSE 3000
CMD ["npm", "start"]
```

**Step 2: 이미지 크기 비교**
```bash
# 멀티스테이지 빌드
docker build -f Dockerfile.multi -t node-app:multi .

# 이미지 크기 비교
docker images | grep node-app
```

### ✅ Phase 3 체크포인트
- [ ] 멀티스테이지 빌드 Dockerfile 작성
- [ ] 빌드와 런타임 환경 분리
- [ ] 이미지 크기 최적화 확인
- [ ] 프로덕션 전용 의존성만 포함

---

## 🎯 Phase 4: 초보자 종합 실습 (10분)

### 📝 기본 미션
**미션**: Python Flask 애플리케이션 Docker화

```bash
# 프로젝트 생성
mkdir ~/docker-flask && cd ~/docker-flask

# Flask 앱 생성
cat > app.py << 'EOF'
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Flask in Docker!',
        'version': os.environ.get('APP_VERSION', '1.0.0')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# requirements.txt 생성
echo "Flask==2.3.3" > requirements.txt

# Dockerfile 작성
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
EOF

# 빌드 및 실행
docker build -t flask-app .
docker run -d -p 5000:5000 --name flask-demo flask-app
```

### ✅ 기본 미션 체크포인트
- [ ] Python Flask 애플리케이션 Dockerfile 작성
- [ ] 이미지 빌드 및 컨테이너 실행
- [ ] API 엔드포인트 정상 동작 확인

---

## 🚀 숙련자 추가 미션 (20분)

### 🔥 고급 미션
**미션 1: 고급 최적화 기법**
```dockerfile
# Dockerfile.optimized
FROM python:3.9-slim AS base

# 시스템 의존성 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 빌드 스테이지
FROM base AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

# 프로덕션 스테이지
FROM python:3.9-slim AS production
WORKDIR /app

# 빌드된 wheel 파일 복사 및 설치
COPY --from=builder /app/wheels /wheels
COPY requirements.txt .
RUN pip install --no-cache /wheels/*

# 애플리케이션 코드 복사
COPY . .

# 보안 설정
RUN useradd --create-home --shell /bin/bash app && chown -R app:app /app
USER app

EXPOSE 5000
CMD ["python", "app.py"]
```

**미션 2: 이미지 보안 스캔**
```bash
# Docker Scout 사용 (Docker Desktop 포함)
docker scout cves flask-app

# 또는 Trivy 사용
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image flask-app
```

**미션 3: 이미지 레이어 분석**
```bash
# 이미지 히스토리 확인
docker history flask-app

# 이미지 상세 정보
docker inspect flask-app

# 레이어별 크기 분석
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### ✅ 고급 미션 체크포인트
- [ ] 고급 멀티스테이지 빌드 구현
- [ ] 이미지 보안 스캔 실행
- [ ] 이미지 레이어 구조 분석
- [ ] 최적화 전후 성능 비교

---

## 🔧 베스트 프랙티스 체크리스트

### ✅ Dockerfile 작성 체크리스트
- [ ] 경량 베이스 이미지 사용 (alpine, slim)
- [ ] .dockerignore 파일 작성
- [ ] 레이어 캐싱 최적화 (자주 변경되지 않는 파일 먼저)
- [ ] 비root 사용자 사용
- [ ] 불필요한 패키지 설치 방지
- [ ] 명확한 태그 사용 (latest 금지)
- [ ] 헬스체크 추가
- [ ] 환경 변수 활용

### 🔒 보안 고려사항
- [ ] 민감한 정보 하드코딩 금지
- [ ] 최소 권한 원칙 적용
- [ ] 정기적인 베이스 이미지 업데이트
- [ ] 보안 스캔 도구 활용

---

## 📝 실습 마무리

### ✅ 오늘 실습 성과
- [ ] Dockerfile 작성 및 이미지 빌드 완전 습득
- [ ] 멀티스테이지 빌드를 통한 이미지 최적화
- [ ] 보안을 고려한 Dockerfile 작성
- [ ] 다양한 언어/프레임워크 Docker화 경험

### 🎯 내일 실습 준비
- **주제**: Docker Compose를 활용한 멀티 컨테이너 구성
- **준비사항**: 오늘 만든 이미지들 보관
- **연결고리**: 단일 컨테이너 → 멀티 컨테이너 오케스트레이션

---

<div align="center">

**🏗️ Dockerfile 마스터가 되었습니다**

*커스텀 이미지 제작부터 최적화까지 완벽 습득*

**다음**: [Day 4 - Docker Compose & 멀티 컨테이너](../day4/README.md)

</div>