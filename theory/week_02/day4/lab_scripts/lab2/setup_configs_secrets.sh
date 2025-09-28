#!/bin/bash

# Week 2 Day 4 Lab 2: 설정 및 시크릿 자동 생성 스크립트
# 사용법: ./setup_configs_secrets.sh

echo "=== WordPress K8s 마이그레이션: 설정 및 시크릿 생성 시작 ==="
echo ""

# 1. 클러스터 연결 확인
echo "1. 클러스터 연결 확인 중..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes 클러스터에 연결할 수 없습니다."
    echo "먼저 Lab 1의 setup_k8s_cluster.sh를 실행해주세요."
    exit 1
fi
echo "✅ 클러스터 연결 확인 완료"
echo ""

# 2. 네임스페이스 생성
echo "2. 네임스페이스 생성 중..."
kubectl create namespace wordpress-k8s --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring-k8s --dry-run=client -o yaml | kubectl apply -f -
echo "✅ wordpress-k8s, monitoring-k8s 네임스페이스 생성 완료"
echo ""

# 3. MySQL 설정을 위한 ConfigMap 생성
echo "3. MySQL ConfigMap 생성 중..."
cat > /tmp/mysql-configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: wordpress-k8s
  labels:
    app: mysql
    component: database
data:
  my.cnf: |
    [mysqld]
    # 기본 설정
    bind-address = 0.0.0.0
    port = 3306
    socket = /var/run/mysqld/mysqld.sock
    
    # 문자셋 설정
    character-set-server = utf8mb4
    collation-server = utf8mb4_unicode_ci
    init-connect = 'SET NAMES utf8mb4'
    
    # InnoDB 설정
    innodb_buffer_pool_size = 256M
    innodb_log_file_size = 64M
    innodb_flush_log_at_trx_commit = 2
    innodb_file_per_table = 1
    
    # 연결 설정
    max_connections = 100
    wait_timeout = 600
    interactive_timeout = 600
    
    # 로깅 설정
    slow_query_log = 1
    long_query_time = 2
    slow_query_log_file = /var/log/mysql/slow.log
    
    # 보안 설정
    local_infile = 0
    
    # 성능 최적화
    query_cache_type = 1
    query_cache_size = 32M
    tmp_table_size = 32M
    max_heap_table_size = 32M
    
  init.sql: |
    -- WordPress 데이터베이스 초기화
    CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY 'wppassword';
    GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
    FLUSH PRIVILEGES;
    
    -- 기본 테이블 생성 (WordPress가 자동으로 생성하지만 미리 준비)
    USE wordpress;
    
    -- 성능 모니터링을 위한 뷰 생성
    CREATE OR REPLACE VIEW db_status AS
    SELECT 
        'connections' as metric,
        VARIABLE_VALUE as value
    FROM information_schema.GLOBAL_STATUS 
    WHERE VARIABLE_NAME = 'Threads_connected'
    UNION ALL
    SELECT 
        'queries' as metric,
        VARIABLE_VALUE as value
    FROM information_schema.GLOBAL_STATUS 
    WHERE VARIABLE_NAME = 'Queries';
EOF

kubectl apply -f /tmp/mysql-configmap.yaml
echo "✅ MySQL ConfigMap 생성 완료"
echo ""

# 4. WordPress 설정을 위한 ConfigMap 생성
echo "4. WordPress ConfigMap 생성 중..."
cat > /tmp/wordpress-configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: wordpress-config
  namespace: wordpress-k8s
  labels:
    app: wordpress
    component: frontend
