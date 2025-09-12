# Session 7: 컨테이너 모니터링과 로깅

## 📍 교과과정에서의 위치
이 세션은 **Week 2 > Day 3 > Session 7**로, 컨테이너 관리와 스토리지 구성을 마친 후 운영 환경에서 필수적인 모니터링과 로깅 시스템을 구축합니다.

## 학습 목표 (5분)
- **컨테이너 모니터링** 시스템 구축 및 **메트릭 수집**
- **로그 드라이버** 활용 및 **중앙 집중식 로깅** 구현
- **알림 시스템** 구성 및 **운영 대시보드** 구축

## 1. 이론: 컨테이너 관찰성 (Observability) (20분)

### 관찰성의 3대 요소

```mermaid
graph TB
    subgraph "Observability Pillars"
        A[Metrics] --> D[시계열 데이터]
        B[Logs] --> E[이벤트 기록]
        C[Traces] --> F[요청 추적]
    end
    
    subgraph "Docker Monitoring"
        D --> G[CPU, Memory, Network]
        E --> H[Container Logs]
        F --> I[Application Traces]
    end
    
    subgraph "Tools & Solutions"
        G --> J[Prometheus + Grafana]
        H --> K[ELK Stack]
        I --> L[Jaeger, Zipkin]
    end
```

### 모니터링 메트릭 분류

```
시스템 메트릭:
├── CPU 사용률 (%)
├── 메모리 사용량 (MB/GB)
├── 디스크 I/O (IOPS, MB/s)
├── 네트워크 I/O (packets/s, MB/s)
└── 파일 디스크립터 수

컨테이너 메트릭:
├── 컨테이너 상태 (running/stopped/failed)
├── 재시작 횟수
├── 이미지 크기
├── 볼륨 사용량
└── 네트워크 연결 수

애플리케이션 메트릭:
├── 응답 시간 (ms)
├── 처리량 (requests/s)
├── 에러율 (%)
├── 큐 길이
└── 비즈니스 메트릭

인프라 메트릭:
├── 호스트 리소스
├── 네트워크 지연시간
├── 스토리지 성능
├── 서비스 가용성
└── 보안 이벤트
```

### 로그 레벨 및 구조화

```
로그 레벨 체계:

FATAL (0): 시스템 중단
├── 복구 불가능한 오류
├── 즉시 대응 필요
└── 예: 데이터베이스 연결 실패

ERROR (1): 오류 발생
├── 기능 동작 실패
├── 빠른 대응 필요
└── 예: API 호출 실패

WARN (2): 경고
├── 잠재적 문제
├── 모니터링 필요
└── 예: 메모리 사용량 증가

INFO (3): 정보
├── 일반적인 동작
├── 비즈니스 로직 추적
└── 예: 사용자 로그인

DEBUG (4): 디버그
├── 상세한 실행 정보
├── 개발/테스트 환경
└── 예: 변수 값, 함수 호출

구조화된 로그 형식:
{
  "timestamp": "2024-01-01T12:00:00Z",
  "level": "INFO",
  "service": "web-api",
  "container_id": "abc123",
  "message": "User login successful",
  "user_id": "12345",
  "ip_address": "192.168.1.100",
  "response_time": 150
}
```

## 2. 실습: Docker 기본 모니터링 (15분)

### 실시간 메트릭 수집

```bash
# 모니터링 대상 컨테이너 실행
docker run -d --name web-server nginx:alpine
docker run -d --name database -e MYSQL_ROOT_PASSWORD=secret mysql:8.0
docker run -d --name cache redis:alpine

# 기본 모니터링 명령어
echo "=== Basic Docker Monitoring ==="

# 실시간 통계
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# 개별 컨테이너 상세 정보
docker inspect web-server --format '{{json .State}}' | jq

# 시스템 전체 정보
docker system df
docker system events --since "1m" &
EVENTS_PID=$!

sleep 10
kill $EVENTS_PID
```

### 커스텀 모니터링 스크립트

