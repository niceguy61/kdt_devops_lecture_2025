#!/bin/bash

# Week 4 Day 5 Hands-on 1: 모니터링 스택 설치
# 설명: Metrics Server, Prometheus, Jaeger, Kubecost, Grafana 설치

set -e

echo "=== 모니터링 스택 설치 시작 ==="

# 1. Metrics Server 설치
echo "1/5 Metrics Server 설치 중..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Metrics Server 설정 패치 (Kind 환경용)
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

echo "   Metrics Server 준비 대기 중..."
kubectl wait --for=condition=available --timeout=120s deployment/metrics-server -n kube-system

# 2. Monitoring 네임스페이스 생성
echo "2/5 Monitoring 네임스페이스 생성 중..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# 3. Prometheus 설치
echo "3/5 Prometheus 설치 중..."
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
        image: prom/prometheus:v2.45.0
        args:
        - '--config.file=/etc/prometheus/prometheus.yml'
        - '--storage.tsdb.path=/prometheus'
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
        - name: storage
          mountPath: /prometheus
      volumes:
      - name: config
        configMap:
          name: prometheus-config
      - name: storage
        emptyDir: {}
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
  type: ClusterIP
EOF

# 4. Jaeger 설치
echo "4/5 Jaeger 설치 중..."
kubectl create namespace tracing --dry-run=client -o yaml | kubectl apply -f -

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
        image: jaegertracing/all-in-one:1.47
        env:
        - name: COLLECTOR_ZIPKIN_HOST_PORT
          value: ":9411"
        ports:
        - containerPort: 5775
          protocol: UDP
        - containerPort: 6831
          protocol: UDP
        - containerPort: 6832
          protocol: UDP
        - containerPort: 5778
          protocol: TCP
        - containerPort: 16686
          protocol: TCP
        - containerPort: 14268
          protocol: TCP
        - containerPort: 14250
          protocol: TCP
        - containerPort: 9411
          protocol: TCP
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
  - name: jaeger-collector-http
    port: 14268
    targetPort: 14268
  - name: jaeger-collector-grpc
    port: 14250
    targetPort: 14250
  - name: zipkin
    port: 9411
    targetPort: 9411
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger-query
  namespace: tracing
spec:
  selector:
    app: jaeger
  ports:
  - name: query-http
    port: 16686
    targetPort: 16686
    nodePort: 30092
  type: NodePort
EOF

# 5. Kubecost 설치
echo "5/5 Kubecost 설치 중..."
kubectl create namespace kubecost --dry-run=client -o yaml | kubectl apply -f -

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
        image: gcr.io/kubecost1/cost-model:prod-1.106.2
        env:
        - name: PROMETHEUS_SERVER_ENDPOINT
          value: "http://prometheus.monitoring.svc.cluster.local:9090"
        ports:
        - containerPort: 9090
---
apiVersion: v1
kind: Service
metadata:
  name: kubecost
  namespace: kubecost
spec:
  selector:
    app: kubecost
  ports:
  - port: 9090
    targetPort: 9090
    nodePort: 30090
  type: NodePort
EOF

# 6. Grafana 설치
echo "6/6 Grafana 설치 중..."
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
        image: grafana/grafana:10.0.3
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin"
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
    nodePort: 30091
  type: NodePort
EOF

# 모든 Pod 준비 대기
echo ""
echo "모든 컴포넌트 준비 대기 중..."
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=120s
kubectl wait --for=condition=ready pod -l app=jaeger -n tracing --timeout=120s
kubectl wait --for=condition=ready pod -l app=kubecost -n kubecost --timeout=120s
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=120s

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
echo "확인 명령어:"
echo "  kubectl get pods -n monitoring"
echo "  kubectl get pods -n tracing"
echo "  kubectl get pods -n kubecost"
echo "  kubectl top nodes"
