# CloudMart 샘플 앱 사용 가이드

## 🖥️ Windows 사용자를 위한 WSL 설정

### WSL 설치 (Windows 10/11)

**PowerShell 관리자 권한으로 실행**:
```powershell
# WSL 설치
wsl --install

# 재부팅 후 Ubuntu 설치 확인
wsl --list --verbose
```

### WSL에서 샘플 앱 사용

**1. Windows 파일 시스템 접근**:
```bash
# WSL에서 Windows 다운로드 폴더 접근
cd /mnt/c/Users/<사용자명>/Downloads

# 압축 해제
tar -xzf cloudmart-sample-app.tar.gz

# 작업 디렉토리로 이동
cd cloudmart-sample-app
```

**2. Docker Desktop 연동**:
```bash
# WSL에서 Docker 사용 가능 확인
docker --version
docker ps

# Docker Desktop 설정에서 "Use WSL 2 based engine" 활성화 필요
```

**3. 파일 편집**:
```bash
# WSL에서 VS Code 실행
code .

# 또는 Windows 탐색기에서 접근
# \\wsl$\Ubuntu\home\<사용자명>\cloudmart-sample-app
```

---

## 📦 다운로드

### 방법 1: tar.gz 파일 다운로드 (권장)

```bash
# Day 5 디렉토리로 이동
cd theory/week_05/day5

# 압축 해제
tar -xzf cloudmart-sample-app.tar.gz

# 디렉토리 확인
cd sample_app
ls -la
```

### 방법 2: 직접 복사

```bash
# 전체 sample_app 폴더를 작업 디렉토리로 복사
cp -r theory/week_05/day5/sample_app ~/cloudmart-app
cd ~/cloudmart-app
```

---

## ✅ 사전 테스트 완료 (2025-10-30)

### 테스트 환경
- **OS**: Linux (WSL2)
- **Docker**: 27.x
- **Node.js**: 22.x
- **PostgreSQL**: 16-alpine
- **Redis**: 7-alpine

### 테스트 결과

| 항목 | 상태 | 세부 내용 |
|------|------|----------|
| **PostgreSQL 초기화** | ✅ | 20개 상품, 6개 카테고리 |
| **Redis 캐싱** | ✅ | Database → Cache 전환 확인 |
| **Health Check** | ✅ | `/health` 정상 응답 |
| **상품 목록 API** | ✅ | 20개 상품 반환 |
| **상품 조회 API** | ✅ | ID로 조회 성공 |
| **상품 생성 API** | ✅ | POST 성공 + 캐시 무효화 |
| **통계 API** | ✅ | 총 재고 가치 $452,919.50 |
| **PostgreSQL 뷰** | ✅ | 카테고리별 통계 정상 |

---

## 🚀 로컬 실행 (Lab 전 테스트)

### 1. Docker Compose로 전체 스택 실행

```bash
cd sample_app

# 컨테이너 실행
docker-compose up -d

# 상태 확인 (모두 healthy 될 때까지 대기)
docker ps --filter "name=cloudmart"

# 로그 확인
docker-compose logs -f
```

### 2. API 테스트

```bash
# Health Check
curl http://localhost:8080/health

# 상품 목록 (첫 호출 - Database)
curl http://localhost:8080/api/products | jq '{source: .source, count: (.data | length)}'

# 상품 목록 (두 번째 호출 - Cache)
curl http://localhost:8080/api/products | jq '{source: .source, count: (.data | length)}'

# 통계
curl http://localhost:8080/api/stats | jq .

# 특정 상품 조회
curl http://localhost:8080/api/products/1 | jq .
```

### 3. Frontend 테스트 (선택)

```bash
# 간단한 HTTP 서버로 실행
cd frontend
python3 -m http.server 3000

# 브라우저에서 접속
# http://localhost:3000
```

**주의**: Frontend의 `API_URL`을 `http://localhost:8080`으로 설정되어 있어야 합니다.

### 4. 정리

```bash
# 컨테이너 중지 및 삭제
docker-compose down

# 볼륨까지 삭제 (데이터 초기화)
docker-compose down -v
```

---

## 📋 Lab 1 사용 방법

### Step 2: RDS 초기화

```bash
# RDS 엔드포인트 확인 후
psql -h <RDS-ENDPOINT> -U postgres -d cloudmart -f database/init.sql

# 확인
psql -h <RDS-ENDPOINT> -U postgres -d cloudmart -c "SELECT COUNT(*) FROM products;"
# 결과: 20
```

### Step 4: Backend 배포

