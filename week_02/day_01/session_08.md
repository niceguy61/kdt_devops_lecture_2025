# Session 8: 환경 변수 및 볼륨 기초

## 📍 교과과정에서의 위치
이 세션은 **Week 2 > Day 1 > Session 8**로, Day 1의 마지막 세션입니다. 환경 변수와 볼륨의 기본 개념을 실습하고, Day 1에서 학습한 모든 내용을 종합 정리합니다.

## 학습 목표 (5분)
- **환경 변수**와 **볼륨**의 기본 개념 이해
- **데이터 영속성** 실습 및 **설정 관리** 체험
- **Day 1 전체 내용** 종합 정리

## 1. 이론: 환경 변수와 볼륨의 기본 개념 (20분)

### 환경 변수 활용 패턴

```mermaid
graph TB
    subgraph "환경 변수 사용 사례"
        A[애플리케이션 설정] --> B[데이터베이스 연결 정보]
        A --> C[API 키 및 시크릿]
        A --> D[환경별 설정 분리]
        A --> E[기능 플래그]
    end
    
    subgraph "설정 방법"
        F[-e 옵션] --> G[docker run -e KEY=VALUE]
        H[--env-file] --> I[파일에서 일괄 로드]
        J[Dockerfile ENV] --> K[이미지에 기본값 설정]
    end
```

### 볼륨 유형별 특징

```
Docker 볼륨 유형:

1. Named Volume (관리형 볼륨)
├── Docker가 관리하는 볼륨
├── /var/lib/docker/volumes/ 에 저장
├── 컨테이너 간 공유 가능
└── 백업 및 마이그레이션 용이

2. Bind Mount (바인드 마운트)
├── 호스트 경로를 직접 마운트
├── 호스트 파일시스템에 직접 접근
├── 개발 시 소스 코드 공유
└── 절대 경로 필요

3. tmpfs Mount (메모리 볼륨)
├── 메모리에만 저장
├── 컨테이너 종료 시 삭제
├── 임시 데이터 저장
└── 보안이 중요한 데이터
```

### 데이터 영속성 전략

```mermaid
flowchart TD
    A[데이터 유형] --> B{영속성 필요?}
    B -->|Yes| C[Named Volume]
    B -->|No| D[tmpfs Mount]
    C --> E{개발/운영?}
    E -->|개발| F[Bind Mount]
    E -->|운영| G[Named Volume]
    
    F --> H[소스 코드 공유]
    G --> I[데이터베이스 저장]
    D --> J[캐시, 임시 파일]
```

## 2. 실습: 환경 변수 활용 (12분)

### 기본 환경 변수 설정

```bash
# 단일 환경 변수 설정
docker run -d \
  -e MYSQL_ROOT_PASSWORD=mypassword \
  -e MYSQL_DATABASE=testdb \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppass \
  --name mysql-env mysql:8.0

# 환경 변수 확인
docker exec mysql-env env | grep MYSQL
docker exec mysql-env printenv MYSQL_ROOT_PASSWORD
```

### 환경 파일 사용

```bash
# 환경 변수 파일 생성
cat > app.env << EOF
NODE_ENV=production
PORT=3000
DATABASE_URL=mysql://user:pass@localhost:3306/mydb
API_KEY=your-secret-api-key
DEBUG=false
LOG_LEVEL=info
EOF

# 환경 파일로 컨테이너 실행
docker run -d \
  --env-file app.env \
  -p 3000:3000 \
  --name node-env node:16-alpine \
  sh -c 'while true; do echo "NODE_ENV: $NODE_ENV, PORT: $PORT"; sleep 10; done'

# 환경 변수 확인
docker logs node-env
docker exec node-env env | grep -E "(NODE_ENV|PORT|DATABASE_URL)"
```

### 환경별 설정 분리

```bash
# 개발 환경 설정
cat > dev.env << EOF
NODE_ENV=development
DEBUG=true
LOG_LEVEL=debug
DATABASE_URL=mysql://root:dev@localhost:3306/devdb
EOF

# 운영 환경 설정
cat > prod.env << EOF
NODE_ENV=production
DEBUG=false
LOG_LEVEL=error
DATABASE_URL=mysql://user:prod@db-server:3306/proddb
EOF

# 환경별 컨테이너 실행
docker run -d --env-file dev.env --name app-dev node:16-alpine sleep 3600
docker run -d --env-file prod.env --name app-prod node:16-alpine sleep 3600

# 환경별 설정 확인
docker exec app-dev printenv NODE_ENV
docker exec app-prod printenv NODE_ENV
```

