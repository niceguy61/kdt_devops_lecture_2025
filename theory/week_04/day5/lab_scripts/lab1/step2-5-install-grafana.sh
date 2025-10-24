#!/bin/bash

# Week 4 Day 5 Lab 1: Grafana 설치
# 설명: Helm을 사용하여 Grafana 설치 및 Prometheus 연동

set -e

echo "=== Grafana 설치 시작 ==="

# 1. Helm repo 추가
echo "1/4 Helm repository 추가 중..."
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 2. Grafana 설치
echo "2/4 Grafana 설치 중..."
helm install grafana grafana/grafana \
  --namespace kubecost \
  --set service.type=NodePort \
  --set service.nodePort=30081 \
  --set adminPassword=admin \
  --set datasources."datasources\.yaml".apiVersion=1 \
  --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
  --set datasources."datasources\.yaml".datasources[0].type=prometheus \
  --set datasources."datasources\.yaml".datasources[0].url=http://kubecost-prometheus-server:80 \
  --set datasources."datasources\.yaml".datasources[0].access=proxy \
  --set datasources."datasources\.yaml".datasources[0].isDefault=true

# 3. Grafana Pod 대기
echo "3/4 Grafana Pod 시작 대기 중..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n kubecost --timeout=120s

# 4. 설치 확인
echo "4/4 설치 확인 중..."
kubectl get pods -n kubecost -l app.kubernetes.io/name=grafana
kubectl get svc -n kubecost -l app.kubernetes.io/name=grafana

echo ""
echo "=== Grafana 설치 완료 ==="
echo ""
echo "접속 정보:"
echo "- URL: http://localhost:30081"
echo "- Username: admin"
echo "- Password: admin"
echo ""
echo "Prometheus 데이터소스가 자동으로 설정되었습니다."
