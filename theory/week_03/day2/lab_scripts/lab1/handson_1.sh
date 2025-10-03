#!/bin/bash

# Week 3 Day 2 H1: Advanced Workload Management
# Purpose: Scheduling, scaling, and lifecycle management

echo "=== Advanced Workload Management H1 ==="

# 1. Deploy with node affinity and resource constraints
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: advanced-web
  namespace: workload-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: advanced-web
  template:
    metadata:
      labels:
        app: advanced-web
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                - amd64
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# 2. Create HPA
kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: advanced-web-hpa
  namespace: workload-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: advanced-web
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF

# 3. Deploy DaemonSet
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
  namespace: workload-demo
spec:
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd:v1.14
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF

echo "✅ Advanced workloads deployed"
echo ""
echo "Monitor scaling:"
echo "kubectl get hpa -n workload-demo -w"
echo "kubectl top pods -n workload-demo"
