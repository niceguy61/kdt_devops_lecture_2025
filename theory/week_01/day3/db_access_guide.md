# 🗄️ Docker DB 접근 완전 가이드

<div align="center">

**💾 데이터베이스 컨테이너** • **🌐 크로스 플랫폼 접근**

*OS 상관없이 Docker DB에 접근하는 모든 방법*

</div>

---

## 🎯 접근 방법 개요

### 📊 접근 방법 비교
| 방법 | 난이도 | OS 호환성 | 추천도 | 용도 |
|------|--------|-----------|--------|------|
| **Docker exec** | ⭐⭐ | ✅ 모든 OS | ⭐⭐⭐⭐⭐ | 빠른 확인, 스크립트 |
| **네이티브 클라이언트** | ⭐⭐⭐ | ⚠️ OS별 설치 | ⭐⭐⭐⭐ | 전문 개발자 |
| **포트 포워딩** | ⭐ | ✅ 모든 OS | ⭐⭐⭐ | 기존 도구 활용 |

---

## 🚀 방법 1: 포트 포워딩으로 직접 접근

### 📊 기본 MySQL 컨테이너 구성
```yaml
# docker-compose.yml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: mysql-dev
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: testdb
      MYSQL_USER: testuser
      MYSQL_PASSWORD: testpass
    ports:
      - "3306:3306"  # 호스트 포트로 직접 노출
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init-db:/docker-entrypoint-initdb.d
    command: --default-authentication-plugin=mysql_native_password

volumes:
  mysql_data:
```

**🔗 접근 방법**:
```bash
# 1. 컨테이너 실행
docker-compose up -d

# 2. 로컬 MySQL 클라이언트로 접근
# 호스트: localhost
# 포트: 3306
# 사용자: testuser
# 비밀번호: testpass
# 데이터베이스: testdb
```

---

## 💻 방법 2: Docker exec 명령어 (CLI)

### 🔧 MySQL 접근
```bash
# 1. MySQL 컨테이너 내부 접근
docker exec -it mysql-dev mysql -u root -p

# 2. 특정 데이터베이스 직접 접근
docker exec -it mysql-dev mysql -u testuser -ptestpass testdb

# 3. SQL 파일 실행
docker exec -i mysql-dev mysql -u root -prootpassword testdb < backup.sql

# 4. 데이터베이스 백업
docker exec mysql-dev mysqldump -u root -prootpassword testdb > backup.sql

# 5. 간단한 쿼리 실행
docker exec mysql-dev mysql -u root -prootpassword -e "SHOW DATABASES;"
```

### 🐘 PostgreSQL 접근
```bash
# PostgreSQL 컨테이너 예시
docker run -d \
  --name postgres-dev \
  -e POSTGRES_DB=testdb \
  -e POSTGRES_USER=testuser \
  -e POSTGRES_PASSWORD=testpass \
  -p 5432:5432 \
  postgres:13

# 1. PostgreSQL 접근
docker exec -it postgres-dev psql -U testuser -d testdb

# 2. SQL 실행
docker exec -it postgres-dev psql -U testuser -d testdb -c "SELECT version();"

# 3. 백업
docker exec postgres-dev pg_dump -U testuser testdb > backup.sql
```

---

## 🖥️ 방법 3: 네이티브 클라이언트 도구

### 🪟 Windows
```powershell
# MySQL Workbench 설치 (GUI)
winget install Oracle.MySQLWorkbench

# MySQL CLI 설치
winget install Oracle.MySQL

# 연결
mysql -h localhost -P 3306 -u testuser -p
```

### 🍎 macOS
```bash
# Homebrew로 설치
brew install mysql-client
brew install --cask mysql-workbench

# 연결
mysql -h localhost -P 3306 -u testuser -p
```

### 🐧 Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mysql-client

# CentOS/RHEL
sudo yum install mysql

# 연결
mysql -h localhost -P 3306 -u testuser -p
```

---

## 🔧 실전 활용 스크립트

### 📋 올인원 DB 셋업 스크립트
```bash
#!/bin/bash
# db-setup.sh - 크로스 플랫폼 DB 셋업

echo "🗄️ Docker DB 환경 구축 시작..."

# 1. Docker Compose 파일 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: mysql-dev
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: testdb
      MYSQL_USER: testuser
      MYSQL_PASSWORD: testpass
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init-db:/docker-entrypoint-initdb.d
    command: --default-authentication-plugin=mysql_native_password

volumes:
  mysql_data:
EOF

