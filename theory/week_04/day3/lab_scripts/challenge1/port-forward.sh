#!/bin/bash

# Week 4 Day 3 Challenge 1: 포트 포워딩
# 설명: Prometheus와 Grafana 접근을 위한 포트 포워딩

echo "=== 포트 포워딩 시작 ==="
echo ""
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000"
echo ""
echo "종료하려면 Ctrl+C를 누르세요"
echo ""

# 백그라운드로 포트 포워딩 실행
kubectl port-forward -n istio-system svc/prometheus 9090:9090 &
PROM_PID=$!

kubectl port-forward -n istio-system svc/grafana 3000:3000 &
GRAFANA_PID=$!

# Ctrl+C 처리
trap "kill $PROM_PID $GRAFANA_PID 2>/dev/null; echo '포트 포워딩 종료'; exit" INT TERM

# 프로세스 대기
wait