## 3. 실습: 볼륨 기초 (13분)

### Named Volume 생성 및 사용

```bash
# 볼륨 생성
docker volume create my-data
docker volume create web-content
docker volume create db-data

# 볼륨 목록 확인
docker volume ls

# 볼륨 상세 정보
docker volume inspect my-data

# 볼륨을 사용하는 컨테이너 실행
docker run -d \
  -v my-data:/data \
  --name data-container alpine:latest \
  sh -c 'echo "Hello Volume" > /data/hello.txt && sleep 3600'

# 볼륨 내용 확인
docker exec data-container cat /data/hello.txt
docker exec data-container ls -la /data/
```

### Bind Mount 실습

```bash
# 호스트 디렉토리 준비
mkdir -p ./host-data
echo "Host file content" > ./host-data/host-file.txt

# Bind Mount로 컨테이너 실행
docker run -d \
  -v $(pwd)/host-data:/container-data \
  --name bind-container alpine:latest \
  sleep 3600

# 양방향 파일 공유 확인
docker exec bind-container ls -la /container-data/
docker exec bind-container cat /container-data/host-file.txt

# 컨테이너에서 파일 생성
docker exec bind-container sh -c 'echo "Container file" > /container-data/container-file.txt'

# 호스트에서 확인
ls -la ./host-data/
cat ./host-data/container-file.txt
```

### 볼륨 공유 실습

```bash
# 첫 번째 컨테이너에서 데이터 생성
docker run -d \
  -v shared-volume:/shared \
  --name writer alpine:latest \
  sh -c 'for i in $(seq 1 10); do echo "Message $i" >> /shared/messages.txt; sleep 2; done'

# 두 번째 컨테이너에서 데이터 읽기
docker run -d \
  -v shared-volume:/shared \
  --name reader alpine:latest \
  sh -c 'while true; do echo "=== Reading ==="; cat /shared/messages.txt 2>/dev/null || echo "No file yet"; sleep 5; done'

# 실시간 로그 확인
docker logs -f reader &
docker logs -f writer &

# 잠시 후 백그라운드 작업 종료
# jobs
# kill %1 %2
```

## 4. 실습: 데이터베이스 영속성 (10분)

### MySQL 데이터 영속성

```bash
# 볼륨을 사용한 MySQL 컨테이너
docker run -d \
  -e MYSQL_ROOT_PASSWORD=mypassword \
  -e MYSQL_DATABASE=persistent_db \
  -v mysql-data:/var/lib/mysql \
  -p 3306:3306 \
  --name mysql-persistent mysql:8.0

# 데이터베이스에 데이터 추가
docker exec -it mysql-persistent mysql -u root -p << EOF
mypassword
USE persistent_db;
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50), email VARCHAR(100));
INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com');
INSERT INTO users (name, email) VALUES ('Jane Smith', 'jane@example.com');
SELECT * FROM users;
EXIT;
EOF
```

### 컨테이너 재생성 후 데이터 확인

```bash
# 컨테이너 중지 및 삭제
docker stop mysql-persistent
docker rm mysql-persistent

# 동일한 볼륨으로 새 컨테이너 생성
docker run -d \
  -e MYSQL_ROOT_PASSWORD=mypassword \
  -v mysql-data:/var/lib/mysql \
  -p 3306:3306 \
  --name mysql-restored mysql:8.0

# 데이터 복구 확인 (잠시 대기 후)
sleep 10
docker exec -it mysql-restored mysql -u root -p << EOF
mypassword
USE persistent_db;
SELECT * FROM users;
EXIT;
EOF
```

### 볼륨 백업 및 복원

```bash
# 볼륨 백업 (tar 파일로)
docker run --rm \
  -v mysql-data:/data \
  -v $(pwd):/backup \
  alpine:latest \
  tar czf /backup/mysql-backup.tar.gz -C /data .

# 백업 파일 확인
ls -la mysql-backup.tar.gz

# 새 볼륨에 복원
docker volume create mysql-data-restored
docker run --rm \
  -v mysql-data-restored:/data \
  -v $(pwd):/backup \
  alpine:latest \
  tar xzf /backup/mysql-backup.tar.gz -C /data
```

