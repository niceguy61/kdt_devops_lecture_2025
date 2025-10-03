#!/bin/bash

# 클러스터 분석 스크립트

echo "=== Kubernetes Cluster Analysis ==="
echo "Date: $(date)"
echo ""

echo "=== Cluster Info ==="
kubectl cluster-info
echo ""

echo "=== Node Status ==="
kubectl get nodes -o wide
echo ""

echo "=== System Pods ==="
kubectl get pods -n kube-system -o wide
echo ""

echo "=== Component Health ==="
kubectl get componentstatuses
echo ""

echo "=== Resource Usage ==="
kubectl top nodes 2>/dev/null || echo "Metrics server not available"
echo ""

echo "=== ETCD Health ==="
ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n kube-system $ETCD_POD -- \
  etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health 2>/dev/null || echo "ETCD health check failed"

echo ""
echo "=== Test Workload Status ==="
kubectl get all -n lab-day1

echo ""
echo "=== Pod Distribution ==="
kubectl get pods -n lab-day1 -o wide

echo ""
echo "=== Service Endpoints ==="
kubectl get endpoints -n lab-day1