# Week 1 Day 4 Lab 2: Docker Compose 모니터링 시스템 구축

<div align="center">

**📊 모니터링 & 관측성** • **Prometheus + Grafana**

*Docker Compose 환경에서 완전한 모니터링 스택 구축*

</div>

---

## 🕘 실습 정보

**시간**: 14:00-14:50 (50분)  
**목표**: Docker Compose 환경에서 Prometheus + Grafana 모니터링 시스템 구축  
**방식**: 모니터링 스택 구축 + 대시보드 설정 + 알림 구성

---

## 🎯 실습 목표

### 📚 학습 목표
- **기본 목표**: Docker Compose 환경에서 모니터링 시스템 구축
- **응용 목표**: Prometheus + Grafana를 활용한 시각화 대시보드 생성
- **협업 목표**: 팀별 모니터링 대시보드 커스터마이징 및 공유

---

## 🚀 Phase 1: 모니터링 스택 구성 (15분)

### 📊 확장된 모니터링 아키텍처
```mermaid
graph TB
    subgraph "애플리케이션 스택 (Lab 1)"
        A[React Frontend] --> D[Nginx Proxy]
        B[Node.js Backend] --> D
        C[PostgreSQL] --> B
        E[Redis Cache] --> B
    end
    
    subgraph "모니터링 & 로깅 스택 (Lab 2)"
        F[Node Exporter<br/>시스템 메트릭] --> K[Prometheus<br/>메트릭 수집]
        G[cAdvisor<br/>컨테이너 메트릭] --> K
        H[Postgres Exporter<br/>DB 메트릭] --> K
        I[Redis Exporter<br/>캐시 메트릭] --> K
        J[Nginx Exporter<br/>웹서버 메트릭] --> K
        
        K --> L[Grafana<br/>시각화]
        K --> M[AlertManager<br/>알림 관리]
        
        N[Loki<br/>로그 수집] --> L
        O[Promtail<br/>로그 에이전트] --> N
    end
    
    A -.-> F
    B -.-> G
    C -.-> H
    E -.-> I
    D -.-> J
    
    style K fill:#e3f2fd
    style L fill:#e8f5e8
    style M fill:#fff3e0
    style N fill:#f3e5f5
```

### 🔧 Lab 1 애플리케이션에 모니터링 추가
**Step 1: 기존 애플리케이션 확인**
```bash
# Lab 1에서 구축한 애플리케이션 상태 확인
cd ~/docker-fullstack
docker-compose ps

# 실행 중이 아니라면 다시 시작
if [ $(docker-compose ps -q | wc -l) -eq 0 ]; then
    echo "Lab 1 애플리케이션 시작 중..."
    docker-compose up -d
    sleep 10
fi
```

**Step 2: 백엔드에 메트릭 엔드포인트 추가**
```bash
# 백엔드 서버에 Prometheus 메트릭 추가
cat >> backend/src/server.js << 'EOF'

// Prometheus 메트릭 수집
let httpRequestsTotal = 0;
let httpRequestDuration = [];
let activeConnections = 0;
let errorCount = 0;

// 메트릭 수집 미들웨어
app.use((req, res, next) => {
  const start = Date.now();
  httpRequestsTotal++;
  activeConnections++;
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    httpRequestDuration.push(duration);
    activeConnections--;
    
    if (res.statusCode >= 400) {
      errorCount++;
    }
  });
  
  next();
});

// Prometheus 메트릭 엔드포인트
app.get('/metrics', (req, res) => {
  const avgDuration = httpRequestDuration.length > 0 
    ? httpRequestDuration.reduce((a, b) => a + b) / httpRequestDuration.length 
    : 0;
    
  res.set('Content-Type', 'text/plain');
  res.send(`# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total ${httpRequestsTotal}

# HELP http_request_duration_ms Average HTTP request duration in milliseconds
# TYPE http_request_duration_ms gauge
http_request_duration_ms ${avgDuration}

# HELP http_active_connections Current active connections
# TYPE http_active_connections gauge
http_active_connections ${activeConnections}

# HELP http_errors_total Total HTTP errors (4xx, 5xx)
# TYPE http_errors_total counter
http_errors_total ${errorCount}

