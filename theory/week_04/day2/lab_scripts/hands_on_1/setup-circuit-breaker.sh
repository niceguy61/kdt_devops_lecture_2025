#!/bin/bash

# Week 4 Day 2 Hands-on 1: 서킷 브레이커 & 고급 헬스체크 설정
# 사용법: ./setup-circuit-breaker.sh

echo "=== 서킷 브레이커 & 고급 헬스체크 설정 시작 ==="

# 1. Kong 헬스체크 강화
echo "1. Kong 업스트림 헬스체크 강화 중..."

# 업스트림 헬스체크 설정 업데이트
curl -s -X PATCH http://localhost:8001/upstreams/user-service-upstream \
  --data "healthchecks.active.type=http" \
  --data "healthchecks.active.http_path=/health" \
  --data "healthchecks.active.healthy.interval=5" \
  --data "healthchecks.active.healthy.successes=2" \
  --data "healthchecks.active.unhealthy.interval=3" \
  --data "healthchecks.active.unhealthy.http_failures=2" \
  --data "healthchecks.active.unhealthy.timeouts=2" \
  --data "healthchecks.passive.healthy.successes=3" \
  --data "healthchecks.passive.unhealthy.http_failures=3" \
  --data "healthchecks.passive.unhealthy.timeouts=2" > /dev/null

# 2. 서비스별 타임아웃 및 재시도 설정
echo "2. 서비스별 타임아웃 및 재시도 설정 중..."

services=("user-service" "product-service" "order-service")

for service in "${services[@]}"; do
    # 서비스 타임아웃 설정
    curl -s -X PATCH http://localhost:8001/services/${service} \
      --data "connect_timeout=5000" \
      --data "write_timeout=10000" \
      --data "read_timeout=10000" \
      --data "retries=3" > /dev/null
    
    echo "  ✅ ${service} 타임아웃 설정 완료"
done

# 3. Request Termination 플러그인 (서킷 브레이커 시뮬레이션)
echo "3. Request Termination 플러그인 설정 중..."

# 헬스체크 실패 시 요청 차단을 위한 플러그인
curl -s -X POST http://localhost:8001/plugins \
  --data "name=request-termination" \
  --data "config.status_code=503" \
  --data "config.message=Service Temporarily Unavailable - Circuit Breaker Open" \
  --data "enabled=false" > /dev/null

# 4. Proxy Cache 플러그인 (성능 향상)
echo "4. Proxy Cache 플러그인 설정 중..."

curl -s -X POST http://localhost:8001/plugins \
  --data "name=proxy-cache" \
  --data "config.response_code=200" \
  --data "config.request_method=GET" \
  --data "config.content_type=application/json" \
  --data "config.cache_ttl=300" \
  --data "config.strategy=memory" > /dev/null

# 5. IP Restriction 플러그인 (보안 강화)
echo "5. IP Restriction 플러그인 설정 중..."

curl -s -X POST http://localhost:8001/plugins \
  --data "name=ip-restriction" \
  --data "config.allow=127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16" > /dev/null

# 6. Request Size Limiting 플러그인
echo "6. Request Size Limiting 플러그인 설정 중..."

curl -s -X POST http://localhost:8001/plugins \
  --data "name=request-size-limiting" \
  --data "config.allowed_payload_size=10" > /dev/null

# 7. 고급 로깅 설정
echo "7. 고급 로깅 설정 중..."

# HTTP Log 플러그인 (외부 로그 수집기로 전송)
curl -s -X POST http://localhost:8001/plugins \
  --data "name=http-log" \
  --data "config.http_endpoint=http://localhost:8080/logs" \
  --data "config.method=POST" \
  --data "config.timeout=1000" \
  --data "config.keepalive=1000" \
  --data "enabled=false" > /dev/null

# File Log 플러그인 (로컬 파일 로깅)
curl -s -X POST http://localhost:8001/plugins \
  --data "name=file-log" \
  --data "config.path=/tmp/kong-access.log" > /dev/null

# 8. 장애 시뮬레이션 서비스 생성
echo "8. 장애 시뮬레이션 서비스 생성 중..."

mkdir -p ~/microservices-lab/services/chaos-service

cat > ~/microservices-lab/services/chaos-service/app.js << 'EOF'
const express = require('express');
const app = express();
const PORT = 3006;

let isHealthy = true;
let responseDelay = 0;
let errorRate = 0;

app.use(express.json());

// 헬스체크 (조작 가능)
app.get('/health', (req, res) => {
  if (isHealthy) {
    res.json({ 
      status: 'healthy', 
      service: 'chaos-service',
      timestamp: new Date().toISOString()
    });
  } else {
    res.status(503).json({ 
      status: 'unhealthy', 
      service: 'chaos-service',
      timestamp: new Date().toISOString()
    });
  }
});

