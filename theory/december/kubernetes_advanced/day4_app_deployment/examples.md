# Day 4 실습 예제 모음

## 🎯 목적
Day 4 세션에서 사용하는 모든 ECR 및 멀티 티어 애플리케이션 배포 명령어와 예제를 한 곳에 모아 챌린저들이 쉽게 참조할 수 있도록 합니다.

---

## 📋 Session 1 예제: 컨테이너 이미지 관리

### ECR 기본 설정

#### AWS 계정 정보 확인
```bash
# 현재 AWS 계정 정보
aws sts get-caller-identity

# 환경 변수 설정
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export REGION="ap-northeast-2"
export ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

echo "Account ID: $ACCOUNT_ID"
echo "Region: $REGION"
echo "ECR Registry: $ECR_REGISTRY"
```

### ECR 저장소 관리

#### 저장소 생성
```bash
# 단일 저장소 생성
aws ecr create-repository --repository-name my-app --region $REGION

# 여러 저장소 일괄 생성
REPOSITORIES=("frontend-app" "backend-api" "nginx-proxy" "worker-service")
for repo in "${REPOSITORIES[@]}"; do
    aws ecr create-repository --repository-name "$repo" --region $REGION
done

# 저장소 목록 확인
aws ecr describe-repositories --region $REGION --query 'repositories[*].repositoryName' --output table
```

#### 저장소 설정
```bash
# 이미지 스캔 활성화
aws ecr put-image-scanning-configuration \
    --repository-name my-app \
    --image-scanning-configuration scanOnPush=true \
    --region $REGION

# 라이프사이클 정책 설정 (최근 10개 이미지만 유지)
cat > lifecycle-policy.json << 'EOF'
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

aws ecr put-lifecycle-policy \
    --repository-name my-app \
    --lifecycle-policy-text file://lifecycle-policy.json \
    --region $REGION
```

#### 저장소 권한 관리
```bash
# 저장소 정책 설정 (다른 계정 접근 허용)
cat > repository-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPull",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::OTHER-ACCOUNT-ID:root"
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF

aws ecr set-repository-policy \
    --repository-name my-app \
    --policy-text file://repository-policy.json \
    --region $REGION
```

### Docker 이미지 관리

#### ECR 로그인
```bash
# ECR 로그인 (Docker CLI)
aws ecr get-login-password --region $REGION | \
    docker login --username AWS --password-stdin $ECR_REGISTRY

# 로그인 상태 확인
docker system info | grep -A 5 "Registry"

# 로그인 토큰 만료 시간 확인 (12시간)
aws ecr get-authorization-token --region $REGION \
    --query 'authorizationData[0].expiresAt' --output text
```

#### 이미지 빌드 및 태깅
```bash
# 기본 이미지 빌드
docker build -t my-app:latest .

# 멀티 스테이지 빌드 예제
cat > Dockerfile.multistage << 'EOF'
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

docker build -f Dockerfile.multistage -t my-app:v1.0.0 .

# 태깅 전략
docker tag my-app:v1.0.0 my-app:latest
docker tag my-app:v1.0.0 my-app:$(git rev-parse --short HEAD)
docker tag my-app:v1.0.0 $ECR_REGISTRY/my-app:v1.0.0
docker tag my-app:v1.0.0 $ECR_REGISTRY/my-app:latest
```

#### 이미지 푸시 및 관리
```bash
# 단일 이미지 푸시
docker push $ECR_REGISTRY/my-app:v1.0.0

# 모든 태그 푸시
docker push $ECR_REGISTRY/my-app:latest
docker push $ECR_REGISTRY/my-app:$(git rev-parse --short HEAD)

# 이미지 목록 확인
aws ecr list-images --repository-name my-app --region $REGION

# 이미지 상세 정보 확인
aws ecr describe-images \
    --repository-name my-app \
    --region $REGION \
    --query 'imageDetails[*].[imageTags[0],imageSizeInBytes,imagePushedAt]' \
    --output table

# 특정 이미지 삭제
aws ecr batch-delete-image \
    --repository-name my-app \
    --image-ids imageTag=old-version \
    --region $REGION
```

### 이미지 보안 및 스캔

#### 취약점 스캔
```bash
# 이미지 스캔 시작
aws ecr start-image-scan \
    --repository-name my-app \
    --image-id imageTag=v1.0.0 \
    --region $REGION

# 스캔 결과 확인
aws ecr describe-image-scan-findings \
    --repository-name my-app \
    --image-id imageTag=v1.0.0 \
    --region $REGION

# 스캔 결과 요약
aws ecr describe-image-scan-findings \
    --repository-name my-app \
    --image-id imageTag=v1.0.0 \
    --region $REGION \
    --query 'imageScanFindingsSummary'
```

---

## 📋 Session 2 예제: 멀티 티어 애플리케이션 배포

### 데이터베이스 계층

#### MySQL 배포 (StatefulSet 버전)
```yaml
# mysql-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql-headless
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-root-password
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

#### PostgreSQL 대안
```yaml
# postgres-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_DB
          value: appdb
        - name: POSTGRES_USER
          value: appuser
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-data
        emptyDir: {}
