#!/bin/bash

# ETCD 수정 스크립트

echo "=== Fixing ETCD Configuration ==="

echo "1. Backing up ETCD configuration..."
sudo cp /etc/kubernetes/manifests/etcd.yaml /etc/kubernetes/manifests/etcd.yaml.backup

echo "2. Fixing ETCD data directory..."
sudo sed -i 's|--data-dir=/var/lib/etcd-wrong|--data-dir=/var/lib/etcd|g' /etc/kubernetes/manifests/etcd.yaml

echo "3. Fixing cluster state (existing -> new)..."
sudo sed -i 's/--initial-cluster-state=existing/--initial-cluster-state=new/' /etc/kubernetes/manifests/etcd.yaml

echo "4. Ensuring ETCD data directory permissions..."
sudo mkdir -p /var/lib/etcd
sudo chown -R root:root /var/lib/etcd
sudo chmod 700 /var/lib/etcd

echo "5. Restarting kubelet..."
sudo systemctl restart kubelet

echo "6. Waiting for ETCD to start..."
sleep 30

echo "7. Testing ETCD health..."
ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$ETCD_POD" ]; then
    kubectl exec -n kube-system $ETCD_POD -- \
      etcdctl --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key \
      endpoint health || echo "ETCD health check failed"
else
    echo "ETCD pod not found"
fi

echo "ETCD fix completed!"