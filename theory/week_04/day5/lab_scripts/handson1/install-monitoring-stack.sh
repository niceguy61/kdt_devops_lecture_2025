#!/bin/bash

# Week 4 Day 5 Hands-on 1: 모니터링 스택 설치
# 설명: Metrics Server + Prometheus + Jaeger + Kubecost + Grafana

set -e

echo "=== 모니터링 스택 설치 시작 ==="

# 1. Metrics Server 설치
echo "1/5 Metrics Server 설치 중..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

echo "Metrics Server 준비 대기 중..."
kubectl wait --for=condition=available --timeout=60s deployment/metrics-server -n kube-system

# 2. Prometheus 설치
echo "2/5 Prometheus 설치 중..."
kubectl create namespace monitoring

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    scrape_configs:
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: \$1:\$2
        target_label: __address__
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
      volumes:
      - name: config
        configMap:
          name: prometheus-config
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090
EOF

# 3. Jaeger 설치
echo "3/5 Jaeger 설치 중..."
kubectl create namespace tracing

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
  namespace: tracing
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:latest
        ports:
        - containerPort: 16686  # UI
        - containerPort: 14268  # Collector HTTP
        - containerPort: 14250  # Collector gRPC
        - containerPort: 6831   # Agent UDP
          protocol: UDP
        env:
        - name: COLLECTOR_ZIPKIN_HOST_PORT
          value: ":9411"
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger-collector
  namespace: tracing
spec:
  selector:
    app: jaeger
  ports:
  - name: http
    port: 14268
    targetPort: 14268
  - name: grpc
    port: 14250
    targetPort: 14250
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger-agent
  namespace: tracing
spec:
  selector:
    app: jaeger
  ports:
  - name: agent-udp
    port: 6831
    targetPort: 6831
    protocol: UDP
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger-query
  namespace: tracing
  labels:
    app: jaeger
spec:
  type: NodePort
  selector:
    app: jaeger
  ports:
  - port: 16686
    targetPort: 16686
    nodePort: 30092
EOF

# 4. Kubecost 설치
echo "4/5 Kubecost 설치 중..."
kubectl create namespace kubecost

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubecost
  namespace: kubecost
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kubecost
  template:
    metadata:
      labels:
        app: kubecost
    spec:
      containers:
      - name: kubecost
        image: gcr.io/kubecost1/cost-model:latest
        ports:
        - containerPort: 9090
        env:
        - name: PROMETHEUS_SERVER_ENDPOINT
          value: "http://prometheus.monitoring:9090"
---
apiVersion: v1
kind: Service
metadata:
  name: kubecost
  namespace: kubecost
spec:
  type: NodePort
  selector:
    app: kubecost
  ports:
  - port: 9090
    targetPort: 9090
    nodePort: 30090
EOF

# 5. Grafana 설치
echo "5/5 Grafana 설치 중..."

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin"
        - name: GF_USERS_ALLOW_SIGN_UP
          value: "false"
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  type: NodePort
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
    nodePort: 30091
EOF

echo ""
echo "=== 모니터링 스택 설치 완료 ==="
echo ""
echo "설치된 컴포넌트:"
echo "- Metrics Server (kube-system namespace)"
echo "- Prometheus (monitoring namespace)"
echo "- Jaeger (tracing namespace)"
echo "  * UI: http://localhost:30092"
echo "- Kubecost (kubecost namespace)"
echo "  * UI: http://localhost:30090"
echo "- Grafana (monitoring namespace)"
echo "  * UI: http://localhost:30091"
echo "  * ID: admin / PW: admin"
echo ""
echo "다음 단계:"
echo "kubectl get pods --all-namespaces"