```bash
# 고급 모니터링 스크립트 생성
cat > container-monitor.sh << 'EOF'
#!/bin/bash

LOG_FILE="/tmp/container-monitor.log"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEM=80

# 로그 함수
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# 메트릭 수집 함수
collect_metrics() {
    local container=$1
    
    # CPU 사용률 추출
    local cpu_percent=$(docker stats --no-stream --format "{{.CPUPerc}}" $container | sed 's/%//')
    
    # 메모리 사용률 추출
    local mem_usage=$(docker stats --no-stream --format "{{.MemPerc}}" $container | sed 's/%//')
    
    # 네트워크 I/O
    local net_io=$(docker stats --no-stream --format "{{.NetIO}}" $container)
    
    # 블록 I/O
    local block_io=$(docker stats --no-stream --format "{{.BlockIO}}" $container)
    
    # 컨테이너 상태
    local status=$(docker inspect $container --format '{{.State.Status}}')
    
    # 메트릭 로깅
    log_message "METRICS - Container: $container, CPU: ${cpu_percent}%, Memory: ${mem_usage}%, Status: $status"
    
    # 알림 체크
    if (( $(echo "$cpu_percent > $ALERT_THRESHOLD_CPU" | bc -l) )); then
        log_message "ALERT - High CPU usage in $container: ${cpu_percent}%"
    fi
    
    if (( $(echo "$mem_usage > $ALERT_THRESHOLD_MEM" | bc -l) )); then
        log_message "ALERT - High memory usage in $container: ${mem_usage}%"
    fi
}

# 헬스체크 함수
health_check() {
    local container=$1
    
    # 컨테이너 실행 상태 확인
    if ! docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
        log_message "ALERT - Container $container is not running"
        return 1
    fi
    
    # 프로세스 확인
    local process_count=$(docker exec $container ps aux | wc -l)
    log_message "HEALTH - Container $container has $process_count processes"
    
    return 0
}

# 메인 모니터링 루프
log_message "Starting container monitoring..."

for i in {1..10}; do
    echo "=== Monitoring Cycle $i ==="
    
    for container in $(docker ps --format "{{.Names}}"); do
        collect_metrics $container
        health_check $container
    done
    
    echo "Cycle $i completed, sleeping..."
    sleep 5
done

log_message "Monitoring completed"
EOF

chmod +x container-monitor.sh

# 모니터링 실행
./container-monitor.sh

# 로그 확인
echo "=== Monitoring Log ==="
tail -20 /tmp/container-monitor.log
```

### 리소스 사용량 분석

```bash
# 리소스 분석 스크립트
cat > resource-analyzer.sh << 'EOF'
#!/bin/bash

echo "=== Container Resource Analysis ==="

# 컨테이너별 리소스 사용량 수집
declare -A cpu_usage
declare -A mem_usage
declare -A net_io

for container in $(docker ps --format "{{.Names}}"); do
    # 5초간 평균 사용량 측정
    total_cpu=0
    total_mem=0
    
    for i in {1..5}; do
        cpu=$(docker stats --no-stream --format "{{.CPUPerc}}" $container | sed 's/%//')
        mem=$(docker stats --no-stream --format "{{.MemPerc}}" $container | sed 's/%//')
        
        total_cpu=$(echo "$total_cpu + $cpu" | bc -l)
        total_mem=$(echo "$total_mem + $mem" | bc -l)
        
        sleep 1
    done
    
    avg_cpu=$(echo "scale=2; $total_cpu / 5" | bc -l)
    avg_mem=$(echo "scale=2; $total_mem / 5" | bc -l)
    
    cpu_usage[$container]=$avg_cpu
    mem_usage[$container]=$avg_mem
    
    echo "Container: $container"
    echo "  Average CPU: ${avg_cpu}%"
    echo "  Average Memory: ${avg_mem}%"
    echo ""
done

# 리소스 사용량 순위
echo "=== Resource Usage Ranking ==="
echo "Top CPU consumers:"
for container in "${!cpu_usage[@]}"; do
    echo "${cpu_usage[$container]} $container"
done | sort -nr | head -3

echo ""
echo "Top Memory consumers:"
for container in "${!mem_usage[@]}"; do
    echo "${mem_usage[$container]} $container"
done | sort -nr | head -3
EOF

chmod +x resource-analyzer.sh
./resource-analyzer.sh
```

## 3. 실습: 로그 드라이버 및 중앙 집중식 로깅 (15분)

### 로그 드라이버 설정

