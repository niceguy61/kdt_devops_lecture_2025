#!/bin/bash

# Week 2 Day 3 Lab 2: 서비스 스택 자동 배포
# 사용법: ./deploy_service_stack.sh

echo "=== 서비스 스택 자동 배포 시작 ==="

# 1. Swarm 클러스터 상태 확인
echo "1. Swarm 클러스터 상태 확인 중..."
if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q active; then
    echo "❌ Swarm 클러스터가 활성화되지 않았습니다."
    echo "먼저 ./setup_swarm_cluster.sh를 실행하세요."
    exit 1
fi

NODE_COUNT=$(docker node ls --format "{{.Hostname}}" | wc -l)
echo "✅ Swarm 클러스터 활성 ($NODE_COUNT개 노드)"

# 2. 오버레이 네트워크 생성
echo "2. 오버레이 네트워크 생성 중..."
docker network create --driver overlay --attachable frontend-net 2>/dev/null || echo "frontend-net 이미 존재"
docker network create --driver overlay --attachable backend-net 2>/dev/null || echo "backend-net 이미 존재"
docker network create --driver overlay --attachable database-net 2>/dev/null || echo "database-net 이미 존재"
docker network create --driver overlay --attachable monitoring-net 2>/dev/null || echo "monitoring-net 이미 존재"

echo "생성된 오버레이 네트워크:"
docker network ls --filter driver=overlay --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"

# 3. 스택 디렉토리 생성
echo "3. 스택 디렉토리 생성 중..."
mkdir -p stacks/{web,database,monitoring}
mkdir -p configs

# 4. 데이터베이스 스택 생성
echo "4. 데이터베이스 스택 생성 중..."
cat > stacks/database/docker-compose.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    networks:
      - database-net
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppassword
    volumes:
      - mysql-data:/var/lib/mysql
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.role == database
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 5
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10
      interval: 30s

networks:
  database-net:
    external: true

volumes:
  mysql-data:
    driver: local
EOF

# 5. 웹 애플리케이션 스택 생성
echo "5. 웹 애플리케이션 스택 생성 중..."

# Nginx 설정 파일 생성
cat > configs/nginx.conf << 'EOF'
upstream wordpress {
    server wordpress:80;
}

server {
    listen 80;
    server_name _;
    
    # 로그 설정
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    # 헬스 체크
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # 정적 파일 캐싱
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        proxy_pass http://wordpress;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # 동적 콘텐츠
    location / {
        proxy_pass http://wordpress;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 타임아웃 설정
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
}
EOF

# Docker Config 생성
docker config create nginx_config configs/nginx.conf 2>/dev/null || \
docker config rm nginx_config && docker config create nginx_config configs/nginx.conf

# 웹 스택 Compose 파일 생성
cat > stacks/web/docker-compose.yml << 'EOF'
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    networks:
      - frontend-net
      - backend-net
    configs:
      - source: nginx_config
        target: /etc/nginx/conf.d/default.conf
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.labels.role == web
      update_config:
        parallelism: 1
        delay: 30s
        failure_action: rollback
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          memory: 128M
        reservations:
          memory: 64M

  wordpress:
    image: wordpress:latest
    networks:
      - backend-net
      - database-net
    environment:
      WORDPRESS_DB_HOST: mysql:3306
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppassword
    volumes:
      - wp-content:/var/www/html/wp-content
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.labels.role == api
      update_config:
        parallelism: 1
        delay: 60s
        failure_action: rollback
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 3
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      timeout: 10s
      retries: 3
      interval: 30s

networks:
  frontend-net:
    external: true
  backend-net:
    external: true
  database-net:
    external: true

volumes:
  wp-content:
    driver: local

configs:
  nginx_config:
    external: true
EOF

# 6. 모니터링 스택 생성
echo "6. 모니터링 스택 생성 중..."

# Prometheus 설정 파일 생성
cat > configs/prometheus-swarm.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'cadvisor'
    dns_sd_configs:
      - names:
          - 'tasks.cadvisor'
        type: 'A'
        port: 8080

  - job_name: 'node-exporter'
    dns_sd_configs:
      - names:
          - 'tasks.node-exporter'
        type: 'A'
        port: 9100

  - job_name: 'dockerd'
    static_configs:
      - targets: ['host.docker.internal:9323']
EOF

# Prometheus Config 생성
docker config create prometheus_swarm_config configs/prometheus-swarm.yml 2>/dev/null || \
docker config rm prometheus_swarm_config && docker config create prometheus_swarm_config configs/prometheus-swarm.yml

# 모니터링 스택 Compose 파일 생성
cat > stacks/monitoring/docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    networks:
      - monitoring-net
    configs:
      - source: prometheus_swarm_config
        target: /etc/prometheus/prometheus.yml
    volumes:
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
      - '--web.enable-lifecycle'
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    networks:
      - monitoring-net
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
      GF_USERS_ALLOW_SIGN_UP: false
    volumes:
      - grafana-data:/var/lib/grafana
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    networks:
      - monitoring-net
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    deploy:
      mode: global
      restart_policy:
        condition: on-failure
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

networks:
  monitoring-net:
    external: true

volumes:
  prometheus-data:
    driver: local
  grafana-data:
    driver: local

configs:
  prometheus_swarm_config:
    external: true
EOF

# 7. 스택 배포
echo "7. 스택 배포 중..."

# 데이터베이스 스택 배포
echo "데이터베이스 스택 배포 중..."
docker stack deploy -c stacks/database/docker-compose.yml database

# 데이터베이스 시작 대기
echo "데이터베이스 시작 대기 중..."
sleep 30

# 웹 애플리케이션 스택 배포
echo "웹 애플리케이션 스택 배포 중..."
docker stack deploy -c stacks/web/docker-compose.yml web

# 모니터링 스택 배포
echo "모니터링 스택 배포 중..."
docker stack deploy -c stacks/monitoring/docker-compose.yml monitoring

# 8. 배포 상태 확인
echo "8. 배포 상태 확인 중..."
sleep 20

echo ""
echo "📊 배포된 스택:"
docker stack ls

echo ""
echo "🔧 서비스 상태:"
docker service ls

echo ""
echo "📋 서비스 세부 정보:"
for service in $(docker service ls --format "{{.Name}}"); do
    echo "  $service:"
    docker service ps $service --format "    {{.Name}} -> {{.Node}} ({{.CurrentState}})"
done

# 9. 헬스 체크
echo ""
echo "9. 서비스 헬스 체크 중..."
sleep 30

# 웹 서비스 확인
if curl -f http://localhost/health >/dev/null 2>&1; then
    echo "✅ 웹 서비스: 정상"
else
    echo "⚠️ 웹 서비스: 아직 시작 중"
fi

# Prometheus 확인
if curl -f http://localhost:9090/-/healthy >/dev/null 2>&1; then
    echo "✅ Prometheus: 정상"
else
    echo "⚠️ Prometheus: 아직 시작 중"
fi

# Grafana 확인
if curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ Grafana: 정상"
else
    echo "⚠️ Grafana: 아직 시작 중"
fi

echo ""
echo "=== 서비스 스택 배포 완료 ==="
echo ""
echo "🌐 접속 정보:"
echo "- 웹 서비스: http://localhost/"
echo "- 헬스 체크: http://localhost/health"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- cAdvisor: http://localhost:8080"
echo ""
echo "📊 상태 확인 명령어:"
echo "- docker stack ls"
echo "- docker service ls"
echo "- docker service ps <service-name>"
echo ""
echo "🔗 다음 단계: ./deploy_and_scale_services.sh"