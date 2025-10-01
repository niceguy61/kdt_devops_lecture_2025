#!/bin/bash

# Week 2 Day 3: Grafana 대시보드 문제 해결 스크립트
# 사용법: ./fix_grafana_dashboard.sh

echo "=== Grafana 대시보드 문제 해결 시작 ==="

# 현재 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASHBOARD_DIR="$SCRIPT_DIR/grafana/provisioning/dashboards"
DATASOURCE_DIR="$SCRIPT_DIR/grafana/provisioning/datasources"

echo "1. 환경 상태 확인..."
echo "   - 스크립트 디렉토리: $SCRIPT_DIR"
echo "   - 대시보드 디렉토리: $DASHBOARD_DIR"

# Docker 컨테이너 상태 확인
echo "2. Docker 컨테이너 상태 확인..."
if docker ps | grep -q grafana; then
    GRAFANA_STATUS="실행 중"
    GRAFANA_CONTAINER=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep grafana)
    echo "   ✅ Grafana: $GRAFANA_STATUS"
    echo "   $GRAFANA_CONTAINER"
else
    echo "   ❌ Grafana 컨테이너가 실행되지 않음"
    echo "   모니터링 스택을 먼저 시작해주세요"
    exit 1
fi

if docker ps | grep -q prometheus; then
    echo "   ✅ Prometheus: 실행 중"
else
    echo "   ❌ Prometheus 컨테이너가 실행되지 않음"
fi

# 디렉토리 구조 확인
echo "3. 디렉토리 구조 확인..."
if [ -d "$DASHBOARD_DIR" ]; then
    echo "   ✅ 대시보드 디렉토리 존재"
    echo "   파일 목록:"
    ls -la "$DASHBOARD_DIR/" | sed 's/^/     /'
else
    echo "   ❌ 대시보드 디렉토리 없음"
    echo "   디렉토리 생성 중..."
    mkdir -p "$DASHBOARD_DIR"
fi

# 프로비저닝 설정 파일 확인 및 생성
echo "4. 프로비저닝 설정 확인..."

# dashboard.yml 확인
if [ ! -f "$DASHBOARD_DIR/dashboard.yml" ]; then
    echo "   - dashboard.yml 생성 중..."
    cat > "$DASHBOARD_DIR/dashboard.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF
    echo "   ✅ dashboard.yml 생성 완료"
else
    echo "   ✅ dashboard.yml 이미 존재"
fi

# datasource 설정 확인
mkdir -p "$DATASOURCE_DIR"
if [ ! -f "$DATASOURCE_DIR/prometheus.yml" ]; then
    echo "   - prometheus.yml 생성 중..."
    cat > "$DATASOURCE_DIR/prometheus.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF
    echo "   ✅ prometheus.yml 생성 완료"
else
    echo "   ✅ prometheus.yml 이미 존재"
fi

# 대시보드 파일 확인
echo "5. 대시보드 파일 확인..."
DASHBOARD_FILES=("container-dashboard.json" "error-app-dashboard.json" "load-test-dashboard.json")

for file in "${DASHBOARD_FILES[@]}"; do
    if [ -f "$DASHBOARD_DIR/$file" ]; then
        FILE_SIZE=$(stat -f%z "$DASHBOARD_DIR/$file" 2>/dev/null || stat -c%s "$DASHBOARD_DIR/$file" 2>/dev/null)
        echo "   ✅ $file: ${FILE_SIZE} bytes"
    else
        echo "   ❌ $file: 없음"
    fi
done

# Grafana 로그 확인
echo "6. Grafana 로그 확인..."
echo "   최근 로그 (마지막 10줄):"
docker logs grafana --tail 10 2>/dev/null | sed 's/^/     /' || echo "   로그를 가져올 수 없습니다"

# Grafana 설정 리로드
echo "7. Grafana 설정 리로드..."
echo "   - 컨테이너 재시작 중..."
docker restart grafana > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "   ✅ Grafana 재시작 성공"
    echo "   - 30초 대기 중..."
    sleep 30
else
    echo "   ❌ Grafana 재시작 실패"
fi

# 연결 테스트
echo "8. 연결 테스트..."
if curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
    echo "   ✅ Grafana 웹 인터페이스 접근 가능"
else
    echo "   ❌ Grafana 웹 인터페이스 접근 불가"
    echo "   포트 3001이 사용 중인지 확인해주세요"
fi

# API를 통한 대시보드 확인
echo "9. API를 통한 대시보드 확인..."
DASHBOARDS=$(curl -s -u admin:admin http://localhost:3001/api/search 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$DASHBOARDS" ]; then
    echo "   ✅ API 접근 성공"
    echo "   등록된 대시보드:"
    echo "$DASHBOARDS" | grep -o '"title":"[^"]*"' | sed 's/"title":"//g' | sed 's/"//g' | sed 's/^/     - /'
else
    echo "   ❌ API 접근 실패 또는 대시보드 없음"
fi

echo ""
echo "=== 문제 해결 완료 ==="
echo ""
echo "🔧 수행된 작업:"
echo "- ✅ 디렉토리 구조 확인 및 생성"
echo "- ✅ 프로비저닝 설정 파일 생성"
echo "- ✅ Grafana 컨테이너 재시작"
echo "- ✅ 연결 상태 확인"
echo ""
echo "📋 다음 단계:"
echo "1. Grafana 접속: http://localhost:3001"
echo "2. 로그인: admin / admin"
echo "3. 왼쪽 메뉴 → Dashboards 클릭"
echo "4. 대시보드 목록에서 다음 항목 확인:"
echo "   - Container Monitoring Dashboard"
echo "   - Error Test App Monitoring"
echo "   - Load Test & Performance Dashboard"
echo ""
echo "❓ 여전히 대시보드가 보이지 않는다면:"
echo "1. 브라우저 새로고침 (Ctrl+F5)"
echo "2. 다른 브라우저에서 접속 시도"
echo "3. Grafana 로그 확인: docker logs grafana"
echo "4. 파일 권한 확인: ls -la $DASHBOARD_DIR/"
echo ""
echo "🆘 추가 도움이 필요하면:"
echo "- 대시보드 수동 생성: ./create_error_dashboard.sh"
echo "- 고급 대시보드 생성: ./create_advanced_dashboard.sh"