# 2. 초기 데이터 디렉토리 생성
mkdir -p init-db

# 3. 샘플 데이터 생성
cat > init-db/01-sample-data.sql << 'EOF'
USE testdb;

-- 1. 먼저 users 테이블 생성
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. users 데이터 먼저 삽입 (외래키 참조 대상)
INSERT INTO users (name, email) VALUES
('홍길동', 'hong@example.com'),
('김철수', 'kim@example.com'),
('이영희', 'lee@example.com');

-- 3. posts 테이블 생성 (외래키 제약조건 포함)
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,  -- NOT NULL 추가로 데이터 무결성 강화
    title VARCHAR(200) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. posts 데이터 삽입 (users 테이블에 존재하는 id만 참조)
INSERT INTO posts (user_id, title, content) VALUES
(1, '첫 번째 게시글', '안녕하세요! 첫 번째 게시글입니다.'),
(2, 'Docker 학습', 'Docker로 데이터베이스를 구축했습니다.'),
(3, '실습 후기', '오늘 실습이 정말 유익했습니다.'),
(1, '두 번째 게시글', '홍길동의 두 번째 게시글입니다.'),
(2, 'MySQL 팁', 'MySQL 사용 시 유용한 팁들을 공유합니다.');

-- 5. 데이터 확인용 뷰 생성
CREATE VIEW user_posts AS
SELECT 
    u.name as user_name,
    u.email,
    p.title,
    p.content,
    p.created_at
FROM users u
JOIN posts p ON u.id = p.user_id
ORDER BY p.created_at DESC;
EOF

# 4. 컨테이너 실행
echo "🚀 컨테이너 실행 중..."
docker-compose up -d

# 5. 상태 확인
echo "⏳ 데이터베이스 초기화 대기 중..."
sleep 30

echo "✅ 설정 완료!"
echo ""
echo "📊 접근 방법:"
echo "1. CLI 접근: docker exec -it mysql-dev mysql -u testuser -ptestpass testdb"
echo "2. 로컬 클라이언트: mysql -h localhost -P 3306 -u testuser -p"
echo "3. GUI 도구: MySQL Workbench, DBeaver 등"
echo ""
echo "🔑 접속 정보:"
echo "- 호스트: localhost"
echo "- 포트: 3306"
echo "- 사용자: testuser"
echo "- 비밀번호: testpass"
echo "- 데이터베이스: testdb"
```

### 🔍 DB 상태 확인 스크립트
```bash
#!/bin/bash
# db-check.sh - DB 상태 확인

echo "🔍 데이터베이스 상태 확인..."

# 1. 컨테이너 상태
echo "📦 컨테이너 상태:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep mysql

# 2. 네트워크 연결 테스트
echo ""
echo "🌐 네트워크 연결 테스트:"
if docker exec mysql-dev mysqladmin -u testuser -ptestpass ping > /dev/null 2>&1; then
    echo "✅ MySQL 연결 성공"
else
    echo "❌ MySQL 연결 실패"
fi

# 3. 데이터베이스 목록
echo ""
echo "🗄️ 데이터베이스 목록:"
docker exec mysql-dev mysql -u testuser -ptestpass -e "SHOW DATABASES;"

# 4. 테이블 목록
echo ""
echo "📋 testdb 테이블 목록:"
docker exec mysql-dev mysql -u testuser -ptestpass testdb -e "SHOW TABLES;"

# 5. 샘플 데이터 확인
echo ""
echo "👥 사용자 데이터:"
docker exec mysql-dev mysql -u testuser -ptestpass testdb -e "SELECT * FROM users;"

echo ""
echo "📝 게시글 데이터:"
docker exec mysql-dev mysql -u testuser -ptestpass testdb -e "SELECT * FROM posts;"

echo ""
echo "🔗 사용자-게시글 조인 데이터:"
docker exec mysql-dev mysql -u testuser -ptestpass testdb -e "SELECT * FROM user_posts LIMIT 5;"

echo ""
echo "ℹ️ 외래키 제약조건 확인:"
docker exec mysql-dev mysql -u testuser -ptestpass testdb -e "SHOW CREATE TABLE posts\G" | grep FOREIGN
```

---

## 🚨 트러블슈팅 가이드

### ❌ 자주 발생하는 문제들

#### 1. **포트 충돌 문제**
```bash
# 문제: Port 3306 already in use
# 해결: 다른 포트 사용
ports:
  - "3307:3306"  # 호스트 포트 변경

# 또는 기존 MySQL 서비스 중지
# Windows
net stop mysql80