## 5. Day 1 종합 정리 및 실습 (15분)

### 종합 실습: 완전한 웹 애플리케이션 스택

```bash
# 1. 데이터베이스 컨테이너 (영속성 포함)
docker run -d \
  --name app-database \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=webapp \
  -e MYSQL_USER=webuser \
  -e MYSQL_PASSWORD=webpass \
  -v webapp-db:/var/lib/mysql \
  mysql:8.0

# 2. 웹 서버 컨테이너 (설정 파일 마운트)
mkdir -p ./web-config
cat > ./web-config/nginx.conf << EOF
server {
    listen 80;
    server_name localhost;
    
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
    
    location /api/ {
        proxy_pass http://app-backend:3000/;
    }
}
EOF

docker run -d \
  --name app-webserver \
  -p 8080:80 \
  -v ./web-config/nginx.conf:/etc/nginx/conf.d/default.conf \
  -v webapp-content:/usr/share/nginx/html \
  nginx:latest

# 3. 애플리케이션 컨테이너 (환경 변수 사용)
cat > app-backend.env << EOF
NODE_ENV=production
PORT=3000
DB_HOST=app-database
DB_USER=webuser
DB_PASSWORD=webpass
DB_NAME=webapp
EOF

docker run -d \
  --name app-backend \
  --env-file app-backend.env \
  --link app-database:database \
  node:16-alpine \
  sh -c 'echo "Backend running on port 3000" && sleep 3600'
```

### Day 1 학습 내용 체크리스트

```bash
# 설치 및 환경 구성 ✅
docker --version
docker system info

# 기본 명령어 ✅
docker images
docker ps -a
docker logs app-webserver

# 컨테이너 관리 ✅
docker stop app-backend
docker start app-backend
docker restart app-webserver

# 내부 접근 ✅
docker exec -it app-webserver /bin/bash
# exit

# 포트 매핑 ✅
curl http://localhost:8080

# 환경 변수 ✅
docker exec app-backend printenv NODE_ENV

# 볼륨 ✅
docker volume ls
docker exec app-webserver ls -la /usr/share/nginx/html/
```

### 문제 해결 및 정리

```bash
# 리소스 사용량 확인
docker stats --no-stream

# 시스템 정보 확인
docker system df

# 불필요한 리소스 정리
docker container prune -f
docker volume prune -f
docker image prune -f

# 학습용 컨테이너 모두 정리 (선택사항)
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
```

## 6. Q&A 및 다음 날 준비 (5분)

### Day 1 핵심 성과 정리
- ✅ Docker 설치 및 환경 구성 완료
- ✅ 기본 명령어 10개 이상 실습
- ✅ 컨테이너 라이프사이클 완전 이해
- ✅ 포트 매핑으로 외부 접근 설정
- ✅ 환경 변수와 볼륨 기초 활용

### Day 2 준비사항
```bash
# 텍스트 에디터 준비 (VS Code 권장)
code --version

# Git 설치 확인
git --version

# 실습용 디렉토리 정리
mkdir -p ~/docker-practice/day2
cd ~/docker-practice/day2
```

### 과제 및 복습
1. **개인 실습**: 오늘 배운 명령어로 간단한 블로그 사이트 컨테이너 구성
2. **환경 정리**: 불필요한 컨테이너 및 이미지 정리
3. **개념 복습**: Week 1 이론과 Day 1 실습 연결점 정리

## 💡 핵심 키워드
- **환경 변수**: -e 옵션, --env-file, 설정 외부화
- **볼륨**: Named Volume, Bind Mount, 데이터 영속성
- **데이터 관리**: 백업, 복원, 컨테이너 간 공유
- **종합 활용**: 다중 컨테이너 애플리케이션 구성

## 📚 참고 자료
- [Docker 환경 변수 가이드](https://docs.docker.com/engine/reference/run/#env-environment-variables)
- [Docker 볼륨 관리](https://docs.docker.com/storage/volumes/)
- [Docker Compose 준비](https://docs.docker.com/compose/)

## 🔧 실습 체크리스트
- [ ] 환경 변수로 애플리케이션 설정
- [ ] 환경 파일을 사용한 일괄 설정
- [ ] Named Volume으로 데이터 영속성 구현
- [ ] Bind Mount로 호스트-컨테이너 파일 공유
- [ ] 다중 컨테이너 애플리케이션 구성
