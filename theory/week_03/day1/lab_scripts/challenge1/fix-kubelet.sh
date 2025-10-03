#!/bin/bash

# Kubelet 수정 스크립트

echo "=== Fixing Kubelet Configuration ==="

echo "1. Backing up kubelet certificates..."
sudo cp -r /var/lib/kubelet/pki /var/lib/kubelet/pki.backup 2>/dev/null || echo "No existing certificates to backup"

echo "2. Removing expired certificates..."
sudo rm -f /var/lib/kubelet/pki/kubelet-client*

echo "3. Enabling certificate rotation in kubelet config..."
if [ -f "/var/lib/kubelet/config.yaml" ]; then
    sudo sed -i '/rotateCertificates/d' /var/lib/kubelet/config.yaml
    echo "rotateCertificates: true" | sudo tee -a /var/lib/kubelet/config.yaml
    echo "serverTLSBootstrap: true" | sudo tee -a /var/lib/kubelet/config.yaml
else
    echo "Kubelet config file not found"
fi

echo "4. Creating bootstrap token (run on master node)..."
kubectl create token kubelet-bootstrap --duration=1h 2>/dev/null || echo "Cannot create token - API Server may not be ready"

echo "5. Restarting kubelet service..."
sudo systemctl restart kubelet

echo "6. Waiting for kubelet to start..."
sleep 15

echo "7. Checking node status..."
kubectl get nodes || echo "Node still not ready"

echo "8. Checking kubelet logs for certificate renewal..."
sudo journalctl -u kubelet --no-pager -l | tail -10 | grep -i cert || echo "No certificate messages in recent logs"

echo "Kubelet fix completed!"
echo "Note: In a real environment, you may need to re-run 'kubeadm join' command"