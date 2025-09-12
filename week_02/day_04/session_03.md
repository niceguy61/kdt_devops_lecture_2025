# Session 3: 볼륨과 환경 변수 관리

## 📍 교과과정에서의 위치
이 세션은 **Week 2 > Day 4 > Session 3**으로, Session 2의 서비스 네트워킹을 바탕으로 데이터 영속성과 설정 관리를 학습합니다.

## 학습 목표 (5분)
- **Compose 볼륨** 관리 및 **데이터 영속성** 보장
- **환경 변수** 및 **설정 파일** 외부화 전략
- **시크릿 관리** 및 **보안** 모범 사례

## 1. 이론: 데이터와 설정 관리 (20분)

### 볼륨 관리 전략

```yaml
# Named Volume
services:
  db:
    image: postgres
    volumes:
      - db_data:/var/lib/postgresql/data
volumes:
  db_data:

# Bind Mount
services:
  web:
    image: nginx
    volumes:
      - ./config:/etc/nginx/conf.d:ro
      - ./logs:/var/log/nginx

# tmpfs Mount
services:
  cache:
    image: redis
    tmpfs:
      - /tmp:rw,size=100m
```

### 환경 변수 관리 패턴

```yaml
# 직접 정의
services:
  app:
    image: myapp
    environment:
      - NODE_ENV=production
      - DB_HOST=database

# .env 파일 사용
services:
  app:
    image: myapp
    env_file:
      - .env
      - .env.local

# 환경별 파일
services:
  app:
    image: myapp
    env_file:
      - .env.${ENVIRONMENT:-development}
```

## 2. 실습: 볼륨 관리 구현 (15분)

### 데이터 영속성 설정

```bash
mkdir -p volume-demo && cd volume-demo

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # 웹 애플리케이션
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./web-content:/usr/share/nginx/html:ro
      - ./nginx-config:/etc/nginx/conf.d:ro
      - web-logs:/var/log/nginx
    depends_on:
      - api

  # API 서버
  api:
    build: ./api
    volumes:
      - ./api:/app
      - /app/node_modules
      - api-uploads:/app/uploads
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    depends_on:
      - postgres
      - redis

  # PostgreSQL 데이터베이스
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./db-init:/docker-entrypoint-initdb.d:ro
      - ./db-backup:/backup

  # Redis 캐시
  redis:
    image: redis:alpine
    volumes:
      - redis-data:/data
    command: redis-server --appendonly yes

  # 백업 서비스
  backup:
    image: postgres:13
    volumes:
      - postgres-data:/source:ro
      - ./backups:/backup
    command: >
      sh -c "
        while true; do
          pg_dump -h postgres -U user -d appdb > /backup/backup-$$(date +%Y%m%d-%H%M%S).sql
          sleep 3600
        done
      "
    depends_on:
      - postgres

volumes:
  postgres-data:
    driver: local
  redis-data:
    driver: local
  web-logs:
    driver: local
  api-uploads:
    driver: local
EOF

# 디렉토리 구조 생성
mkdir -p {web-content,nginx-config,api,db-init,backups}
```

### 설정 파일 외부화

```bash
# Nginx 설정
cat > nginx-config/default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    # 로그 설정
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
    
    location /api/ {
        proxy_pass http://api:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # 파일 업로드
    location /uploads/ {
        alias /app/uploads/;
    }
}
EOF

# 웹 콘텐츠
cat > web-content/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>볼륨 관리 데모</title>
</head>
<body>
    <h1>Docker Compose 볼륨 관리</h1>
    <p>이 파일은 바인드 마운트로 관리됩니다.</p>
    <button onclick="testAPI()">API 테스트</button>
    <div id="result"></div>
    
    <script>
        async function testAPI() {
            const response = await fetch('/api/data');
            const data = await response.json();
            document.getElementById('result').innerHTML = JSON.stringify(data, null, 2);
        }
    </script>
</body>
</html>
EOF

# API 서버
cat > api/package.json << 'EOF'
{
  "name": "volume-api",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2",
    "multer": "^1.4.5",
    "pg": "^8.8.0",
    "redis": "^4.5.0"
  }
}
EOF

cat > api/server.js << 'EOF'
const express = require('express');
const multer = require('multer');
const { Client } = require('pg');
const redis = require('redis');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(express.json());

// 업로드 디렉토리 확인
const uploadDir = '/app/uploads';
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// 파일 업로드 설정
const upload = multer({ dest: uploadDir });

// 데이터베이스 연결
const db = new Client({
    host: process.env.DB_HOST,
    database: 'appdb',
    user: 'user',
    password: 'password'
});

// Redis 연결
const redisClient = redis.createClient({
    host: process.env.REDIS_HOST
});

db.connect().catch(console.error);
redisClient.connect().catch(console.error);

app.get('/data', async (req, res) => {
    try {
        // 캐시 확인
        const cached = await redisClient.get('app_data');
        if (cached) {
            return res.json({ source: 'cache', data: JSON.parse(cached) });
        }
        
        // 데이터베이스 조회
        const result = await db.query('SELECT NOW() as timestamp, \'Hello from DB\' as message');
        const data = result.rows[0];
        
        // 캐시 저장
        await redisClient.setEx('app_data', 60, JSON.stringify(data));
        
        res.json({ source: 'database', data });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/upload', upload.single('file'), (req, res) => {
    res.json({
        message: 'File uploaded successfully',
        filename: req.file.filename,
        path: `/uploads/${req.file.filename}`
    });
});

app.listen(3000, '0.0.0.0', () => {
    console.log('API server running on port 3000');
});
EOF

cat > api/Dockerfile << 'EOF'
FROM node:alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
EOF

# 데이터베이스 초기화
cat > db-init/init.sql << 'EOF'
CREATE TABLE IF NOT EXISTS app_data (
    id SERIAL PRIMARY KEY,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO app_data (message) VALUES 
('Initial data from volume'),
('Persistent data example');
EOF
```

