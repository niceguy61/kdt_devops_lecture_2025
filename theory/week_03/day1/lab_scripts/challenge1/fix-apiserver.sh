#!/bin/bash

# API Server 수정 스크립트

echo "=== Fixing API Server Configuration ==="

echo "1. Backing up current configuration..."
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml.backup

echo "2. Fixing API Server port (6444 -> 6443)..."
sudo sed -i 's/--secure-port=6444/--secure-port=6443/' /etc/kubernetes/manifests/kube-apiserver.yaml

echo "3. Fixing ETCD port (2380 -> 2379)..."
sudo sed -i 's/2380/2379/' /etc/kubernetes/manifests/kube-apiserver.yaml

echo "4. Restarting kubelet to recreate static pod..."
sudo systemctl restart kubelet

echo "5. Waiting for API Server to start..."
sleep 30

echo "6. Testing API Server connectivity..."
kubectl cluster-info || echo "API Server still not accessible"

echo "API Server fix completed!"