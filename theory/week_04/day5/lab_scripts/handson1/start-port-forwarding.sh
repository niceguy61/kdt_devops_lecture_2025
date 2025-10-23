#!/bin/bash

# Week 4 Day 5 Hands-on 1: 포트포워딩 자동 시작
# 설명: CloudMart, Grafana, Jaeger 포트포워딩 자동 실행

set -e

echo "=== 포트포워딩 시작 ==="

# 기존 포트포워딩 프로세스 종료
pkill -f "port-forward" 2>/dev/null || true
sleep 2

# CloudMart 서비스 포트포워딩
echo "1/5 User Service 포트포워딩 (8080 → 8080)..."
kubectl port-forward -n cloudmart svc/user-service 8080:80 > /dev/null 2>&1 &

echo "2/5 Product Service 포트포워딩 (8081 → 80)..."
kubectl port-forward -n cloudmart svc/product-service 8081:80 > /dev/null 2>&1 &

echo "3/5 Order Service 포트포워딩 (8082 → 80)..."
kubectl port-forward -n cloudmart svc/order-service 8082:80 > /dev/null 2>&1 &

# 모니터링 도구 포트포워딩
echo "4/5 Grafana 포트포워딩 (3000 → 80)..."
kubectl port-forward -n monitoring svc/grafana 3000:80 > /dev/null 2>&1 &

echo "5/5 Jaeger 포트포워딩 (16686 → 16686)..."
kubectl port-forward -n tracing svc/jaeger-query 16686:16686 > /dev/null 2>&1 &

# 잠시 대기
sleep 3

echo ""
echo "=== 포트포워딩 완료 ==="
echo ""
echo "접속 정보:"
echo "- User Service: http://localhost:8080"
echo "- Product Service: http://localhost:8081"
echo "- Order Service: http://localhost:8082"
echo "- Grafana: http://localhost:3000 (admin/admin)"
echo "- Jaeger UI: http://localhost:16686"
echo ""
echo "포트포워딩 중지: pkill -f port-forward"
