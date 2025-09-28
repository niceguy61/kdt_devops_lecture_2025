#!/bin/bash

# Week 2 Day 2 Lab 1: MySQL 데이터베이스 구축 스크립트
# 사용법: ./setup_database.sh

echo "=== MySQL 데이터베이스 구축 시작 ==="

# MySQL 데이터 볼륨 생성
echo "1. MySQL 볼륨 생성 중..."
docker volume create mysql-data
docker volume create mysql-config

# MySQL 설정 디렉토리 생성
echo "2. MySQL 설정 파일 생성 중..."
mkdir -p config/mysql

# MySQL 최적화 설정 파일 생성
cat > config/mysql/my.cnf << 'EOF'
[mysqld]
# 기본 설정
bind-address = 0.0.0.0
port = 3306
datadir = /var/lib/mysql

# 문자셋
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# InnoDB 최적화
innodb_buffer_pool_size = 512M
innodb_log_file_size = 128M
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = 1

# 연결 설정
max_connections = 100
wait_timeout = 600
interactive_timeout = 600

# 쿼리 캐시 (MySQL 8.0에서는 제거됨)
query_cache_type = 0
query_cache_size = 0

# 로깅
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
general_log = 0

# 보안
local_infile = 0
EOF

# MySQL 컨테이너 실행
echo "3. MySQL 컨테이너 실행 중..."
docker run -d \
  --name mysql-wordpress \
  --restart=unless-stopped \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wpuser \
  -e MYSQL_PASSWORD=wppassword \
  -v mysql-data:/var/lib/mysql \
  -v mysql-config:/etc/mysql/conf.d \
  -v $(pwd)/config/mysql/my.cnf:/etc/mysql/conf.d/custom.cnf \
  --memory=1g \
  --cpus=1.0 \
  --health-cmd="mysqladmin ping -h localhost -u root -prootpassword" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  mysql:8.0

# 데이터베이스 초기화 대기
echo "4. 데이터베이스 초기화 대기 중... (30초)"
sleep 30

# 연결 테스트
echo "5. 데이터베이스 연결 테스트..."
if docker exec mysql-wordpress mysql -u wpuser -pwppassword -e "SHOW DATABASES;" >/dev/null 2>&1; then
    echo "✅ MySQL 데이터베이스 연결 성공"
else
    echo "❌ MySQL 데이터베이스 연결 실패"
    exit 1
fi

# 성능 설정 확인
echo "6. MySQL 성능 설정 확인..."
docker exec mysql-wordpress mysql -u root -prootpassword -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';"

echo ""
echo "=== MySQL 데이터베이스 구축 완료 ==="
echo ""
echo "MySQL 데이터베이스 정보:"
echo "- 컨테이너명: mysql-wordpress"
echo "- 데이터베이스: wordpress"
echo "- 사용자: wpuser / 비밀번호: wppassword"
echo "- 루트 비밀번호: rootpassword"
echo "- 볼륨: mysql-data (데이터), mysql-config (설정)"