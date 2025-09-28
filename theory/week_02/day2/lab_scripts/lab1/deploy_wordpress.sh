#!/bin/bash

# Week 2 Day 2 Lab 1: WordPress 애플리케이션 배포 스크립트
# 사용법: ./deploy_wordpress.sh

echo "=== WordPress 애플리케이션 배포 시작 ==="

# WordPress 데이터 볼륨 생성
echo "1. WordPress 볼륨 생성 중..."
docker volume create wp-content
docker volume create wp-config
docker volume create redis-data

# WordPress 설정 디렉토리 생성
echo "2. WordPress 설정 파일 생성 중..."
mkdir -p config/wordpress config/php

# WordPress 설정 파일 생성
cat > config/wordpress/wp-config.php << 'EOF'
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', 'wppassword');
define('DB_HOST', 'mysql-wordpress:3306');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

// 보안 키 설정 (실제 환경에서는 고유한 키 사용)
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

// Redis 세션 설정
define('WP_REDIS_HOST', 'redis-session');
define('WP_REDIS_PORT', 6379);
define('WP_REDIS_DATABASE', 0);

// 성능 최적화
define('WP_CACHE', true);
define('COMPRESS_CSS', true);
define('COMPRESS_SCRIPTS', true);
define('CONCATENATE_SCRIPTS', true);

// 디버그 설정
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);

// 파일 권한
define('FS_METHOD', 'direct');

// 테이블 접두사
$table_prefix = 'wp_';

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOF

# PHP 최적화 설정 파일 생성
cat > config/php/php.ini << 'EOF'
; 메모리 설정
memory_limit = 256M
max_execution_time = 300
max_input_time = 300

; 파일 업로드
upload_max_filesize = 64M
post_max_size = 64M
max_file_uploads = 20

; 세션 설정
session.save_handler = redis
session.save_path = "tcp://redis-session:6379"
session.gc_maxlifetime = 3600

; OPcache 설정
opcache.enable = 1
opcache.memory_consumption = 128
opcache.max_accelerated_files = 4000
opcache.revalidate_freq = 60
opcache.validate_timestamps = 1

; 로깅
log_errors = On
error_log = /var/log/php_errors.log

; 보안
expose_php = Off
allow_url_fopen = Off
allow_url_include = Off
EOF

# Redis 세션 스토어 실행
echo "3. Redis 세션 스토어 실행 중..."
docker run -d \
  --name redis-session \
  --restart=unless-stopped \
  -v redis-data:/data \
  --memory=256m \
  --health-cmd="redis-cli ping" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  redis:7-alpine redis-server --appendonly yes --maxmemory 200mb --maxmemory-policy allkeys-lru

# WordPress 컨테이너 실행
echo "4. WordPress 컨테이너 실행 중..."
docker run -d \
  --name wordpress-app \
  --restart=unless-stopped \
  -p 8080:80 \
  -e WORDPRESS_DB_HOST=mysql-wordpress:3306 \
  -e WORDPRESS_DB_NAME=wordpress \
  -e WORDPRESS_DB_USER=wpuser \
  -e WORDPRESS_DB_PASSWORD=wppassword \
  -v wp-content:/var/www/html/wp-content \
  -v $(pwd)/config/wordpress/wp-config.php:/var/www/html/wp-config.php \
  -v $(pwd)/config/php/php.ini:/usr/local/etc/php/conf.d/custom.ini \
  --link mysql-wordpress:mysql \
  --link redis-session:redis \
  --memory=512m \
  --cpus=1.0 \
  --health-cmd="curl -f http://localhost/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  wordpress:latest

# 서비스 시작 대기
echo "5. WordPress 서비스 시작 대기 중... (30초)"
sleep 30

# WordPress 연결 테스트
echo "6. WordPress 연결 테스트..."
if curl -f http://localhost:8080/ >/dev/null 2>&1; then
    echo "✅ WordPress 애플리케이션 정상 동작"
else
    echo "❌ WordPress 애플리케이션 연결 실패"
fi

# Redis 연결 테스트
echo "7. Redis 세션 스토어 테스트..."
if docker exec redis-session redis-cli ping | grep -q "PONG"; then
    echo "✅ Redis 세션 스토어 정상 동작"
else
    echo "❌ Redis 세션 스토어 연결 실패"
fi

echo ""
echo "=== WordPress 애플리케이션 배포 완료 ==="
echo ""
echo "배포된 서비스:"
echo "- WordPress: http://localhost:8080"
echo "- Redis 세션 스토어: redis-session:6379"
echo ""
echo "볼륨 정보:"
echo "- wp-content: WordPress 콘텐츠 파일"
echo "- wp-config: WordPress 설정 파일"
echo "- redis-data: Redis 데이터"
echo ""
echo "🌐 브라우저에서 http://localhost:8080 접속하여 WordPress 설치를 완료하세요!"