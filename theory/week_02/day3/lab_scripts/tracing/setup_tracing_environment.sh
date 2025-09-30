#!/bin/bash

# Week 2 Day 3 Lab 2: OpenTelemetry & Jaeger 환경 설정
# 사용법: ./setup_tracing_environment.sh

echo "=== OpenTelemetry & Jaeger 분산 추적 환경 설정 시작 ==="

# 작업 디렉토리 생성
echo "1. 작업 디렉토리 생성 중..."
mkdir -p ~/docker-tracing-lab
cd ~/docker-tracing-lab

# Docker Compose 파일 생성
echo "2. Docker Compose 파일 생성 중..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Jaeger - 분산 추적
  jaeger:
    image: jaegertracing/all-in-one:1.50
    container_name: jaeger
    ports:
      - "16686:16686"  # Jaeger UI
      - "14268:14268"  # Jaeger collector HTTP
      - "14250:14250"  # Jaeger collector gRPC
      - "6831:6831/udp"  # Jaeger agent UDP
    environment:
      - COLLECTOR_OTLP_ENABLED=true
      - COLLECTOR_ZIPKIN_HOST_PORT=:9411
    networks:
      - observability

  # OTEL Collector
  otel-collector:
    image: otel/opentelemetry-collector-contrib:0.88.0
    container_name: otel-collector
    command: ["--config=/etc/otel-collector-config.yaml"]
    volumes:
      - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml
    ports:
      - "4317:4317"   # OTLP gRPC receiver
      - "4318:4318"   # OTLP HTTP receiver
      - "8889:8889"   # Prometheus metrics
    depends_on:
      - jaeger
      - prometheus
    networks:
      - observability

  # Prometheus
  prometheus:
    image: prom/prometheus:v2.47.0
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - observability

  # Grafana
  grafana:
    image: grafana/grafana:10.1.0
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    networks:
      - observability

  # PostgreSQL
  postgres:
    image: postgres:15
    container_name: postgres
    environment:
      - POSTGRES_DB=userdb
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - observability

  # Redis
  redis:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6379:6379"
    networks:
      - observability

networks:
  observability:
    driver: bridge

volumes:
  grafana-data:
EOF

# OpenTelemetry Collector 설정
echo "3. OpenTelemetry Collector 설정 생성 중..."
cat > otel-collector-config.yaml << 'EOF'
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
  memory_limiter:
    limit_mib: 512

exporters:
  jaeger:
    endpoint: jaeger:14250
    tls:
      insecure: true
  
  prometheus:
    endpoint: "0.0.0.0:8889"
    
  logging:
    loglevel: debug

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [jaeger, logging]
    
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [prometheus, logging]
EOF

# Prometheus 설정
echo "4. Prometheus 설정 생성 중..."
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'otel-collector'
    static_configs:
      - targets: ['otel-collector:8889']

  - job_name: 'api-gateway'
    static_configs:
      - targets: ['api-gateway:3001']
    metrics_path: '/metrics'

  - job_name: 'user-service'
    static_configs:
      - targets: ['user-service:3002']
    metrics_path: '/metrics'
EOF

# PostgreSQL 초기화 스크립트
echo "5. PostgreSQL 초기화 스크립트 생성 중..."
cat > init.sql << 'EOF'
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Brown', 'charlie@example.com'),
('Diana Prince', 'diana@example.com'),
('Eve Wilson', 'eve@example.com');
EOF

echo ""
echo "=== OpenTelemetry & Jaeger 환경 설정 완료 ==="
echo ""
echo "다음 단계:"
echo "1. 애플리케이션 배포: ./deploy_traced_apps.sh"
echo "2. Grafana 대시보드 설정: ./setup_grafana_dashboards.sh"
echo "3. 분산 추적 테스트: ./test_distributed_tracing.sh"
echo ""
echo "접속 정보:"
echo "- Jaeger UI: http://localhost:16686"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- Prometheus: http://localhost:9090"