#!/bin/bash
set -e

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Install Cilium CLI
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64 && [ "$(uname -m)" = "aarch64" ] && CLI_ARCH=arm64
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$${CILIUM_CLI_VERSION}/cilium-linux-$${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-$${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-$${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-$${CLI_ARCH}.tar.gz{,.sha256sum}

# Get the master node's private IP address dynamically
MASTER_IP=$(hostname -I | awk '{print $1}')
echo "Master IP: $MASTER_IP"

# Add Cilium Helm repository
helm repo add cilium https://helm.cilium.io/
helm repo update

# Wait for k3s to be fully ready
echo "Installing Cilium..."

# Helm install cilium
helm upgrade cilium cilium/cilium \
    -n kube-system \
    -f /tmp/cilium/values.yaml \
    --version ${cilium_version} \
    --set operator.replicas=1

# Wait for Cilium to be ready
echo "Waiting for Cilium to be ready..."
kubectl wait --for=condition=ready --all pods -n kube-system -l k8s-app=cilium --timeout=300s

# Verify Cilium installation
cilium status --wait

# Apply node labels for visibility
kubectl label node ${hostname} node-role.kubernetes.io/master=true --overwrite

echo "Cilium installation completed successfully"

# Save Cilium status for troubleshooting
cilium status > /tmp/cilium-status.txt
