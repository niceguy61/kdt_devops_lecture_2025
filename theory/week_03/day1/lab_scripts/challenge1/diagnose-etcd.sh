#!/bin/bash

# ETCD 진단 스크립트

echo "=== ETCD Diagnosis ==="

echo "1. Checking ETCD Pod status..."
kubectl get pods -n kube-system -l component=etcd || echo "Cannot access API Server"

echo "2. Checking ETCD logs..."
kubectl logs -n kube-system -l component=etcd --tail=20 || echo "Cannot access ETCD logs"

echo "3. Checking ETCD data directories..."
sudo ls -la /var/lib/etcd* || echo "No ETCD data directories found"

echo "4. Checking ETCD process..."
sudo ps aux | grep etcd || echo "No ETCD process found"

echo "5. Checking ETCD configuration..."
if [ -f "/etc/kubernetes/manifests/etcd.yaml" ]; then
    echo "ETCD configuration file exists"
    grep -E "(data-dir|initial-cluster-state)" /etc/kubernetes/manifests/etcd.yaml
else
    echo "ETCD configuration file not found"
fi

echo "ETCD diagnosis completed!"