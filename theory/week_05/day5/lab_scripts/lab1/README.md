# CloudMart 샘플 애플리케이션

Week 5 Day 5 실습을 위한 즉시 사용 가능한 샘플 앱입니다.

## 🎯 기술 스택

- **Frontend**: HTML5 + Vanilla JavaScript
- **Backend**: Node.js 22 + Express
- **Database**: PostgreSQL 16
- **Cache**: Redis 7
- **Deployment**: AWS (EC2, RDS, ElastiCache, S3, CloudFront)

## 📁 구조

```
sample_app/
├── frontend/
│   └── index.html          # 정적 HTML (S3 + CloudFront)
├── backend/
│   ├── server.js           # Express API 서버
│   ├── package.json        # Node.js 의존성
│   └── Dockerfile          # Docker 이미지
└── database/
    └── init.sql            # PostgreSQL 초기화 스크립트
```

## 🚀 로컬 테스트

### 1. Docker Compose로 실행

```bash
cd sample_app

# Docker Compose 파일 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: cloudmart
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
  
  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://postgres:password@postgres:5432/cloudmart
      REDIS_URL: redis://redis:6379
      NODE_ENV: development
    ports:
      - "8080:8080"
    depends_on:
      - postgres
      - redis
EOF

# 실행
docker-compose up -d

# 확인
curl http://localhost:8080/health
curl http://localhost:8080/api/products
```

### 2. Frontend 테스트

```bash
# 간단한 HTTP 서버로 실행
cd frontend
python3 -m http.server 3000

# 브라우저에서 접속
open http://localhost:3000
```

## 📦 AWS 배포

### Backend Docker 이미지 빌드

```bash
cd backend

# 이미지 빌드
docker build -t cloudmart-backend:latest .

# ECR에 푸시 (선택사항)
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-northeast-2.amazonaws.com
docker tag cloudmart-backend:latest <account-id>.dkr.ecr.ap-northeast-2.amazonaws.com/cloudmart-backend:latest
docker push <account-id>.dkr.ecr.ap-northeast-2.amazonaws.com/cloudmart-backend:latest
```

### RDS 초기화

```bash
# RDS 엔드포인트로 연결
psql -h <RDS-ENDPOINT> -U postgres -d cloudmart

# init.sql 실행
\i database/init.sql

# 확인
SELECT COUNT(*) FROM products;
```

### EC2 User Data

```bash
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

# Backend 컨테이너 실행
docker run -d \
  -p 8080:8080 \
  -e DATABASE_URL="postgresql://postgres:password@<RDS-ENDPOINT>:5432/cloudmart" \
  -e REDIS_URL="redis://<REDIS-ENDPOINT>:6379" \
  -e NODE_ENV="production" \
  --restart unless-stopped \
  cloudmart-backend:latest
```

### S3 Frontend 배포

```bash
# S3 버킷에 업로드
aws s3 cp frontend/index.html s3://cloudmart-frontend-<unique-id>/

# 퍼블릭 읽기 권한 (버킷 정책)
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::cloudmart-frontend-<unique-id>/*"
    }
  ]
}
```

## 🔍 API 엔드포인트

### Health Check
```bash
GET /health
```

### 상품 목록 (캐싱 적용)
```bash
GET /api/products
```

### 상품 상세
```bash
GET /api/products/:id
```

### 상품 생성
```bash
POST /api/products
Content-Type: application/json

{
  "name": "New Product",
  "description": "Product description",
  "price": 99.99,
  "stock": 50
}
```

### 통계
```bash
GET /api/stats
```

## 📊 샘플 데이터

- **총 20개 상품**
- **6개 카테고리**: Electronics, Audio, Home Entertainment, Accessories, Cameras, Gaming
- **총 재고 가치**: ~$30,000

## 🎨 주요 기능

1. **Redis 캐싱**: 상품 목록 10분 캐싱
2. **PostgreSQL 16**: 최신 기능 활용 (트리거, 뷰)
3. **Graceful Shutdown**: SIGTERM 처리
4. **Health Check**: 모니터링용 엔드포인트
5. **CORS 지원**: Frontend 연동

## 🔧 환경 변수

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `DATABASE_URL` | PostgreSQL 연결 문자열 | `postgresql://postgres:password@localhost:5432/cloudmart` |
| `REDIS_URL` | Redis 연결 문자열 | `redis://localhost:6379` |
| `NODE_ENV` | 환경 (development/production) | `development` |
| `PORT` | 서버 포트 | `8080` |

## 📝 주의사항

1. **프로덕션 배포 시**:
   - 환경 변수로 비밀번호 관리 (Secrets Manager 권장)
   - SSL/TLS 연결 활성화
   - 보안 그룹 최소 권한 설정

2. **Frontend API URL 수정**:
   - `index.html`의 `API_URL` 변수를 ALB DNS로 변경

3. **비용 관리**:
   - 실습 후 즉시 리소스 정리
   - 프리티어 한도 확인

## 🎯 Week 5 Day 5 실습 연계

이 샘플 앱은 다음 실습에서 사용됩니다:

- **Lab 1**: CloudMart 인프라 구축
- **Challenge**: 프로덕션급 배포

모든 코드는 즉시 사용 가능하며, 추가 개발 없이 AWS 배포 실습에 집중할 수 있습니다.
