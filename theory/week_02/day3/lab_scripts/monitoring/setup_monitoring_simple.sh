#!/bin/bash

# Week 2 Day 3 Lab 1: 간소화된 모니터링 스택 구축 스크립트
# 사용법: ./setup_monitoring_simple.sh

echo "=== 간소화된 모니터링 스택 구축 시작 ==="

mkdir -p monitoring/{grafana/provisioning/{dashboards,datasources},prometheus}

echo "1. Prometheus 설정 파일 생성..."

cat > monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'app'
    static_configs:
      - targets: ['host.docker.internal:3000']
    metrics_path: '/metrics'
    scrape_interval: 10s
EOF

echo "✅ Prometheus 설정 완료"

echo ""
echo "2. Grafana 데이터소스 설정..."

cat > monitoring/grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

echo "✅ Grafana 데이터소스 설정 완료"

echo ""
echo "3. Docker Compose 설정..."

cat > monitoring/docker-compose.monitoring.yml << 'EOF'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=7d'
      - '--web.enable-lifecycle'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    restart: unless-stopped
    depends_on:
      - prometheus

volumes:
  prometheus-data:
  grafana-data:

networks:
  default:
    name: monitoring-network
EOF

echo "✅ Docker Compose 설정 완료"

echo ""
echo "4. 모니터링 스택 시작..."

cd monitoring

docker-compose -f docker-compose.monitoring.yml down -v > /dev/null 2>&1
docker-compose -f docker-compose.monitoring.yml up -d

echo "서비스 시작 중..."
sleep 15

echo ""
echo "5. 서비스 상태 확인..."
docker-compose -f docker-compose.monitoring.yml ps

echo ""
echo "6. 연결 테스트..."

if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "✅ Prometheus 정상 동작 (http://localhost:9090)"
else
    echo "❌ Prometheus 연결 실패"
fi

if curl -s http://localhost:3001/api/health > /dev/null; then
    echo "✅ Grafana 정상 동작 (http://localhost:3001)"
else
    echo "❌ Grafana 연결 실패"
fi

echo ""
echo "7. 메트릭 수집 확인..."

sleep 5
TARGETS_UP=$(curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health=="up") | .labels.job' 2>/dev/null | wc -l)
echo "활성 타겟 수: ${TARGETS_UP}개"

cd ..

echo ""
echo "=== 간소화된 모니터링 스택 구축 완료 ==="
echo ""
echo "접속 정보:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3001 (admin/admin)"
echo ""
echo "사용법:"
echo "1. 애플리케이션이 실행 중인지 확인: curl http://localhost:3000/metrics"
echo "2. Prometheus에서 메트릭 확인: http://localhost:9090/targets"
echo "3. Grafana에서 대시보드 생성: http://localhost:3001"
echo ""
echo "다음 단계: 애플리케이션 메트릭 수집 테스트"