```

#### Redis 캐시 추가
```yaml
# redis-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        command: ["redis-server"]
        args: ["--appendonly", "yes"]
        volumeMounts:
        - name: redis-data
          mountPath: /data
      volumes:
      - name: redis-data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: redis-service
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
```

### 백엔드 API 계층

#### Node.js Express API
```javascript
// server.js - 완전한 예제
const express = require('express');
const mysql = require('mysql2/promise');
const redis = require('redis');

const app = express();
const port = process.env.PORT || 3000;

// 미들웨어
app.use(express.json());
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

// 데이터베이스 연결
const dbConfig = {
    host: process.env.DB_HOST || 'mysql-service',
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER || 'appuser',
    password: process.env.DB_PASSWORD || 'apppassword123',
    database: process.env.DB_NAME || 'appdb'
};

// Redis 연결
const redisClient = redis.createClient({
    host: process.env.REDIS_HOST || 'redis-service',
    port: process.env.REDIS_PORT || 6379
});

// API 엔드포인트
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        version: process.env.API_VERSION || '1.0.0',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

app.get('/api/data', async (req, res) => {
    try {
        const connection = await mysql.createConnection(dbConfig);
        const [rows] = await connection.execute('SELECT 1 as test');
        await connection.end();
        
        res.json({
            message: 'Data from backend API',
            database_status: 'connected',
            data: rows
        });
    } catch (error) {
        res.status(500).json({
            error: 'Database connection failed',
            message: error.message
        });
    }
});

app.listen(port, () => {
    console.log(`Backend API listening at http://localhost:${port}`);
});
```

#### Python Flask API 대안
```python
# app.py
from flask import Flask, jsonify
import os
import pymysql
import redis
from datetime import datetime

app = Flask(__name__)

