#!/bin/bash

# Week 4 Day 3 Challenge 1: Gatekeeper 메트릭 설정
# 설명: Prometheus가 Gatekeeper 메트릭을 수집하도록 설정

set -e

echo "=== Gatekeeper 메트릭 설정 시작 ==="

# 1. Gatekeeper ServiceMonitor 생성
echo "1/3 ServiceMonitor 생성 중..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: gatekeeper-controller-manager-metrics
  namespace: gatekeeper-system
  labels:
    app: gatekeeper
spec:
  ports:
  - name: metrics
    port: 8888
    protocol: TCP
    targetPort: 8888
  selector:
    control-plane: controller-manager
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: gatekeeper-controller-manager
  namespace: gatekeeper-system
  labels:
    app: gatekeeper
spec:
  selector:
    matchLabels:
      app: gatekeeper
  endpoints:
  - port: metrics
    interval: 30s
EOF

# 2. Prometheus에 Gatekeeper 네임스페이스 접근 권한 부여
echo "2/3 Prometheus RBAC 설정 중..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus-gatekeeper
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/metrics
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources:
  - configmaps
  verbs: ["get"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus-gatekeeper
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-gatekeeper
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: istio-system
EOF

# 3. Prometheus 재시작
echo "3/3 Prometheus 재시작 중..."
kubectl rollout restart deployment prometheus -n istio-system

echo ""
echo "=== Gatekeeper 메트릭 설정 완료 ==="
echo ""
echo "확인 방법:"
echo "1. Prometheus에서 'gatekeeper' 검색"
echo "2. Grafana에서 Gatekeeper 대시보드 확인"
echo ""
echo "주요 메트릭:"
echo "- gatekeeper_constraints"
echo "- gatekeeper_constraint_template_ingestion_count"
echo "- gatekeeper_violations"
