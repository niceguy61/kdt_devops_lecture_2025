#!/bin/bash

# Kubelet 진단 스크립트

echo "=== Kubelet Diagnosis ==="

echo "1. Checking node status..."
kubectl get nodes || echo "Cannot access API Server"

echo "2. Checking kubelet service status..."
sudo systemctl status kubelet

echo "3. Checking kubelet logs..."
sudo journalctl -u kubelet --no-pager -l | tail -20

echo "4. Checking kubelet certificates..."
if [ -f "/var/lib/kubelet/pki/kubelet-client-current.pem" ]; then
    echo "Checking certificate expiration:"
    sudo openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -text -noout | grep -A2 Validity
else
    echo "Kubelet client certificate not found"
fi

echo "5. Checking kubelet configuration..."
if [ -f "/etc/kubernetes/kubelet.conf" ]; then
    echo "Kubelet configuration exists"
    echo "Current context:"
    grep "current-context" /etc/kubernetes/kubelet.conf
else
    echo "Kubelet configuration not found"
fi

echo "6. Checking kubelet config file..."
if [ -f "/var/lib/kubelet/config.yaml" ]; then
    echo "Kubelet config file exists"
    grep -E "(rotateCertificates|serverTLSBootstrap)" /var/lib/kubelet/config.yaml || echo "Certificate rotation not configured"
else
    echo "Kubelet config file not found"
fi

echo "Kubelet diagnosis completed!"