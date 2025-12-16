#!/bin/bash

# ECR 저장소 설정 및 샘플 애플리케이션 빌드 스크립트

echo "🚀 ECR 저장소 설정 시작..."
echo "=================================="

# 환경 변수 설정
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export REGION="ap-northeast-2"
export ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

echo "Account ID: $ACCOUNT_ID"
echo "Region: $REGION"
echo "ECR Registry: $ECR_REGISTRY"

# ECR 저장소 생성
echo -e "\n📁 ECR 저장소 생성 중..."
REPOSITORIES=("frontend-app" "backend-api" "nginx-proxy")

for repo in "${REPOSITORIES[@]}"; do
    echo "생성 중: $repo"
    
    # 저장소가 이미 존재하는지 확인
    if aws ecr describe-repositories --repository-names "$repo" --region $REGION > /dev/null 2>&1; then
        echo "✅ 저장소 '$repo'가 이미 존재합니다"
    else
        aws ecr create-repository --repository-name "$repo" --region $REGION > /dev/null
        if [ $? -eq 0 ]; then
            echo "✅ 저장소 '$repo' 생성 완료"
        else
            echo "❌ 저장소 '$repo' 생성 실패"
            exit 1
        fi
    fi
    
    # 이미지 스캔 활성화
    aws ecr put-image-scanning-configuration \
        --repository-name "$repo" \
        --image-scanning-configuration scanOnPush=true \
        --region $REGION > /dev/null
done

# ECR 로그인
echo -e "\n🔐 ECR 로그인 중..."
aws ecr get-login-password --region $REGION | \
    docker login --username AWS --password-stdin $ECR_REGISTRY

if [ $? -eq 0 ]; then
    echo "✅ ECR 로그인 성공"
else
    echo "❌ ECR 로그인 실패"
    exit 1
fi

# 샘플 애플리케이션 디렉토리 생성
echo -e "\n📁 샘플 애플리케이션 생성 중..."
mkdir -p apps/{frontend,backend}

# Frontend 애플리케이션 생성
echo "📝 Frontend 애플리케이션 생성 중..."
cd apps/frontend

cat > Dockerfile << 'EOF'
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

cat > package.json << 'EOF'
{
  "name": "frontend-app",
  "version": "1.0.0",
  "scripts": {
    "build": "echo 'Building frontend...' && mkdir -p build && echo '<h1>Frontend App v1.0.0</h1><p>Timestamp: '$(date)'</p>' > build/index.html"
  }
}
EOF

cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}
http {
    upstream backend {
        server backend-service:3000;
    }
    
    server {
        listen 80;
        
        location / {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
        
        location /api/ {
            proxy_pass http://backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

cd ../..

# Backend 애플리케이션 생성
echo "📝 Backend 애플리케이션 생성 중..."
cd apps/backend

cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
EOF

cat > package.json << 'EOF'
{
  "name": "backend-api",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    version: '1.0.0', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/api/data', (req, res) => {
  res.json({ 
    message: 'Hello from Backend API',
    data: [
      { id: 1, name: 'Item 1', timestamp: new Date().toISOString() },
      { id: 2, name: 'Item 2', timestamp: new Date().toISOString() }
    ],
    database_status: process.env.DB_HOST ? 'configured' : 'not_configured'
  });
});

app.listen(port, () => {
  console.log(`Backend API listening at http://localhost:${port}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
EOF

cd ../..

# 이미지 빌드 및 푸시
echo -e "\n🔨 이미지 빌드 및 푸시 중..."

# Frontend 이미지
echo "Frontend 이미지 빌드 중..."
cd apps/frontend
docker build -t frontend-app:v1.0.0 . > /dev/null

docker tag frontend-app:v1.0.0 $ECR_REGISTRY/frontend-app:v1.0.0
docker tag frontend-app:v1.0.0 $ECR_REGISTRY/frontend-app:latest

echo "Frontend 이미지 푸시 중..."
docker push $ECR_REGISTRY/frontend-app:v1.0.0 > /dev/null
docker push $ECR_REGISTRY/frontend-app:latest > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Frontend 이미지 푸시 완료"
else
    echo "❌ Frontend 이미지 푸시 실패"
    exit 1
fi

cd ../..

# Backend 이미지
echo "Backend 이미지 빌드 중..."
cd apps/backend
docker build -t backend-api:v1.0.0 . > /dev/null

docker tag backend-api:v1.0.0 $ECR_REGISTRY/backend-api:v1.0.0
docker tag backend-api:v1.0.0 $ECR_REGISTRY/backend-api:latest

echo "Backend 이미지 푸시 중..."
docker push $ECR_REGISTRY/backend-api:v1.0.0 > /dev/null
docker push $ECR_REGISTRY/backend-api:latest > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Backend 이미지 푸시 완료"
else
    echo "❌ Backend 이미지 푸시 실패"
    exit 1
fi

cd ../..

# 결과 확인
echo -e "\n📋 ECR 저장소 및 이미지 확인:"
for repo in "${REPOSITORIES[@]}"; do
    echo -e "\n🔍 저장소: $repo"
    aws ecr list-images --repository-name "$repo" --region $REGION \
        --query 'imageIds[*].imageTag' --output table
done

echo -e "\n🎯 ECR 설정 완료!"
echo "이미지 URI:"
echo "  Frontend: $ECR_REGISTRY/frontend-app:v1.0.0"
echo "  Backend:  $ECR_REGISTRY/backend-api:v1.0.0"
echo ""
echo "다음 단계:"
echo "  1. Session 2에서 이 이미지들을 사용하여 멀티 티어 애플리케이션 배포"
echo "  2. kubectl을 사용하여 Kubernetes 클러스터에 배포"