```bash
# 다양한 로그 드라이버로 컨테이너 실행
echo "=== Log Driver Configuration ==="

# JSON 파일 로그 드라이버 (기본)
docker run -d --name app-json \
    --log-driver json-file \
    --log-opt max-size=10m \
    --log-opt max-file=3 \
    alpine sh -c 'while true; do echo "JSON log: $(date)"; sleep 2; done'

# Syslog 드라이버
docker run -d --name app-syslog \
    --log-driver syslog \
    --log-opt syslog-address=udp://localhost:514 \
    alpine sh -c 'while true; do echo "Syslog: $(date)"; sleep 2; done' || echo "Syslog not available"

# 로그 없음 (성능 최적화)
docker run -d --name app-none \
    --log-driver none \
    alpine sh -c 'while true; do echo "No logs: $(date)"; sleep 2; done'

# 로그 확인
echo "JSON file logs:"
docker logs app-json | head -5

echo "Syslog logs (if available):"
docker logs app-syslog | head -5 || echo "Syslog logs not accessible via docker logs"

echo "No logs:"
docker logs app-none || echo "No logs available (expected)"
```

### ELK Stack 구성

```bash
# ELK Stack 네트워크 생성
docker network create elk-network

# Elasticsearch
docker run -d --name elasticsearch \
    --network elk-network \
    -p 9200:9200 \
    -e "discovery.type=single-node" \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    elasticsearch:7.17.0

# Kibana
docker run -d --name kibana \
    --network elk-network \
    -p 5601:5601 \
    -e "ELASTICSEARCH_HOSTS=http://elasticsearch:9200" \
    kibana:7.17.0

# Logstash 설정 파일 생성
mkdir -p elk-config
cat > elk-config/logstash.conf << 'EOF'
input {
  beats {
    port => 5044
  }
  tcp {
    port => 5000
    codec => json
  }
}

filter {
  if [docker] {
    mutate {
      add_field => { "container_name" => "%{[docker][container][name]}" }
    }
  }
  
  date {
    match => [ "timestamp", "ISO8601" ]
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "docker-logs-%{+YYYY.MM.dd}"
  }
  
  stdout {
    codec => rubydebug
  }
}
EOF

# Logstash
docker run -d --name logstash \
    --network elk-network \
    -p 5000:5000 \
    -p 5044:5044 \
    -v $(pwd)/elk-config/logstash.conf:/usr/share/logstash/pipeline/logstash.conf \
    logstash:7.17.0

# 로그 생성 애플리케이션
docker run -d --name log-generator \
    --network elk-network \
    --log-driver json-file \
    alpine sh -c '
        counter=1
        while true; do
            level=$(shuf -n1 -e INFO WARN ERROR DEBUG)
            echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"$level\",\"message\":\"Log entry $counter\",\"service\":\"log-generator\"}"
            counter=$((counter + 1))
            sleep 1
        done
    '

echo "ELK Stack is starting up... (this may take a few minutes)"
echo "Elasticsearch: http://localhost:9200"
echo "Kibana: http://localhost:5601"
```

### Fluentd 로그 수집

```bash
# Fluentd 설정 파일
mkdir -p fluentd-config
cat > fluentd-config/fluent.conf << 'EOF'
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<match docker.**>
  @type elasticsearch
  host elasticsearch
  port 9200
  index_name docker-logs
  type_name _doc
  
  <buffer>
    flush_interval 1s
  </buffer>
</match>

<match **>
  @type stdout
</match>
EOF

# Fluentd 컨테이너
docker run -d --name fluentd \
    --network elk-network \
    -p 24224:24224 \
    -v $(pwd)/fluentd-config:/fluentd/etc \
    fluent/fluentd:v1.14-1

# Fluentd 로그 드라이버로 애플리케이션 실행
docker run -d --name app-fluentd \
    --log-driver fluentd \
    --log-opt fluentd-address=localhost:24224 \
    --log-opt tag=docker.app \
    alpine sh -c '
        while true; do
            echo "Fluentd log: $(date) - Random number: $RANDOM"
            sleep 3
        done
    '

# 로그 확인
sleep 10
docker logs fluentd | tail -10
```

## 4. 실습: Prometheus와 Grafana 모니터링 (10분)

### Prometheus 설정