# macOS/Linux
sudo systemctl stop mysql
```

#### 2. **권한 문제**
```bash
# 문제: Access denied for user
# 해결: 올바른 인증 정보 확인
docker logs mysql-dev  # 로그 확인

# 컨테이너 재시작
docker-compose restart mysql
```

#### 3. **연결 거부 문제**
```bash
# 문제: Connection refused
# 해결: 컨테이너 상태 확인
docker ps
docker logs mysql-dev

# 네트워크 확인
docker network ls
docker network inspect [network-name]
```

#### 4. **데이터 초기화 문제**
```bash
# 문제: 초기 데이터가 생성되지 않음
# 해결: 볼륨 삭제 후 재생성
docker-compose down -v
docker-compose up -d
```

#### 5. **외래키 제약조건 오류**
```bash
# 문제: Cannot add or update a child row: foreign key constraint fails
# 원인: 참조하는 테이블에 해당 값이 없음

# 해결 1: 참조 데이터 먼저 확인
docker exec mysql-dev mysql -u testuser -ptestpass testdb -e "SELECT id FROM users;"

# 해결 2: 존재하는 user_id만 사용
INSERT INTO posts (user_id, title, content) VALUES (1, '제목', '내용');

# 해결 3: 외래키 제약조건 일시 비활성화 (비추천)
SET FOREIGN_KEY_CHECKS = 0;
-- 데이터 작업
SET FOREIGN_KEY_CHECKS = 1;
```

### 🔗 ON DELETE CASCADE 이해하기

**정의**: 부모 테이블의 레코드가 삭제되면 자식 테이블의 관련 레코드도 자동 삭제

```sql
-- 현재 설정: ON DELETE CASCADE
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
```

**실제 동작 예시**:
```bash
# 1. 현재 데이터 확인
docker exec mysql-dev mysql -u testuser -ptestpass testdb -e "
SELECT u.name, COUNT(p.id) as post_count 
FROM users u LEFT JOIN posts p ON u.id = p.user_id 
GROUP BY u.id, u.name;"

# 결과 예시:
# 홍길동: 2개 게시글
# 김철수: 2개 게시글  
# 이영희: 1개 게시글

# 2. 사용자 삭제 (CASCADE 동작)
docker exec mysql-dev mysql -u testuser -ptestpass testdb -e "
DELETE FROM users WHERE name = '홍길동';"

# 3. 결과 확인 - 홍길동의 게시글도 자동 삭제됨
docker exec mysql-dev mysql -u testuser -ptestpass testdb -e "
SELECT * FROM posts;"  # 홍길동(user_id=1)의 게시글 사라짐
```

**다른 옵션들**:
- `ON DELETE RESTRICT`: 자식 레코드가 있으면 부모 삭제 불가 (기본값)
- `ON DELETE SET NULL`: 부모 삭제 시 자식의 외래키를 NULL로 설정
- `ON DELETE NO ACTION`: RESTRICT와 동일

---

## 📱 원격 접근

### 🌐 네트워크를 통한 접근
```bash
# 같은 네트워크의 다른 기기에서 접근
# 호스트 IP 확인
ipconfig  # Windows
ifconfig  # macOS/Linux

# 다른 기기에서 MySQL 접근
mysql -h [호스트IP] -P 3306 -u testuser -p

# 또는 GUI 도구로 접근
# 호스트: [호스트IP]
# 포트: 3306
```

---

## 🎯 실습 미션

### 🏆 초급 미션
1. **CLI 접근**: docker exec로 MySQL CLI 접근하여 테이블 확인
2. **데이터 조회**: users 테이블의 모든 데이터 조회
3. **외래키 테스트**: 존재하지 않는 user_id로 게시글 추가 시도해보기

### 🚀 중급 미션
1. **CLI 접근**: docker exec로 MySQL CLI 접근
2. **조인 쿼리**: users와 posts 테이블 조인 쿼리 실행
3. **백업**: 데이터베이스 전체 백업 파일 생성

### 💎 고급 미션
1. **다중 DB**: PostgreSQL 컨테이너 추가 구성
2. **네트워크 분리**: DB 전용 네트워크 구성
3. **모니터링**: DB 성능 모니터링 도구 연동

---

<div align="center">

**🗄️ Docker DB 접근 마스터 완료**

*OS 상관없이 어디서든 데이터베이스에 접근할 수 있습니다*

**추천**: Docker exec 명령어로 시작하여 CLI에 익숙해지세요!

</div>