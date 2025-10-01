#!/bin/bash

# Week 2 Day 4 Lab 1: 포트 포워딩 시작 스크립트
# 사용법: ./start_port_forward.sh

echo "=== 포트 포워딩 시작 ==="
echo ""

# 기존 포트 포워딩 프로세스 정리
echo "기존 포트 포워딩 프로세스 정리 중..."
pkill -f "kubectl port-forward.*nginx-service" 2>/dev/null || true
sleep 2

# 백그라운드에서 포트 포워딩 시작
echo "백그라운드에서 포트 포워딩 시작..."
kubectl port-forward svc/nginx-service 8080:80 -n lab-demo > /dev/null 2>&1 &
PID=$!

echo "✅ 포트 포워딩 시작됨 (PID: $PID)"
echo "📝 PID를 파일에 저장: /tmp/port-forward.pid"
echo $PID > /tmp/port-forward.pid

# 연결 테스트 (10초 대기)
echo ""
echo "연결 테스트 중..."
for i in {1..10}; do
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo "✅ 포트 포워딩 연결 성공! ($i초 소요)"
        echo "🌐 브라우저에서 http://localhost:8080 접근 가능"
        break
    else
        echo "⏳ 연결 대기 중... ($i/10초)"
        sleep 1
    fi
done

# 최종 상태 확인
echo ""
if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    echo "🎉 포트 포워딩 설정 완료!"
    echo ""
    echo "🔧 관리 명령어:"
    echo "- 상태 확인: curl http://localhost:8080/health"
    echo "- 프로세스 확인: ps aux | grep kubectl"
    echo "- 중지: kill $PID"
    echo "- 또는: kill \$(cat /tmp/port-forward.pid)"
    echo "- 재시작: ./start_port_forward.sh"
else
    echo "❌ 포트 포워딩 연결 실패"
    echo "수동 확인: kubectl get pods -n lab-demo"
fi

echo ""
echo "💡 팁: 이 터미널을 닫아도 포트 포워딩은 계속 실행됩니다."