```bash
# Prometheus 설정 파일
mkdir -p prometheus-config
cat > prometheus-config/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

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
EOF

# 모니터링 네트워크
docker network create monitoring

# Prometheus
docker run -d --name prometheus \
    --network monitoring \
    -p 9090:9090 \
    -v $(pwd)/prometheus-config/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus

# cAdvisor (컨테이너 메트릭)
docker run -d --name cadvisor \
    --network monitoring \
    -p 8080:8080 \
    --volume=/:/rootfs:ro \
    --volume=/var/run:/var/run:ro \
    --volume=/sys:/sys:ro \
    --volume=/var/lib/docker/:/var/lib/docker:ro \
    --volume=/dev/disk/:/dev/disk:ro \
    gcr.io/cadvisor/cadvisor:latest

# Node Exporter (시스템 메트릭)
docker run -d --name node-exporter \
    --network monitoring \
    -p 9100:9100 \
    prom/node-exporter

# Grafana
docker run -d --name grafana \
    --network monitoring \
    -p 3000:3000 \
    -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
    grafana/grafana

echo "Monitoring stack is starting up..."
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "cAdvisor: http://localhost:8080"
```

### 커스텀 메트릭 수집

```bash
# 애플리케이션 메트릭 생성기
cat > metrics-generator.py << 'EOF'
#!/usr/bin/env python3
import time
import random
import json
from http.server import HTTPServer, BaseHTTPRequestHandler

class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/metrics':
            # Prometheus 형식 메트릭
            metrics = f"""
# HELP app_requests_total Total number of requests
# TYPE app_requests_total counter
app_requests_total {random.randint(1000, 5000)}

# HELP app_response_time_seconds Response time in seconds
# TYPE app_response_time_seconds histogram
app_response_time_seconds_bucket{{le="0.1"}} {random.randint(10, 50)}
app_response_time_seconds_bucket{{le="0.5"}} {random.randint(50, 100)}
app_response_time_seconds_bucket{{le="1.0"}} {random.randint(100, 200)}
app_response_time_seconds_bucket{{le="+Inf"}} {random.randint(200, 300)}

# HELP app_memory_usage_bytes Memory usage in bytes
# TYPE app_memory_usage_bytes gauge
app_memory_usage_bytes {random.randint(50000000, 100000000)}
"""
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(metrics.encode())
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8000), MetricsHandler)
    print("Metrics server starting on port 8000...")
    server.serve_forever()
EOF

# 메트릭 생성기 컨테이너
docker run -d --name metrics-app \
    --network monitoring \
    -p 8000:8000 \
    -v $(pwd)/metrics-generator.py:/app/metrics.py \
    python:3.9-alpine sh -c 'cd /app && python metrics.py'

# 메트릭 확인
sleep 5
curl -s http://localhost:8000/metrics | head -10
```

## 5. 실습: 알림 및 대시보드 구성 (10분)

### 알림 시스템 구성

```bash
# Alertmanager 설정
mkdir -p alertmanager-config
cat > alertmanager-config/alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@example.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://webhook-receiver:8080/webhook'
EOF

# Prometheus 알림 규칙
cat > prometheus-config/alert-rules.yml << 'EOF'
groups:
- name: container.rules
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
    expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) * 100 > 80
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage detected"
      description: "Container {{ $labels.name }} memory usage is above 80%"
EOF

# Alertmanager
docker run -d --name alertmanager \
    --network monitoring \
    -p 9093:9093 \
    -v $(pwd)/alertmanager-config/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
    prom/alertmanager

# 웹훅 수신기 (알림 테스트용)
cat > webhook-receiver.py << 'EOF'
#!/usr/bin/env python3
import json
from http.server import HTTPServer, BaseHTTPRequestHandler

class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            alert_data = json.loads(post_data.decode('utf-8'))
            print(f"ALERT RECEIVED: {json.dumps(alert_data, indent=2)}")
        except:
            print(f"RAW ALERT: {post_data.decode('utf-8')}")
        
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8080), WebhookHandler)
    print("Webhook receiver starting on port 8080...")
    server.serve_forever()
EOF

docker run -d --name webhook-receiver \
    --network monitoring \
    -v $(pwd)/webhook-receiver.py:/app/webhook.py \
    python:3.9-alpine sh -c 'cd /app && python webhook.py'
```

### 대시보드 자동화

