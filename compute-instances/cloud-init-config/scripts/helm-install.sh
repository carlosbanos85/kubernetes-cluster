#!/bin/bash
set -e

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Install Helm using the cross-platform script (works on Oracle Linux)
echo "Installing Helm"
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify Helm installation
if ! command -v helm &> /dev/null; then
  echo "Helm installation failed, trying alternative method..."
  # Alternative Helm installation
  HELM_VERSION="v3.18.4"
  HELM_ARCH="amd64"
  if [ "$(uname -m)" = "aarch64" ]; then
    HELM_ARCH="arm64"
  fi
  wget -q https://get.helm.sh/helm-$HELM_VERSION-linux-$HELM_ARCH.tar.gz
  tar -xzf helm-$HELM_VERSION-linux-$HELM_ARCH.tar.gz
  mv linux-$HELM_ARCH/helm /usr/local/bin/helm
  chmod +x /usr/local/bin/helm
  rm -rf helm-$HELM_VERSION-linux-$HELM_ARCH.tar.gz linux-$HELM_ARCH
fi

echo "Helm installed successfully: $(helm version --short)"