## 3. 실습: 환경 변수 관리 (15분)

### 환경별 설정 파일

```bash
# 기본 환경 변수
cat > .env << 'EOF'
# 기본 설정
COMPOSE_PROJECT_NAME=volume-demo
NODE_ENV=development
LOG_LEVEL=debug

# 데이터베이스 설정
POSTGRES_DB=appdb
POSTGRES_USER=user
POSTGRES_PASSWORD=password

# Redis 설정
REDIS_PASSWORD=

# 애플리케이션 설정
API_PORT=3000
WEB_PORT=8080
EOF

# 개발 환경
cat > .env.development << 'EOF'
NODE_ENV=development
LOG_LEVEL=debug
DB_POOL_SIZE=5
REDIS_TTL=60
BACKUP_ENABLED=false
EOF

# 프로덕션 환경
cat > .env.production << 'EOF'
NODE_ENV=production
LOG_LEVEL=info
DB_POOL_SIZE=20
REDIS_TTL=3600
BACKUP_ENABLED=true
POSTGRES_PASSWORD=super_secure_password
EOF

# 환경별 Compose 파일
cat > docker-compose.override.yml << 'EOF'
version: '3.8'

services:
  api:
    env_file:
      - .env
      - .env.${NODE_ENV:-development}
    environment:
      - DEBUG=true
    volumes:
      - ./api:/app
      - /app/node_modules

  postgres:
    env_file:
      - .env
    ports:
      - "5432:5432"  # 개발 환경에서만 포트 노출

  redis:
    ports:
      - "6379:6379"  # 개발 환경에서만 포트 노출
EOF

# 프로덕션용 Compose 파일
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  api:
    env_file:
      - .env
      - .env.production
    environment:
      - DEBUG=false
    # 프로덕션에서는 소스 마운트 제거

  postgres:
    env_file:
      - .env.production
    # 프로덕션에서는 포트 노출 안함

  redis:
    command: redis-server --requirepass ${REDIS_PASSWORD}
    # 프로덕션에서는 포트 노출 안함

  # 프로덕션 전용 서비스
  monitoring:
    image: prom/prometheus
    volumes:
      - ./monitoring:/etc/prometheus
    ports:
      - "9090:9090"
EOF
```

### 시크릿 관리

```bash
# 시크릿 파일 생성 (실제로는 안전한 곳에 저장)
mkdir -p secrets
echo "super_secret_db_password" > secrets/db_password.txt
echo "redis_auth_token_12345" > secrets/redis_password.txt
echo "jwt_secret_key_abcdef" > secrets/jwt_secret.txt

# 시크릿을 사용하는 Compose 파일
cat > docker-compose.secrets.yml << 'EOF'
version: '3.8'

services:
  api:
    image: node:alpine
    secrets:
      - db_password
      - jwt_secret
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password
      - JWT_SECRET_FILE=/run/secrets/jwt_secret
    command: >
      sh -c "
        export DB_PASSWORD=$$(cat /run/secrets/db_password)
        export JWT_SECRET=$$(cat /run/secrets/jwt_secret)
        node server.js
      "

  postgres:
    image: postgres:13
    secrets:
      - db_password
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt
EOF

# 환경 변수 검증 스크립트
cat > validate-env.sh << 'EOF'
#!/bin/bash

echo "=== 환경 변수 검증 ==="

# 필수 환경 변수 체크
required_vars=("POSTGRES_DB" "POSTGRES_USER" "NODE_ENV")

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ $var is not set"
        exit 1
    else
        echo "✅ $var = ${!var}"
    fi
done

# 환경별 설정 확인
echo ""
echo "현재 환경: ${NODE_ENV:-development}"
echo "로그 레벨: ${LOG_LEVEL:-info}"
echo "백업 활성화: ${BACKUP_ENABLED:-false}"

# 보안 검증
if [ "$NODE_ENV" = "production" ]; then
    if [ "$POSTGRES_PASSWORD" = "password" ]; then
        echo "⚠️  프로덕션에서 기본 패스워드 사용 중!"
    fi
fi
EOF

chmod +x validate-env.sh
```

