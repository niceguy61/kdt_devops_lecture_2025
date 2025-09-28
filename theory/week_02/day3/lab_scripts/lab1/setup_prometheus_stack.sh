#!/bin/bash

# Week 2 Day 3 Lab 1: Prometheus 모니터링 스택 자동 구축
# 사용법: ./setup_prometheus_stack.sh

echo "=== Prometheus 모니터링 스택 자동 구축 시작 ==="

# 1. 디렉토리 구조 생성
echo "1. 디렉토리 구조 생성 중..."
mkdir -p config/{prometheus,grafana,alertmanager}
mkdir -p data/{prometheus,grafana}

# 2. Prometheus 설정 파일 생성
echo "2. Prometheus 설정 파일 생성 중..."
cat > config/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'mysql-exporter'
    static_configs:
      - targets: ['mysql-exporter:9104']
EOF

# 3. 알림 규칙 생성
echo "3. 알림 규칙 생성 중..."
cat > config/prometheus/alert_rules.yml << 'EOF'
groups:
  - name: container_alerts
    rules:
      - alert: HighCPUUsage
        expr: rate(container_cpu_usage_seconds_total[5m]) * 100 > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "Container {{ $labels.name }} CPU usage is above 80%"

      - alert: HighMemoryUsage
        expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) * 100 > 90
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage detected"
          description: "Container {{ $labels.name }} memory usage is above 90%"

      - alert: ContainerDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Container is down"
          description: "Container {{ $labels.instance }} has been down for more than 1 minute"
EOF

# 4. Prometheus 컨테이너 실행
echo "4. Prometheus 컨테이너 실행 중..."
docker run -d \
  --name prometheus \
  --restart=unless-stopped \
  -p 9090:9090 \
  -v $(pwd)/config/prometheus:/etc/prometheus \
  -v prometheus-data:/prometheus \
  --memory=1g \
  prom/prometheus:latest \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.console.templates=/etc/prometheus/consoles \
  --storage.tsdb.retention.time=30d \
  --web.enable-lifecycle

# 5. 메트릭 수집기 배포
echo "5. 메트릭 수집기 배포 중..."

# cAdvisor
docker run -d \
  --name cadvisor \
  --restart=unless-stopped \
  -p 8080:8080 \
  -v /:/rootfs:ro \
  -v /var/run:/var/run:ro \
  -v /sys:/sys:ro \
  -v /var/lib/docker/:/var/lib/docker:ro \
  -v /dev/disk/:/dev/disk:ro \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:latest

# Node Exporter
docker run -d \
  --name node-exporter \
  --restart=unless-stopped \
  -p 9100:9100 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /:/rootfs:ro \
  --pid=host \
  prom/node-exporter:latest \
  --path.procfs=/host/proc \
  --path.rootfs=/rootfs \
  --path.sysfs=/host/sys \
  --collector.filesystem.mount-points-exclude='^/(sys|proc|dev|host|etc)($$|/)'

# MySQL Exporter (기존 MySQL 컨테이너가 있는 경우)
if docker ps | grep -q mysql-wordpress; then
    docker run -d \
      --name mysql-exporter \
      --restart=unless-stopped \
      -p 9104:9104 \
      -e DATA_SOURCE_NAME="wpuser:wppassword@(mysql-wordpress:3306)/" \
      --link mysql-wordpress:mysql-wordpress \
      prom/mysqld-exporter:latest
    echo "✅ MySQL Exporter 배포 완료"
else
    echo "⚠️ MySQL 컨테이너를 찾을 수 없습니다. MySQL Exporter를 건너뜁니다."
fi

# 6. 서비스 상태 확인
echo "6. 서비스 상태 확인 중..."
sleep 10

echo "배포된 모니터링 서비스:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(prometheus|cadvisor|node-exporter|mysql-exporter)"

echo ""
echo "=== Prometheus 모니터링 스택 구축 완료 ==="
echo ""
echo "접속 정보:"
echo "- Prometheus: http://localhost:9090"
echo "- cAdvisor: http://localhost:8080"
echo "- Node Exporter: http://localhost:9100/metrics"
echo ""
echo "다음 단계: ./setup_grafana_dashboard.sh 실행"