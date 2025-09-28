#!/bin/bash

# Week 2 Day 3 Lab 1: 알림 시스템 및 통합 테스트
# 사용법: ./setup_alerting_test.sh

echo "=== 알림 시스템 및 통합 테스트 시작 ==="

# 1. AlertManager 설정 파일 생성
echo "1. AlertManager 설정 파일 생성 중..."
cat > config/alertmanager/alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@company.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://webhook:5000/alerts'
        send_resolved: true
        title: 'Alert: {{ .GroupLabels.alertname }}'
        text: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOF

# 2. AlertManager 실행
echo "2. AlertManager 실행 중..."
docker run -d \
  --name alertmanager \
  --restart=unless-stopped \
  -p 9093:9093 \
  -v $(pwd)/config/alertmanager:/etc/alertmanager \
  --link prometheus:prometheus \
  --memory=256m \
  prom/alertmanager:latest

# 3. Webhook 서버 생성
echo "3. Webhook 서버 생성 중..."
cat > webhook-server.py << 'EOF'
from flask import Flask, request, jsonify
import json
from datetime import datetime

app = Flask(__name__)

@app.route('/alerts', methods=['POST'])
def receive_alert():
    alerts = request.json
    print(f"[{datetime.now()}] 🚨 Alert 수신:")
    
    for alert in alerts.get('alerts', []):
        status = alert.get('status', 'unknown')
        labels = alert.get('labels', {})
        annotations = alert.get('annotations', {})
        
        print(f"  상태: {status}")
        print(f"  알림명: {labels.get('alertname', 'Unknown')}")
        print(f"  심각도: {labels.get('severity', 'Unknown')}")
        print(f"  요약: {annotations.get('summary', 'No summary')}")
        print(f"  설명: {annotations.get('description', 'No description')}")
        print("-" * 50)
    
    return jsonify({"status": "received", "count": len(alerts.get('alerts', []))})

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "timestamp": datetime.now().isoformat()})

if __name__ == '__main__':
    print("🎯 Webhook 서버 시작 - 알림 수신 대기 중...")
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

# 4. Webhook 서버 실행
echo "4. Webhook 서버 실행 중..."
docker run -d \
  --name webhook \
  --restart=unless-stopped \
  -p 5000:5000 \
  -v $(pwd)/webhook-server.py:/app/webhook-server.py \
  -w /app \
  python:3.9-slim \
  sh -c "pip install flask && python webhook-server.py"

# 5. 부하 테스트 도구 준비
echo "5. 부하 테스트 도구 준비 중..."
cat > load-test.sh << 'EOF'
#!/bin/bash

echo "🔥 부하 테스트 시작 - 알림 트리거 목적"

# WordPress가 실행 중인지 확인
if docker ps | grep -q wordpress-app; then
    TARGET="localhost:8080"
elif docker ps | grep -q nginx-proxy; then
    TARGET="localhost:80"
else
    echo "❌ 테스트할 웹 서비스를 찾을 수 없습니다."
    exit 1
fi

echo "대상 서비스: $TARGET"

# 부하 테스트 실행 (CPU 사용률 증가 목적)
for i in {1..5}; do
    echo "부하 테스트 라운드 $i/5"
    
    # 동시 요청 생성
    for j in {1..20}; do
        curl -s $TARGET > /dev/null &
    done
    
    # CPU 집약적 작업 시뮬레이션
    docker run --rm --cpus=0.5 --memory=100m alpine \
        sh -c 'for i in $(seq 1 1000000); do echo $i > /dev/null; done' &
    
    sleep 10
done

wait
echo "✅ 부하 테스트 완료"
EOF

chmod +x load-test.sh

# 6. 통합 테스트 실행
echo "6. 통합 테스트 실행 중..."

# AlertManager 시작 대기
sleep 15

# 서비스 상태 확인
echo "📊 모니터링 시스템 상태 확인:"
echo "- Prometheus: $(curl -s http://localhost:9090/-/healthy 2>/dev/null || echo 'Not Ready')"
echo "- Grafana: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000 2>/dev/null || echo 'Not Ready')"
echo "- AlertManager: $(curl -s http://localhost:9093/-/healthy 2>/dev/null || echo 'Not Ready')"
echo "- Elasticsearch: $(curl -s http://localhost:9200/_cluster/health 2>/dev/null | grep -o '"status":"[^"]*"' || echo 'Not Ready')"
echo "- Kibana: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:5601 2>/dev/null || echo 'Not Ready')"
echo "- Webhook: $(curl -s http://localhost:5000/health 2>/dev/null | grep -o '"status":"[^"]*"' || echo 'Not Ready')"

# 7. 샘플 로그 생성
echo "7. 샘플 로그 생성 중..."
if docker ps | grep -q nginx-proxy; then
    # 웹 요청으로 로그 생성
    for i in {1..10}; do
        curl -s http://localhost/ > /dev/null
        curl -s http://localhost/nonexistent > /dev/null  # 404 에러 생성
    done
    echo "✅ 샘플 로그 생성 완료"
fi

# 8. 메트릭 수집 확인
echo "8. 메트릭 수집 확인 중..."
METRICS_COUNT=$(curl -s http://localhost:9090/api/v1/targets 2>/dev/null | grep -o '"health":"up"' | wc -l)
echo "활성 메트릭 타겟: $METRICS_COUNT개"

# 9. 테스트 결과 요약
echo ""
echo "=== 알림 시스템 및 통합 테스트 완료 ==="
echo ""
echo "🎯 테스트 결과:"
echo "- 모니터링 스택: 구축 완료"
echo "- 로깅 시스템: 구축 완료"
echo "- 알림 시스템: 구축 완료"
echo ""
echo "📊 접속 정보:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- AlertManager: http://localhost:9093"
echo "- Kibana: http://localhost:5601"
echo "- Webhook: http://localhost:5000/health"
echo ""
echo "🔥 부하 테스트 실행:"
echo "  ./load-test.sh"
echo ""
echo "📝 알림 로그 확인:"
echo "  docker logs webhook -f"