# HELP nodejs_memory_usage_bytes Node.js memory usage
# TYPE nodejs_memory_usage_bytes gauge
nodejs_memory_usage_bytes{type="rss"} ${process.memoryUsage().rss}
nodejs_memory_usage_bytes{type="heapTotal"} ${process.memoryUsage().heapTotal}
nodejs_memory_usage_bytes{type="heapUsed"} ${process.memoryUsage().heapUsed}
`);
});
EOF

# 백엔드 컨테이너 재시작
docker-compose restart backend
```

**Step 3: Nginx에 상태 페이지 추가**
```bash
# Nginx 설정에 상태 페이지 추가
cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }
    
    upstream backend {
        server backend:5000;
    }

    server {
        listen 80;
        
        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Backend API
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Nginx 상태 페이지 (모니터링용)
        location /nginx_status {
            stub_status on;
            access_log off;
            allow all;
        }
    }
}
EOF

# Nginx 컨테이너 재시작
docker-compose restart nginx
```

**Step 4: 확장된 모니터링 스택 추가**
```bash
# 확장된 모니터링 스택 파일 생성
cat > docker-compose.monitoring.yml << 'EOF'
version: '3.8'

services:
  # Prometheus - 메트릭 수집 및 저장
  prometheus:
    image: prom/prometheus:latest
    container_name: fullstack-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./monitoring/alert-rules.yml:/etc/prometheus/alert-rules.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
    networks:
      - app-network
      - monitoring

  # Grafana - 시각화 대시보드
  grafana:
    image: grafana/grafana:latest
    container_name: fullstack-grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-piechart-panel,grafana-worldmap-panel
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning
      - ./monitoring/grafana/dashboards:/var/lib/grafana/dashboards
    depends_on:
      - prometheus
    networks:
      - monitoring

  # AlertManager - 알림 관리
  alertmanager:
    image: prom/alertmanager:latest
    container_name: fullstack-alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./monitoring/alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager_data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
      - '--web.external-url=http://localhost:9093'
    networks:
      - monitoring

  # Node Exporter - 시스템 메트릭
  node-exporter:
    image: prom/node-exporter:latest
    container_name: fullstack-node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    networks:
      - monitoring

  # cAdvisor - 컨테이너 메트릭
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: fullstack-cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true
    devices:
      - /dev/kmsg
    networks:
      - monitoring

  # PostgreSQL Exporter - 데이터베이스 메트릭
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    container_name: fullstack-postgres-exporter
    ports:
      - "9187:9187"
    environment:
      - DATA_SOURCE_NAME=postgresql://${DB_USER}:${DB_PASSWORD}@postgres:5432/${DB_NAME}?sslmode=disable
    depends_on:
      - postgres
    networks:
      - app-network
      - monitoring

  # Redis Exporter - 캐시 메트릭
  redis-exporter:
    image: oliver006/redis_exporter:latest
    container_name: fullstack-redis-exporter
    ports:
      - "9121:9121"
    environment:
      - REDIS_ADDR=redis://redis:6379
    depends_on:
      - redis
    networks:
      - app-network
      - monitoring

  # Nginx Exporter - 웹서버 메트릭
  nginx-exporter:
    image: nginx/nginx-prometheus-exporter:latest
    container_name: fullstack-nginx-exporter
    ports:
      - "9113:9113"
    command:
      - '-nginx.scrape-uri=http://nginx:80/nginx_status'
    depends_on:
      - nginx
    networks:
      - app-network
      - monitoring

  # Loki - 로그 수집 및 저장
  loki:
    image: grafana/loki:latest
    container_name: fullstack-loki
    ports:
      - "3100:3100"
    volumes:
      - ./monitoring/loki-config.yml:/etc/loki/local-config.yaml
      - loki_data:/loki
    command: -config.file=/etc/loki/local-config.yaml
    networks:
      - monitoring

  # Promtail - 로그 에이전트
  promtail:
    image: grafana/promtail:latest
    container_name: fullstack-promtail
    volumes:
      - ./monitoring/promtail-config.yml:/etc/promtail/config.yml
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    command: -config.file=/etc/promtail/config.yml
    depends_on:
      - loki
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:
  alertmanager_data:
  loki_data:

networks:
  monitoring:
    driver: bridge
  app-network:
    external: true
EOF
```

**Step 5: 모니터링 설정 파일들 생성**
```bash
# Prometheus 설정 업데이트
cat > monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert-rules.yml"

scrape_configs:
  # Prometheus 자체 모니터링
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter - 시스템 메트릭
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  # cAdvisor - 컨테이너 ��트릭
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  # 백엔드 애플리케이션 메트릭
  - job_name: 'backend'
    static_configs:
      - targets: ['backend:5000']
    metrics_path: '/metrics'

  # PostgreSQL 메트릭
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  # Redis 메트릭
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  # Nginx 메트릭
  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx-exporter:9113']
EOF

# 모니터링 스택 실행
docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml up -d

# 모든 서비스 상태 확인
docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml ps
```