data:
  # 데이터베이스 연결 설정
  WORDPRESS_DB_HOST: "mysql-service:3306"
  WORDPRESS_DB_NAME: "wordpress"
  WORDPRESS_DB_USER: "wpuser"
  
  # WordPress 기본 설정
  WORDPRESS_TABLE_PREFIX: "wp_"
  WORDPRESS_DEBUG: "0"
  
  # PHP 설정
  php.ini: |
    ; PHP 성능 설정
    memory_limit = 256M
    max_execution_time = 300
    max_input_time = 300
    
    ; 업로드 설정
    upload_max_filesize = 64M
    post_max_size = 64M
    max_file_uploads = 20
    
    ; 세션 설정
    session.gc_maxlifetime = 1440
    session.cookie_lifetime = 0
    
    ; 오류 보고 설정
    display_errors = Off
    log_errors = On
    error_log = /var/log/php_errors.log
    
    ; 보안 설정
    expose_php = Off
    allow_url_fopen = Off
    
    ; OPcache 설정
    opcache.enable = 1
    opcache.memory_consumption = 128
    opcache.max_accelerated_files = 4000
    opcache.revalidate_freq = 60
    
  # WordPress 추가 설정
  wp-config-extra.php: |
    <?php
    // 추가 WordPress 설정
    
    // 보안 강화
    define('DISALLOW_FILE_EDIT', true);
    define('DISALLOW_FILE_MODS', true);
    define('FORCE_SSL_ADMIN', false);
    
    // 성능 최적화
    define('WP_MEMORY_LIMIT', '256M');
    define('WP_MAX_MEMORY_LIMIT', '512M');
    
    // 캐시 설정
    define('WP_CACHE', true);
    define('COMPRESS_CSS', true);
    define('COMPRESS_SCRIPTS', true);
    
    // 자동 업데이트 설정
    define('AUTOMATIC_UPDATER_DISABLED', true);
    define('WP_AUTO_UPDATE_CORE', false);
    
    // 디버그 설정 (개발 환경)
    if (getenv('WORDPRESS_DEBUG') === '1') {
        define('WP_DEBUG', true);
        define('WP_DEBUG_LOG', true);
        define('WP_DEBUG_DISPLAY', false);
    }
    
    // 멀티사이트 준비 (필요시)
    // define('WP_ALLOW_MULTISITE', true);
    
  # Nginx 설정 (WordPress용)
  nginx.conf: |
    server {
        listen 80;
        server_name _;
        root /var/www/html;
        index index.php index.html;
        
        # 보안 헤더
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # WordPress 규칙
        location / {
            try_files $uri $uri/ /index.php?$args;
        }
        
        # PHP 처리
        location ~ \.php$ {
            fastcgi_pass wordpress:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
        
        # 정적 파일 캐시
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        # WordPress 보안
        location ~ /\. {
            deny all;
        }
        
        location ~* /(?:uploads|files)/.*\.php$ {
            deny all;
        }
        
        # Health check
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
EOF

kubectl apply -f /tmp/wordpress-configmap.yaml
echo "✅ WordPress ConfigMap 생성 완료"
echo ""

# 5. 민감한 정보를 위한 Secret 생성
echo "5. WordPress Secret 생성 중..."

# Base64 인코딩된 값들 생성
MYSQL_ROOT_PASSWORD=$(echo -n "rootpassword123!" | base64)
MYSQL_PASSWORD=$(echo -n "wppassword123!" | base64)
WORDPRESS_DB_PASSWORD=$(echo -n "wppassword123!" | base64)

# WordPress 보안 키 생성 (실제로는 WordPress.org에서 생성)
WP_AUTH_KEY=$(echo -n "$(openssl rand -base64 32)" | base64)
WP_SECURE_AUTH_KEY=$(echo -n "$(openssl rand -base64 32)" | base64)
WP_LOGGED_IN_KEY=$(echo -n "$(openssl rand -base64 32)" | base64)
WP_NONCE_KEY=$(echo -n "$(openssl rand -base64 32)" | base64)

cat > /tmp/wordpress-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: wordpress-secret
  namespace: wordpress-k8s
  labels:
    app: wordpress
    component: security
type: Opaque
data:
  # MySQL 인증 정보
  MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
  MYSQL_PASSWORD: $MYSQL_PASSWORD
  WORDPRESS_DB_PASSWORD: $WORDPRESS_DB_PASSWORD
  
  # WordPress 보안 키
  WORDPRESS_AUTH_KEY: $WP_AUTH_KEY
  WORDPRESS_SECURE_AUTH_KEY: $WP_SECURE_AUTH_KEY
  WORDPRESS_LOGGED_IN_KEY: $WP_LOGGED_IN_KEY
  WORDPRESS_NONCE_KEY: $WP_NONCE_KEY
  
  # 추가 보안 설정
  WORDPRESS_CONFIG_EXTRA: $(echo -n "define('WP_DEBUG', false);" | base64)
EOF

kubectl apply -f /tmp/wordpress-secret.yaml
echo "✅ WordPress Secret 생성 완료"
echo ""

# 6. TLS Secret 생성 (자체 서명 인증서)
echo "6. TLS Secret 생성 중..."

# 자체 서명 인증서 생성
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/tls.key \
    -out /tmp/tls.crt \
    -subj "/CN=wordpress.local/O=wordpress.local" \
    -addext "subjectAltName=DNS:wordpress.local,DNS:*.wordpress.local,IP:127.0.0.1" 2>/dev/null

# TLS Secret 생성
kubectl create secret tls wordpress-tls \
    --cert=/tmp/tls.crt \
    --key=/tmp/tls.key \
    -n wordpress-k8s \
    --dry-run=client -o yaml | kubectl apply -f -

echo "✅ TLS Secret 생성 완료"
echo ""

# 7. 모니터링용 ConfigMap 생성
echo "7. 모니터링 ConfigMap 생성 중..."
cat > /tmp/monitoring-configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: monitoring-config
  namespace: monitoring-k8s
  labels:
    app: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
      
      - job_name: 'wordpress-app'
        static_configs:
          - targets: ['wordpress-service.wordpress-k8s.svc.cluster.local:80']
        metrics_path: '/metrics'
        scrape_interval: 30s
  
  grafana-datasources.yml: |
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        access: proxy
        url: http://prometheus-service:9090
        isDefault: true
EOF

kubectl apply -f /tmp/monitoring-configmap.yaml
echo "✅ 모니터링 ConfigMap 생성 완료"
echo ""

# 8. 생성된 리소스 확인
echo "8. 생성된 설정 및 시크릿 확인"
echo "============================"
echo ""

echo "📋 ConfigMaps:"
kubectl get configmaps -n wordpress-k8s
echo ""

echo "🔐 Secrets:"
kubectl get secrets -n wordpress-k8s
echo ""

echo "📊 모니터링 네임스페이스:"
kubectl get configmaps -n monitoring-k8s
echo ""

# 9. 설정 내용 검증
echo "9. 설정 내용 검증"
echo "================"
echo ""

echo "🔍 MySQL 설정 확인:"
kubectl get configmap mysql-config -n wordpress-k8s -o jsonpath='{.data.my\.cnf}' | head -10
echo "... (생략)"
echo ""

echo "🔍 WordPress 설정 확인:"
kubectl get configmap wordpress-config -n wordpress-k8s -o jsonpath='{.data.WORDPRESS_DB_HOST}'
echo ""

echo "🔍 Secret 키 확인:"
kubectl get secret wordpress-secret -n wordpress-k8s -o jsonpath='{.data}' | jq -r 'keys[]' 2>/dev/null || kubectl get secret wordpress-secret -n wordpress-k8s -o jsonpath='{.data}' | grep -o '"[^"]*"' | tr -d '"'
echo ""

# 10. 임시 파일 정리
echo "10. 임시 파일 정리 중..."
rm -f /tmp/mysql-configmap.yaml
rm -f /tmp/wordpress-configmap.yaml
rm -f /tmp/wordpress-secret.yaml
rm -f /tmp/monitoring-configmap.yaml
rm -f /tmp/tls.key /tmp/tls.crt
echo "✅ 임시 파일 정리 완료"
echo ""

# 11. 완료 요약
echo ""
echo "=== 설정 및 시크릿 생성 완료 ==="
echo ""
echo "생성된 리소스:"
echo "- 네임스페이스: wordpress-k8s, monitoring-k8s"
echo "- ConfigMap: mysql-config (MySQL 설정)"
echo "- ConfigMap: wordpress-config (WordPress 설정)"
echo "- ConfigMap: monitoring-config (모니터링 설정)"
echo "- Secret: wordpress-secret (인증 정보)"
echo "- Secret: wordpress-tls (TLS 인증서)"
echo ""
echo "설정 내용:"
echo "- MySQL: 성능 최적화 및 보안 설정"
echo "- WordPress: PHP 최적화 및 보안 강화"
echo "- TLS: 자체 서명 인증서 (개발용)"
echo "- 모니터링: Prometheus/Grafana 설정"
echo ""
echo "보안 정보:"
echo "- 모든 패스워드는 Secret으로 안전하게 저장"
echo "- WordPress 보안 키 자동 생성"
echo "- TLS 인증서로 HTTPS 지원 준비"
echo ""
echo "다음 단계:"
echo "- deploy_mysql_statefulset.sh 실행"
echo "- MySQL StatefulSet 배포 및 데이터 영속성 설정"
echo ""
echo "🎉 설정 및 시크릿 생성이 성공적으로 완료되었습니다!"