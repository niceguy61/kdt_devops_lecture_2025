#!/bin/bash

# Week 4 Day 5 Hands-on 1: CloudMart 통합 검증
# 설명: CloudMart 전체 시스템 상태 및 비용 추적 검증

echo "=== CloudMart 통합 검증 ==="
echo ""

echo "1. CloudMart 서비스 확인"
kubectl get pods -n cloudmart -o wide

echo ""
echo "2. HPA 동작 확인"
kubectl get hpa -n cloudmart

echo ""
echo "3. Kubecost 상태"
kubectl get pods -n kubecost

echo ""
echo "4. 전체 리소스 사용량"
kubectl top nodes

echo ""
echo "5. CloudMart 비용 (최근 1일)"
curl -s "http://localhost:9090/model/allocation?window=1d&aggregate=namespace&filter=namespace:cloudmart" | jq '.data[] | {name: .name, totalCost: .totalCost}'

echo ""
echo "=== 검증 완료 ==="