### ✅ Phase 1 체크포인트
- [ ] 백엔드에 메트릭 엔드포인트 추가 완료
- [ ] Nginx 상태 페이지 설정 완료
- [ ] 확장된 모니터링 스택 정상 실행
- [ ] Prometheus 접속 확인 (http://localhost:9090)
- [ ] Grafana 접속 확인 (http://localhost:3001)
- [ ] 모든 Exporter 서비스 Up 상태 (8개 서비스)

---

## 📈 Phase 2: Grafana 대시보드 설정 (20분)

### 🎨 Grafana 초기 설정
```bash
# Grafana 접속: http://localhost:3001
# 로그인: admin / admin123

# 1. Prometheus 데이터소스 추가
# - Configuration > Data Sources > Add data source
# - Prometheus 선택
# - URL: http://prometheus:9090
# - Save & Test
```

### 📊 기본 대시보드 생성
**Step 1: 시스템 메트릭 대시보드**
```json
{
  "dashboard": {
    "title": "Docker Compose System Metrics",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "stat", 
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"
          }
        ]
      }
    ]
  }
}
```

**Step 2: 컨테이너 메트릭 대시보드**
```bash
# Grafana에서 새 대시보드 생성
# + > Dashboard > Add new panel

# 컨테이너 CPU 사용률
container_cpu_usage_seconds_total

# 컨테이너 메모리 사용률  
container_memory_usage_bytes

# 네트워크 I/O
rate(container_network_receive_bytes_total[5m])
rate(container_network_transmit_bytes_total[5m])
```

### 🔍 확장된 메트릭 쿼리 모음
```bash
# 시스템 메트릭
node_cpu_seconds_total                    # CPU 사용률
node_memory_MemTotal_bytes               # 총 메모리
node_memory_MemAvailable_bytes           # 사용 가능 메모리
node_filesystem_size_bytes               # 디스크 크기
node_filesystem_free_bytes               # 디스크 여유 공간
node_network_receive_bytes_total         # 네트워크 수신
node_network_transmit_bytes_total        # 네트워크 송신

# 컨테이너 메트릭
container_cpu_usage_seconds_total        # 컨테이너 CPU 사용률
container_memory_usage_bytes             # 컨테이너 메모리 사용량
container_memory_max_usage_bytes         # 컨테이너 최대 메모리 사용량
container_fs_usage_bytes                 # 컨테이너 파일시스템 사용량
container_network_receive_bytes_total    # 컨테이너 네트워크 수신
container_network_transmit_bytes_total   # 컨테이너 네트워크 송신

# 애플리케이션 메트릭 (백엔드)
http_requests_total                      # 총 HTTP 요청 수
http_request_duration_ms                 # 평균 응답 시간
http_active_connections                  # 활성 연결 수
http_errors_total                        # HTTP 에러 수
nodejs_memory_usage_bytes                # Node.js 메모리 사용량

# PostgreSQL 메트릭
pg_up                                    # PostgreSQL 상태
pg_stat_database_numbackends             # 활성 연결 수
pg_stat_database_xact_commit             # 커밋된 트랜잭션
pg_stat_database_xact_rollback           # 롤백된 트랜잭션
pg_stat_database_blks_read               # 읽은 블록 수
pg_stat_database_blks_hit                # 캐시 히트 수

# Redis 메트릭
redis_up                                 # Redis 상태
redis_connected_clients                  # 연결된 클라이언트 수
redis_used_memory_bytes                  # 사용 중인 메모리
redis_keyspace_hits_total                # 키 히트 수
redis_keyspace_misses_total              # 키 미스 수
redis_commands_processed_total           # 처리된 명령 수

# Nginx 메트릭
nginx_up                                 # Nginx 상태
nginx_connections_active                 # 활성 연결 수
nginx_connections_reading                # 읽기 중인 연결
nginx_connections_writing                # 쓰기 중인 연결
nginx_connections_waiting                # 대기 중인 연결
nginx_http_requests_total                # 총 HTTP 요청 수
```

### ✅ Phase 2 체크포인트
- [ ] Prometheus 데이터소스 연결 완료
- [ ] 시스템 메트릭 대시보드 생성
- [ ] 컨테이너 메트릭 대시보드 생성
- [ ] 실시간 데이터 시각화 확인

---

## 🚨 Phase 3: 고급 대시보드 및 알림 시스템 (10분)

### 📊 고급 대시보드 생성
**Step 1: 종합 시스템 대시보드**
```bash
# Grafana에서 새 대시보드 생성: "Docker Fullstack Overview"
# 다음 패널들을 추가:

# 1. 시스템 리소스 패널
# CPU 사용률: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
# 메모리 사용률: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
# 디스크 사용률: (1 - (node_filesystem_free_bytes / node_filesystem_size_bytes)) * 100

# 2. 애플리케이션 성능 패널
# 요청 수: rate(http_requests_total[5m])
# 응답 시간: http_request_duration_ms
# 에러율: rate(http_errors_total[5m]) / rate(http_requests_total[5m]) * 100
# 활성 연결: http_active_connections

# 3. 데이터베이스 성능 패널
# PostgreSQL 연결: pg_stat_database_numbackends
# 트랜잭션 처리율: rate(pg_stat_database_xact_commit[5m])
# 캐시 히트율: pg_stat_database_blks_hit / (pg_stat_database_blks_hit + pg_stat_database_blks_read) * 100

# 4. Redis 성능 패널
# Redis 메모리 사용량: redis_used_memory_bytes
# 키 히트율: redis_keyspace_hits_total / (redis_keyspace_hits_total + redis_keyspace_misses_total) * 100
# 명령 처리율: rate(redis_commands_processed_total[5m])

# 5. 컨테이너 리소스 패널
# 컨테이너별 CPU: rate(container_cpu_usage_seconds_total[5m]) * 100
# 컨테이너별 메모리: container_memory_usage_bytes
# 네트워크 I/O: rate(container_network_receive_bytes_total[5m]), rate(container_network_transmit_bytes_total[5m])
```

**Step 2: AlertManager 설정**
```bash
# AlertManager 설정 파일 생성
cat > monitoring/alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alertmanager@example.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://localhost:5001/webhook'
    send_resolved: true
EOF

# Prometheus 알림 규칙 생성
cat > monitoring/alert-rules.yml << 'EOF'
groups:
- name: system_alerts
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
      description: "CPU usage is above 80% for more than 2 minutes"

  - alert: HighMemoryUsage
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "High memory usage detected"
      description: "Memory usage is above 90% for more than 2 minutes"

  - alert: HighDiskUsage
    expr: (1 - (node_filesystem_free_bytes / node_filesystem_size_bytes)) * 100 > 85
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High disk usage detected"
      description: "Disk usage is above 85% for more than 5 minutes"

- name: application_alerts
  rules:
  - alert: HighErrorRate
    expr: rate(http_errors_total[5m]) / rate(http_requests_total[5m]) * 100 > 5
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is above 5% for more than 1 minute"

  - alert: SlowResponseTime
    expr: http_request_duration_ms > 1000
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "Slow response time detected"
      description: "Average response time is above 1000ms for more than 2 minutes"

  - alert: DatabaseConnectionHigh
    expr: pg_stat_database_numbackends > 50
    for: 3m
    labels:
      severity: warning
    annotations:
      summary: "High database connections"
      description: "PostgreSQL has more than 50 active connections for more than 3 minutes"

  - alert: RedisMemoryHigh
    expr: redis_used_memory_bytes > 100000000  # 100MB
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High Redis memory usage"
      description: "Redis memory usage is above 100MB for more than 5 minutes"
EOF
```

### 🤖 로그 수집 및 분석 설정
```bash
# Loki 설정 파일 생성
cat > monitoring/loki-config.yml << 'EOF'
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h
EOF

# Promtail 설정 파일 생성
cat > monitoring/promtail-config.yml << 'EOF'
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
- job_name: containers
  static_configs:
  - targets:
      - localhost
    labels:
      job: containerlogs
      __path__: /var/lib/docker/containers/*/*log

  pipeline_stages:
  - json:
      expressions:
        output: log
        stream: stream
        attrs:
  - json:
      expressions:
        tag:
      source: attrs
  - regex:
      expression: (?P<container_name>(?:[^|]*))
      source: tag
  - timestamp:
      format: RFC3339Nano
      source: time
  - labels:
      stream:
      container_name:
  - output:
      source: output
EOF

# 고급 모니터링 스크립트 생성
cat > advanced-monitor.sh << 'EOF'
#!/bin/bash
# 고급 Docker Compose 모니터링 스크립트

echo "🔍 Docker Fullstack 고급 모니터링 대시보드"
echo "================================================"

while true; do
    clear
    echo "📊 $(date '+%Y-%m-%d %H:%M:%S') - 전체 시스템 상태"
    echo "================================================"
    
    # 애플리케이션 상태
    echo "🚀 애플리케이션 서비스 상태:"
    docker-compose ps --format "table {{.Name}}\t{{.State}}\t{{.Ports}}"
    echo ""
    
    # 모니터링 서비스 상태
    echo "📊 모니터링 서비스 상태:"
    docker-compose -f docker-compose.monitoring.yml ps --format "table {{.Name}}\t{{.State}}\t{{.Ports}}"
    echo ""
    
    # 리소스 사용량
    echo "💻 리소스 사용량 (상위 5개):"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" | head -6
    echo ""
    
    # 애플리케이션 메트릭
    echo "📈 애플리케이션 메트릭:"
    if curl -s http://localhost:5000/metrics > /dev/null 2>&1; then
        echo "✅ Backend 메트릭 수집 중"
        REQUESTS=$(curl -s http://localhost:5000/metrics | grep "http_requests_total" | awk '{print $2}')
        ERRORS=$(curl -s http://localhost:5000/metrics | grep "http_errors_total" | awk '{print $2}')
        echo "   총 요청: ${REQUESTS:-0}, 에러: ${ERRORS:-0}"
    else
        echo "❌ Backend 메트릭 수집 실패"
    fi
    echo ""
    
    # 데이터베이스 연결 확인
    echo "🗄️ 데이터베이스 상태:"
    if docker exec fullstack-db pg_isready -U postgres > /dev/null 2>&1; then
        echo "✅ PostgreSQL 정상"
        CONNECTIONS=$(docker exec fullstack-db psql -U postgres -t -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null | xargs)
        echo "   활성 연결: ${CONNECTIONS:-0}"
    else
        echo "❌ PostgreSQL 연결 실패"
    fi
    
    if docker exec fullstack-cache redis-cli ping > /dev/null 2>&1; then
        echo "✅ Redis 정상"
        MEMORY=$(docker exec fullstack-cache redis-cli info memory | grep "used_memory_human" | cut -d: -f2 | tr -d '\r')
        echo "   메모리 사용량: ${MEMORY:-N/A}"
    else
        echo "❌ Redis 연결 실패"
    fi
    echo ""
    
    # 모니터링 접속 정보
    echo "🔗 모니터링 대시보드 접속:"
    echo "   📊 Grafana: http://localhost:3001 (admin/admin123)"
    echo "   🔍 Prometheus: http://localhost:9090"
    echo "   🚨 AlertManager: http://localhost:9093"
    echo "   📈 cAdvisor: http://localhost:8080"
    echo ""
    
    echo "⏰ 10초 후 새로고침... (Ctrl+C로 종료)"
    sleep 10
done
EOF

chmod +x advanced-monitor.sh
```

### ✅ Phase 3 체크포인트
- [ ] 종합 시스템 대시보드 생성 완료
- [ ] AlertManager 알림 규칙 설정 완료
- [ ] Loki + Promtail 로그 수집 시스템 구축
- [ ] 고급 모니터링 스크립트 실행
- [ ] 모든 메트릭 수집 및 시각화 확인

---

## 🎯 Phase 4: 고급 모니터링 기능 (5분)

### 📊 커스텀 메트릭 추가
**Backend 애플리케이션에 메트릭 엔드포인트 추가**
```javascript
// backend/src/metrics.js
const express = require('express');
const router = express.Router();

let requestCount = 0;
let responseTime = [];

// 미들웨어로 메트릭 수집
const collectMetrics = (req, res, next) => {
  const start = Date.now();
  requestCount++;
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    responseTime.push(duration);
  });
  
  next();
};

// 메트릭 엔드포인트
router.get('/metrics', (req, res) => {
  const avgResponseTime = responseTime.length > 0 
    ? responseTime.reduce((a, b) => a + b) / responseTime.length 
    : 0;
    
  res.set('Content-Type', 'text/plain');
  res.send(`
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total ${requestCount}

# HELP http_request_duration_ms Average HTTP request duration
# TYPE http_request_duration_ms gauge  
http_request_duration_ms ${avgResponseTime}
  `);
});

module.exports = { router, collectMetrics };
```

### 🔍 로그 분석 대시보드
```bash
# 로그 패턴 분석을 위한 간단한 스크립트
docker-compose logs backend | grep ERROR | wc -l  # 에러 개수
docker-compose logs backend | grep -E "2[0-9]{2}-" | tail -10  # 최근 로그
```

### ✅ Phase 4 체크포인트
- [ ] 커스텀 메트릭 엔드포인트 추가
- [ ] 애플리케이션 메트릭 Grafana에서 확인
- [ ] 로그 분석 대시보드 생성
- [ ] 전체 모니터링 시스템 통합 테스트

---

## 🏆 실습 완료 및 정리

### 📊 구축된 모니터링 시스템
```mermaid
graph LR
    A[애플리케이션<br/>메트릭] --> D[Prometheus]
    B[시스템<br/>메트릭] --> D
    C[컨테이너<br/>메트릭] --> D
    
    D --> E[Grafana<br/>대시보드]
    D --> F[알림<br/>시스템]
    
    E --> G[📊 시각화]
    F --> H[🚨 알림]
    
    style D fill:#e3f2fd
    style E fill:#e8f5e8
    style F fill:#fff3e0
```

### ✅ 최종 체크리스트
- [ ] **확장된 모니터링 스택**: Prometheus + Grafana + 8개 Exporters + Loki + AlertManager
- [ ] **종합 대시보드**: 시스템, 컨테이너, 애플리케이션, DB, 캐시 메트릭 시각화
- [ ] **고급 알림 시스템**: 8개 알림 규칙 + AlertManager 통합
- [ ] **로그 수집**: Loki + Promtail로 컨테이너 로그 중앙화
- [ ] **실시간 모니터링**: 고급 모니터링 스크립트 백그라운드 실행
- [ ] **커스텀 메트릭**: 백엔드 애플리케이션 비즈니스 메트릭 수집

### 🎯 모니터링 접속 정보
```bash
# 주요 서비스 접속 URL
echo "📊 Grafana: http://localhost:3001 (admin/admin123)"
echo "🔍 Prometheus: http://localhost:9090"
echo "🚨 AlertManager: http://localhost:9093"
echo "📈 cAdvisor: http://localhost:8080"
echo "🖥️ Node Exporter: http://localhost:9100/metrics"
echo "📊 Loki: http://localhost:3100"

# Exporter 메트릭 엔드포인트
echo ""
echo "🔍 Exporter 메트릭 엔드포인트:"
echo "   PostgreSQL: http://localhost:9187/metrics"
echo "   Redis: http://localhost:9121/metrics"
echo "   Nginx: http://localhost:9113/metrics"
echo "   Backend App: http://localhost:5000/metrics"

# 실시간 모니터링 스크립트 실행
echo ""
echo "🚀 고급 모니터링 스크립트 실행:"
echo "   ./advanced-monitor.sh"
```

### 🧹 정리 명령어
```bash
# 전체 스택 중지 (애플리케이션 + 모니터링)
docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml down

# 볼륨 포함 완전 정리
docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml down -v

# 모니터링만 중지
docker-compose -f docker-compose.monitoring.yml down

# 백그라운드 스크립트 종료
pkill -f advanced-monitor.sh
pkill -f monitor.sh

# 사용하지 않는 도커 리소스 정리
docker system prune -f
docker volume prune -f
```

---

## 📝 실습 마무리

### ✅ Lab 2 성과
- [ ] Docker Compose 환경에서 완전한 모니터링 시스템 구축
- [ ] Prometheus를 통한 메트릭 수집 및 저장
- [ ] Grafana를 통한 시각화 대시보드 생성
- [ ] 실시간 알림 시스템 구성
- [ ] 커스텀 메트릭 및 로그 분석 기능 구현

### 🎯 Week 2 연결고리
- **주제**: Kubernetes 모니터링 (Prometheus Operator)
- **연결**: Docker Compose 모니터링 → Kubernetes 네이티브 모니터링
- **준비사항**: 오늘 구축한 모니터링 개념을 Kubernetes 환경으로 확장

---

<div align="center">

**📊 Docker Compose 모니터링 마스터 완성! 📊**

*Prometheus + Grafana로 완벽한 관측성 확보*

**다음**: [Week 2 - Kubernetes 모니터링](../../week_02/README.md)

</div>