## 4. 실습: 데이터 백업 및 복원 (10분)

### 자동 백업 시스템

```bash
# 백업 스크립트
cat > backup-script.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d-%H%M%S)

echo "Starting backup at $DATE"

# PostgreSQL 백업
pg_dump -h postgres -U user -d appdb > "$BACKUP_DIR/postgres-$DATE.sql"

# Redis 백업
redis-cli -h redis --rdb "$BACKUP_DIR/redis-$DATE.rdb"

# 볼륨 백업
tar -czf "$BACKUP_DIR/volumes-$DATE.tar.gz" /source

# 오래된 백업 정리 (7일 이상)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.rdb" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

# 백업 서비스 추가
cat >> docker-compose.yml << 'EOF'

  # 백업 서비스
  backup-service:
    image: postgres:13
    volumes:
      - postgres-data:/source:ro
      - redis-data:/redis-source:ro
      - ./backups:/backup
      - ./backup-script.sh:/backup-script.sh:ro
    environment:
      - PGPASSWORD=password
    command: >
      sh -c "
        apk add --no-cache redis
        while true; do
          /backup-script.sh
          sleep 3600
        done
      "
    depends_on:
      - postgres
      - redis
EOF

# 복원 스크립트
cat > restore-script.sh << 'EOF'
#!/bin/bash

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    echo "Available backups:"
    ls -la ./backups/
    exit 1
fi

echo "Restoring from $BACKUP_FILE"

# 서비스 중지
docker-compose stop postgres redis

# 볼륨 정리
docker-compose down -v

# 새 볼륨으로 서비스 시작
docker-compose up -d postgres redis

# 백업 복원 대기
sleep 10

# PostgreSQL 복원
if [[ $BACKUP_FILE == *.sql ]]; then
    docker-compose exec -T postgres psql -U user -d appdb < "./backups/$BACKUP_FILE"
fi

echo "Restore completed"
EOF

chmod +x restore-script.sh
```

## 5. Q&A 및 정리 (5분)

### 볼륨 및 환경 관리 검증

```bash
# 전체 시스템 실행
docker-compose up -d

# 볼륨 상태 확인
echo "=== 볼륨 상태 ==="
docker volume ls | grep volume-demo
docker-compose exec postgres df -h /var/lib/postgresql/data
docker-compose exec redis redis-cli info persistence

# 환경 변수 확인
echo "=== 환경 변수 ==="
docker-compose exec api printenv | grep -E "(NODE_ENV|DB_HOST|REDIS_HOST)"

# 데이터 영속성 테스트
echo "=== 데이터 영속성 테스트 ==="
curl -s http://localhost:8080/api/data | jq

# 컨테이너 재시작 후 데이터 확인
docker-compose restart postgres redis
sleep 10
curl -s http://localhost:8080/api/data | jq

# 정리
cat > session3-summary.md << 'EOF'
# Session 3 요약: 볼륨과 환경 변수 관리

## 구현한 기능
1. **Named Volume**: 데이터베이스 데이터 영속성
2. **Bind Mount**: 설정 파일 외부화
3. **환경 변수**: 환경별 설정 관리
4. **시크릿 관리**: 민감한 정보 보호
5. **자동 백업**: 데이터 보호 및 복원

## 볼륨 전략
- **데이터베이스**: Named Volume (영속성)
- **설정 파일**: Bind Mount (수정 가능)
- **로그**: Named Volume (수집 및 분석)
- **업로드**: Named Volume (파일 저장)

## 환경 관리
- **.env**: 기본 설정
- **.env.{environment}**: 환경별 설정
- **docker-compose.override.yml**: 개발 환경
- **docker-compose.prod.yml**: 프로덕션 환경

## 보안 고려사항
- 시크릿 파일 분리
- 환경별 패스워드 관리
- 프로덕션 포트 노출 제한
- 백업 데이터 암호화
EOF

echo "Session 3 완료! 요약: session3-summary.md"
```

## 💡 핵심 키워드
- **데이터 영속성**: Named Volume, 백업/복원
- **설정 외부화**: 환경 변수, .env 파일
- **시크릿 관리**: 민감한 정보 보호
- **환경 분리**: 개발/스테이징/프로덕션

## 📚 참고 자료
- [Compose 볼륨](https://docs.docker.com/compose/compose-file/#volumes)
- [환경 변수](https://docs.docker.com/compose/environment-variables/)
- [시크릿 관리](https://docs.docker.com/compose/compose-file/#secrets)

## 🔧 실습 체크리스트
- [ ] Named Volume 데이터 영속성 구현
- [ ] Bind Mount 설정 파일 외부화
- [ ] 환경별 설정 관리 체계 구축
- [ ] 시크릿 관리 시스템 적용
- [ ] 자동 백업 및 복원 시스템 구현