```bash
# Grafana 대시보드 설정 스크립트
cat > setup-dashboard.sh << 'EOF'
#!/bin/bash

# Grafana API를 통한 대시보드 설정
GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASS="admin"

# 데이터소스 추가
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }' \
  http://admin:admin@localhost:3000/api/datasources

# 간단한 대시보드 생성
cat > dashboard.json << 'DASHBOARD_EOF'
{
  "dashboard": {
    "title": "Docker Container Monitoring",
    "panels": [
      {
        "title": "Container CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total[5m]) * 100",
            "legendFormat": "{{ name }}"
          }
        ]
      },
      {
        "title": "Container Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "container_memory_usage_bytes / 1024 / 1024",
            "legendFormat": "{{ name }}"
          }
        ]
      }
    ]
  }
}
DASHBOARD_EOF

# 대시보드 업로드
curl -X POST \
  -H "Content-Type: application/json" \
  -d @dashboard.json \
  http://admin:admin@localhost:3000/api/dashboards/db

echo "Dashboard setup completed"
EOF

chmod +x setup-dashboard.sh

# 대시보드 설정 (Grafana가 완전히 시작된 후)
sleep 30
./setup-dashboard.sh || echo "Dashboard setup will be available once Grafana is fully started"
```

## 6. Q&A 및 정리 (5분)

### 모니터링 시스템 검증

```bash
# 모니터링 스택 상태 확인
echo "=== Monitoring Stack Status ==="

# 모든 모니터링 컨테이너 상태
docker ps --filter network=monitoring --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --filter network=elk-network --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 서비스 헬스체크
echo ""
echo "Service Health Checks:"

# Prometheus
curl -s http://localhost:9090/-/healthy && echo "✓ Prometheus is healthy" || echo "✗ Prometheus is not responding"

# Grafana
curl -s http://localhost:3000/api/health && echo "✓ Grafana is healthy" || echo "✗ Grafana is not responding"

# Elasticsearch
curl -s http://localhost:9200/_cluster/health && echo "✓ Elasticsearch is healthy" || echo "✗ Elasticsearch is not responding"

# 메트릭 수집 확인
echo ""
echo "Metrics Collection:"
curl -s http://localhost:9090/api/v1/query?query=up | jq '.data.result | length' && echo "targets are being monitored"

# 로그 수집 확인
echo ""
echo "Log Collection:"
docker logs log-generator | tail -3
docker logs app-fluentd | tail -3

# 최종 정리 가이드
cat > monitoring-summary.md << 'EOF'
# Docker Monitoring & Logging Summary

## 구축된 시스템
1. **메트릭 수집**: Prometheus + cAdvisor + Node Exporter
2. **로그 수집**: ELK Stack + Fluentd
3. **시각화**: Grafana 대시보드
4. **알림**: Alertmanager + Webhook

## 접속 정보
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)
- Kibana: http://localhost:5601
- Elasticsearch: http://localhost:9200
- Alertmanager: http://localhost:9093

## 주요 메트릭
- CPU 사용률: container_cpu_usage_seconds_total
- 메모리 사용량: container_memory_usage_bytes
- 네트워크 I/O: container_network_*
- 디스크 I/O: container_fs_*

## 로그 드라이버
- json-file: 기본, 로테이션 지원
- fluentd: 중앙 집중식 수집
- syslog: 시스템 로그 통합
- none: 성능 최적화

## 운영 권장사항
1. 로그 로테이션 설정 필수
2. 메트릭 보존 기간 정책 수립
3. 알림 임계값 환경별 조정
4. 대시보드 정기적 업데이트
EOF

echo "Monitoring summary created: monitoring-summary.md"
echo ""
echo "✓ Monitoring and logging system setup completed!"
```

## 💡 핵심 키워드
- **관찰성**: Metrics, Logs, Traces
- **모니터링 스택**: Prometheus, Grafana, ELK Stack
- **로그 드라이버**: json-file, fluentd, syslog
- **알림 시스템**: Alertmanager, 임계값, 웹훅

## 📚 참고 자료
- [Docker 로깅 드라이버](https://docs.docker.com/config/containers/logging/)
- [Prometheus 모니터링](https://prometheus.io/docs/)
- [ELK Stack 가이드](https://www.elastic.co/guide/)

## 🔧 실습 체크리스트
- [ ] Docker 기본 모니터링 구현
- [ ] 로그 드라이버 설정 및 활용
- [ ] ELK Stack 중앙 집중식 로깅
- [ ] Prometheus + Grafana 메트릭 수집
- [ ] 알림 시스템 구성 및 테스트