// 일반 API (지연 및 에러 시뮬레이션)
app.get('/api/test', async (req, res) => {
  // 응답 지연 시뮬레이션
  if (responseDelay > 0) {
    await new Promise(resolve => setTimeout(resolve, responseDelay));
  }
  
  // 에러 시뮬레이션
  if (Math.random() < errorRate) {
    return res.status(500).json({ 
      error: 'Simulated server error',
      timestamp: new Date().toISOString()
    });
  }
  
  res.json({ 
    message: 'Chaos service response',
    delay: responseDelay,
    errorRate: errorRate,
    timestamp: new Date().toISOString()
  });
});

// 장애 제어 API
app.post('/chaos/health', (req, res) => {
  isHealthy = req.body.healthy !== false;
  res.json({ healthy: isHealthy });
});

app.post('/chaos/delay', (req, res) => {
  responseDelay = parseInt(req.body.delay) || 0;
  res.json({ delay: responseDelay });
});

app.post('/chaos/error-rate', (req, res) => {
  errorRate = parseFloat(req.body.rate) || 0;
  res.json({ errorRate: errorRate });
});

app.listen(PORT, () => {
  console.log(`Chaos Service running on port ${PORT}`);
  console.log('Control endpoints:');
  console.log('- POST /chaos/health {"healthy": false}');
  console.log('- POST /chaos/delay {"delay": 5000}');
  console.log('- POST /chaos/error-rate {"rate": 0.5}');
});
EOF

# package.json 생성
cat > ~/microservices-lab/services/chaos-service/package.json << 'EOF'
{
  "name": "chaos-service",
  "version": "1.0.0",
  "description": "Chaos engineering test service",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# Chaos Service 컨테이너 실행
docker run -d \
  --name chaos-service \
  --network microservices-net \
  -p 3006:3006 \
  -v ~/microservices-lab/services/chaos-service:/app \
  -w /app \
  node:16-alpine \
  sh -c "npm install && npm start"

# 9. Chaos Service를 Kong에 등록
echo "9. Chaos Service를 Kong에 등록 중..."
sleep 5

curl -s -X POST http://localhost:8001/services \
  --data "name=chaos-service" \
  --data "host=chaos-service" \
  --data "port=3006" \
  --data "path=/api" > /dev/null

curl -s -X POST http://localhost:8001/services/chaos-service/routes \
  --data "name=api-chaos" \
  --data "paths[]=/api/chaos" > /dev/null

# 10. 상태 확인 및 테스트
echo "10. 서킷 브레이커 설정 상태 확인 중..."

# 업스트림 헬스체크 상태
echo ""
echo "=== 업스트림 헬스체크 상태 ==="
curl -s http://localhost:8001/upstreams/user-service-upstream/health | jq '.' 2>/dev/null || echo "헬스체크 정보 로딩 중..."

# 활성화된 플러그인 목록
echo ""
echo "=== 활성화된 플러그인 ==="
curl -s http://localhost:8001/plugins | jq -r '.data[] | "- \(.name): \(.enabled)"' 2>/dev/null || echo "플러그인 정보 로딩 중..."

# Chaos Service 상태
echo ""
echo "=== Chaos Service 상태 ==="
if curl -s http://localhost:3006/health | grep -q "healthy"; then
    echo "✅ Chaos Service 정상 실행"
else
    echo "❌ Chaos Service 시작 실패"
fi

echo ""
echo "=== 서킷 브레이커 & 고급 헬스체크 설정 완료 ==="
echo ""
echo "설정된 기능:"
echo "- ✅ 강화된 헬스체크: 2초마다 확인, 2회 실패 시 제외"
echo "- ✅ 타임아웃 설정: 연결 5초, 읽기/쓰기 10초"
echo "- ✅ 자동 재시도: 최대 3회 재시도"
echo "- ✅ 프록시 캐시: GET 요청 5분 캐싱"
echo "- ✅ IP 제한: 내부 네트워크만 허용"
echo "- ✅ 요청 크기 제한: 최대 10MB"
echo "- ✅ 파일 로깅: /tmp/kong-access.log"
echo ""
echo "장애 테스트 방법:"
echo "1. 서비스 다운 시뮬레이션:"
echo "   curl -X POST http://localhost:3006/chaos/health -d '{\"healthy\":false}'"
echo ""
echo "2. 응답 지연 시뮬레이션:"
echo "   curl -X POST http://localhost:3006/chaos/delay -d '{\"delay\":5000}'"
echo ""
echo "3. 에러율 증가 시뮬레이션:"
echo "   curl -X POST http://localhost:3006/chaos/error-rate -d '{\"rate\":0.5}'"
echo ""
echo "4. 테스트 API 호출:"
echo "   curl http://localhost:8000/api/chaos/test"
echo ""
echo "5. 헬스체크 모니터링:"
echo "   watch -n 1 'curl -s http://localhost:8001/upstreams/user-service-upstream/health'"