**EC2 User Data**:
```bash
#!/bin/bash
yum update -y
yum install -y docker git
systemctl start docker
systemctl enable docker

# 샘플 앱 다운로드
cd /home/ec2-user
git clone <repository-url>
cd sample_app/backend

# Docker 이미지 빌드
docker build -t cloudmart-backend:latest .

# 컨테이너 실행
docker run -d \
  -p 8080:8080 \
  -e DATABASE_URL="postgresql://postgres:<password>@<RDS-ENDPOINT>:5432/cloudmart" \
  -e REDIS_URL="redis://<REDIS-ENDPOINT>:6379" \
  -e NODE_ENV="production" \
  --restart unless-stopped \
  cloudmart-backend:latest
```

### Step 5: Frontend 배포

```bash
# S3 버킷에 업로드
aws s3 cp frontend/index.html s3://cloudmart-frontend-<unique-id>/

# 또는 AWS Console에서 직접 업로드
```

**주의**: `index.html`의 `API_URL`을 ALB DNS로 수정 필요:
```javascript
const API_URL = 'http://<ALB-DNS>';
```

---

## 🎯 Challenge 사용 방법

Challenge에서는 Lab 1과 동일한 앱을 사용하되, 다음을 추가:

1. **CloudWatch 대시보드**: Backend 메트릭 시각화
2. **CloudWatch 알람**: CPU, 응답 시간, 에러율
3. **RDS 백업**: 자동 백업 + 수동 스냅샷
4. **보안 강화**: IAM Role, 암호화, CloudTrail

---

## 📊 샘플 데이터 상세

### 카테고리별 상품 (20개)

**Electronics (5개)**:
- MacBook Pro 16" - $3,499.99
- iPhone 15 Pro - $1,199.99
- AirPods Pro - $249.99
- iPad Air - $749.99
- Apple Watch Ultra 2 - $799.99

**Audio (3개)**:
- Sony WH-1000XM5 - $399.99
- Bose QuietComfort - $299.99
- JBL Flip 6 - $129.99

**Home Entertainment (2개)**:
- Samsung 55" OLED TV - $1,499.99
- LG Soundbar - $699.99

**Accessories (4개)**:
- Logitech MX Master 3S - $99.99
- Keychron K8 Pro - $109.99
- Dell UltraSharp 27" - $549.99
- Anker PowerCore - $49.99

**Cameras (3개)**:
- Canon EOS R6 - $2,499.99
- Sony A7 IV - $2,499.99
- DJI Mini 3 Pro - $759.99

**Gaming (3개)**:
- Nintendo Switch OLED - $349.99
- PlayStation 5 - $499.99
- Xbox Series X - $499.99

**총 재고 가치**: $452,919.50

---

## 🔧 커스터마이징

### 상품 추가

```sql
-- RDS에서 직접 실행
INSERT INTO products (name, description, price, stock, category, image_url) 
VALUES ('New Product', 'Description', 99.99, 50, 'Electronics', 'https://via.placeholder.com/300');
```

### 환경 변수 변경

```bash
# Backend 컨테이너 재시작 시
docker run -d \
  -e DATABASE_URL="<new-url>" \
  -e REDIS_URL="<new-url>" \
  cloudmart-backend:latest
```

---

## ⚠️ 주의사항

### 프로덕션 배포 시

1. **비밀번호 변경**: 
   - PostgreSQL 비밀번호를 강력하게 변경
   - AWS Secrets Manager 사용 권장

2. **Frontend API URL**:
   - `index.html`의 `API_URL`을 ALB DNS로 수정
   - 또는 환경 변수로 주입

3. **CORS 설정**:
   - Backend의 CORS를 프로덕션 도메인으로 제한

4. **보안 그룹**:
   - RDS는 Backend SG에서만 접근
   - Redis는 Backend SG에서만 접근
   - Backend는 ALB SG에서만 접근

---

## 🎓 학습 포인트

이 샘플 앱을 통해 학습할 수 있는 것:

1. **Multi-tier 아키텍처**: Frontend - Backend - Database - Cache
2. **캐싱 전략**: Cache-Aside 패턴 구현
3. **API 설계**: RESTful API 엔드포인트
4. **데이터베이스**: PostgreSQL 뷰, 트리거 활용
5. **컨테이너화**: Docker 이미지 빌드 및 배포
6. **AWS 통합**: RDS, ElastiCache, EC2, S3, CloudFront

---

<div align="center">

**✅ 테스트 완료** • **📦 배포 준비 완료** • **🚀 즉시 사용 가능**

*Week 5 Day 5 Lab & Challenge에서 사용하세요!*

</div>
