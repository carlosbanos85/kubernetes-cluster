#!/bin/bash
set -e

# Wait for network to be ready
until ping -c 1 8.8.8.8 &> /dev/null; do
  echo "Waiting for network..."
  sleep 5
done

# Install k3s server
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s - \
  --disable=flannel,local-storage,metrics-server,servicelb,traefik \
  --flannel-backend='none' \
  --disable-network-policy \
  --disable-cloud-controller \
  --disable-kube-proxy \
  --node-name ${hostname} \
  --cluster-init \
  --cluster-domain="${cluster_domain}" \
  --write-kubeconfig-mode 644 \
  K3S_TOKEN=${cluster_token}

# Wait for k3s to be ready
until kubectl get nodes &> /dev/null; do
  echo "Waiting for k3s to be ready..."
  sleep 10
done

# Create kubeconfig for external access
cp /etc/rancher/k3s/k3s.yaml /tmp/k3s-external.yaml
sed -i 's/127.0.0.1:6443/${hostname}:6443/g' /tmp/k3s-external.yaml
chmod 644 /tmp/k3s-external.yaml

echo "K3s master installation completed"