# 데이터베이스 설정
db_config = {
    'host': os.getenv('DB_HOST', 'mysql-service'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'user': os.getenv('DB_USER', 'appuser'),
    'password': os.getenv('DB_PASSWORD', 'apppassword123'),
    'database': os.getenv('DB_NAME', 'appdb')
}

@app.route('/api/health')
def health():
    return jsonify({
        'status': 'healthy',
        'version': os.getenv('API_VERSION', '1.0.0'),
        'timestamp': datetime.now().isoformat(),
        'environment': os.getenv('FLASK_ENV', 'development')
    })

@app.route('/api/data')
def get_data():
    try:
        connection = pymysql.connect(**db_config)
        cursor = connection.cursor()
        cursor.execute('SELECT 1 as test')
        result = cursor.fetchall()
        connection.close()
        
        return jsonify({
            'message': 'Data from Python Flask API',
            'database_status': 'connected',
            'data': result
        })
    except Exception as e:
        return jsonify({
            'error': 'Database connection failed',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', 3000)))
```

### 프론트엔드 계층

#### React 애플리케이션
```javascript
// src/App.js
import React, { useState, useEffect } from 'react';

function App() {
    const [health, setHealth] = useState(null);
    const [data, setData] = useState(null);

    useEffect(() => {
        // 헬스체크
        fetch('/api/health')
            .then(res => res.json())
            .then(data => setHealth(data))
            .catch(err => console.error('Health check failed:', err));

        // 데이터 가져오기
        fetch('/api/data')
            .then(res => res.json())
            .then(data => setData(data))
            .catch(err => console.error('Data fetch failed:', err));
    }, []);

    return (
        <div style={{ padding: '20px', fontFamily: 'Arial' }}>
            <h1>Multi-Tier Application</h1>
            
            <div style={{ marginBottom: '20px' }}>
                <h2>Backend Health</h2>
                {health ? (
                    <pre>{JSON.stringify(health, null, 2)}</pre>
                ) : (
                    <p>Loading health status...</p>
                )}
            </div>

            <div>
                <h2>Backend Data</h2>
                {data ? (
                    <pre>{JSON.stringify(data, null, 2)}</pre>
                ) : (
                    <p>Loading data...</p>
                )}
            </div>
        </div>
    );
}

export default App;
```

#### Nginx 설정 (고급)
```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend-service:3000 max_fails=3 fail_timeout=30s;
        server backend-service:3000 backup;
    }
    
    # 로드 밸런싱 설정
    upstream backend_weighted {
        server backend-service:3000 weight=3;
        server backend-service:3000 weight=1;
    }
    
    # 캐싱 설정
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m max_size=100m inactive=60m;
    
    server {
        listen 80;
        
        # 정적 파일 서빙
        location / {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /index.html;
            
            # 캐싱 헤더
            location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
        }
        
        # API 프록시 (캐싱 포함)
        location /api/ {
            proxy_pass http://backend/;
            proxy_cache api_cache;
            proxy_cache_valid 200 5m;
            proxy_cache_key "$scheme$request_method$host$request_uri";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # 타임아웃 설정
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }
        
        # 헬스체크 엔드포인트
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
        
        # 메트릭 엔드포인트 (모니터링용)
        location /nginx_status {
            stub_status on;
            access_log off;
            allow 10.0.0.0/8;
            deny all;
        }
    }
}
```

### 고급 배포 패턴

#### HorizontalPodAutoscaler (HPA)
```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-api
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

#### PodDisruptionBudget (PDB)
```yaml
# pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: backend-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: backend-api
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: frontend-pdb
spec:
  maxUnavailable: 50%
  selector:
    matchLabels:
      app: frontend-app
```

#### NetworkPolicy (보안)
```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-network-policy
spec:
  podSelector:
    matchLabels:
      app: mysql
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend-api
    ports:
    - protocol: TCP
      port: 3306
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-network-policy
spec:
  podSelector:
    matchLabels:
      app: backend-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend-app
    ports:
    - protocol: TCP
      port: 3000
```

---

## 🔧 유용한 명령어 모음

### 배포 관리

#### 롤링 업데이트
```bash
# 이미지 업데이트
kubectl set image deployment/backend-api backend=$ECR_REGISTRY/backend-api:v1.1.0

# 롤아웃 상태 확인
kubectl rollout status deployment/backend-api

# 롤아웃 히스토리
kubectl rollout history deployment/backend-api

# 롤백
kubectl rollout undo deployment/backend-api
kubectl rollout undo deployment/backend-api --to-revision=2
```

#### 스케일링
```bash
# 수동 스케일링
kubectl scale deployment backend-api --replicas=5

# 오토스케일링 설정
kubectl autoscale deployment backend-api --cpu-percent=70 --min=2 --max=10

# HPA 상태 확인
kubectl get hpa
kubectl describe hpa backend-api
```

### 모니터링 및 디버깅

#### 로그 확인
```bash
# 특정 Pod 로그
kubectl logs -f deployment/backend-api

# 모든 컨테이너 로그
kubectl logs -f deployment/backend-api --all-containers

# 이전 컨테이너 로그
kubectl logs deployment/backend-api --previous

# 여러 Pod 로그 동시 확인
kubectl logs -f -l app=backend-api
```

#### 리소스 모니터링
```bash
# 리소스 사용량 (metrics-server 필요)
kubectl top nodes
kubectl top pods
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory

# 리소스 상태 확인
kubectl describe nodes
kubectl describe pod POD_NAME
```

#### 네트워크 디버깅
```bash
# 서비스 엔드포인트 확인
kubectl get endpoints

# DNS 해석 테스트
kubectl run dns-test --image=busybox --rm -it --restart=Never \
    -- nslookup backend-service

# 포트 포워딩
kubectl port-forward service/backend-service 8080:3000

# 네트워크 정책 확인
kubectl get networkpolicies
kubectl describe networkpolicy database-network-policy
```

---

## 🚨 트러블슈팅 가이드

### ECR 관련 문제

#### 인증 문제
```bash
# 문제: docker login 실패
# 해결: ECR 로그인 토큰 갱신
aws ecr get-login-password --region $REGION | \
    docker login --username AWS --password-stdin $ECR_REGISTRY

# 문제: 토큰 만료
# 해결: 새 토큰 획득 (12시간마다 갱신 필요)
```

#### 권한 문제
```bash
# 문제: ECR 접근 권한 없음
# 해결: IAM 정책 확인
aws iam list-attached-user-policies --user-name YOUR_USERNAME
aws iam get-policy-version --policy-arn POLICY_ARN --version-id v1

# 필요한 ECR 권한
# - ecr:GetAuthorizationToken
# - ecr:BatchCheckLayerAvailability
# - ecr:GetDownloadUrlForLayer
# - ecr:BatchGetImage
# - ecr:PutImage
```

### 애플리케이션 배포 문제

#### 이미지 풀 실패
```bash
# 문제: ErrImagePull, ImagePullBackOff
# 해결: 이미지 URI 및 권한 확인
kubectl describe pod POD_NAME

# 노드 그룹 IAM 역할 확인
aws iam list-attached-role-policies \
    --role-name eksctl-CLUSTER-nodegroup-NODEGROUP-NodeInstanceRole
```

#### 서비스 연결 문제
```bash
# 문제: 서비스 간 통신 실패
# 해결: 서비스 및 엔드포인트 확인
kubectl get services
kubectl get endpoints
kubectl describe service SERVICE_NAME

# DNS 해석 테스트
kubectl run debug --image=busybox --rm -it --restart=Never \
    -- nslookup SERVICE_NAME.NAMESPACE.svc.cluster.local
```

#### 데이터베이스 연결 문제
```bash
# 문제: 데이터베이스 연결 실패
# 해결: 네트워크 및 인증 정보 확인
kubectl exec -it POD_NAME -- env | grep DB_

# 데이터베이스 직접 연결 테스트
kubectl run mysql-client --image=mysql:8.0 --rm -it --restart=Never \
    -- mysql -h mysql-service -u USERNAME -pPASSWORD -e "SELECT 1"
```

이 예제 모음을 통해 챌린저들이 ECR과 멀티 티어 애플리케이션 배포를 완벽하게 마스터할 수 있을 것입니다!
