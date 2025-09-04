#!/bin/bash
# compute-instances/cloud-init-config/scripts/bgp-setup.sh

set -e

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export PATH=$$PATH:/usr/local/bin

# Configuration variables (from Terraform template)
HOSTNAME="${hostname}"
VCN_CIDR="${vcn_cidr}"
BGP_ANNOUNCED_CIDR="${bgp_announced_cidr}"
LOCAL_ASN="${local_asn}"
DRG_ASN="${drg_asn}"
DRG_PEER_IP="${drg_peer_ip}"
CLUSTER_NAME="${cluster_name}"

echo "Starting BGP configuration for Cilium..."
echo "Local ASN: $$LOCAL_ASN"
echo "DRG ASN: $$DRG_ASN"
echo "DRG Peer IP: $$DRG_PEER_IP"
echo "BGP Announced CIDR: $$BGP_ANNOUNCED_CIDR"

# Wait for Cilium to be ready and BGP features available
echo "Waiting for Cilium to be fully ready..."
kubectl wait --for=condition=ready --all pods -n kube-system -l k8s-app=cilium --timeout=600s

# Verify Cilium BGP is enabled
echo "Verifying Cilium BGP configuration..."
until kubectl get crd ciliumloadbalancerippools.cilium.io >&/dev/null; do
  echo "Waiting for Cilium BGP CRDs to be available..."
  sleep 10
done

until kubectl get crd ciliumlbgppeeringpolicies.cilium.io >&/dev/null; do
  echo "Waiting for Cilium BGP peering CRDs to be available..."
  sleep 10
done

# Create CiliumLoadBalancerIPPool
echo "Creating Cilium LoadBalancer IP Pool..."
cat <<EOF | kubectl apply -f -
apiVersion: "cilium.io/v2alpha1"
kind: CiliumLoadBalancerIPPool
metadata:
  name: bgp-lb-pool
  namespace: kube-system
spec:
  blocks:
  - cidr: "$${BGP_ANNOUNCED_CIDR}"
  serviceSelector:
    matchExpressions:
    - key: io.cilium/bgp-announce
      operator: NotIn
      values: ["false"]
EOF

# Wait for IP pool to be ready
echo "Waiting for IP pool to be processed..."
sleep 10

# Create CiliumBGPPeeringPolicy
echo "Creating Cilium BGP Peering Policy..."
cat <<EOF | kubectl apply -f -
apiVersion: "cilium.io/v2alpha1"
kind: CiliumBGPPeeringPolicy
metadata:
  name: bgp-peering-policy
  namespace: kube-system
spec:
  nodeSelector:
    matchLabels:
      kubernetes.io/os: linux
  virtualRouters:
  - localASN: $${LOCAL_ASN}
    exportPodCIDR: false
    serviceSelector:
      matchLabels: {}
    neighbors:
    - peerAddress: "$${DRG_PEER_IP}"
      peerASN: $${DRG_ASN}
      connectRetryTimeSeconds: 120
      holdTimeSeconds: 90
      keepAliveTimeSeconds: 30
      gracefulRestart:
        enabled: true
        restartTimeSeconds: 120
EOF

# Label the current node for BGP announcements
echo "Labeling master node for BGP..."
kubectl label node $$HOSTNAME io.cilium/bgp-peering-policy=bgp-peering-policy --overwrite
kubectl label node $$HOSTNAME node-role.kubernetes.io/control-plane=true --overwrite

# Create a test service to verify BGP is working
echo "Creating test service to verify BGP announcements..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: bgp-test-service
  namespace: default
  labels:
    app: bgp-test
  annotations:
    io.cilium/bgp-announce: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: bgp-test
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bgp-test-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bgp-test
  template:
    metadata:
      labels:
        app: bgp-test
    spec:
      containers:
      - name: test-app
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "32Mi"
            cpu: "50m"
          limits:
            memory: "64Mi"
            cpu: "100m"
EOF

# Wait for service to get an IP
echo "Waiting for test service to get LoadBalancer IP..."
timeout=300
while [ $$timeout -gt 0 ]; do
  EXTERNAL_IP=$$(kubectl get svc bgp-test-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
  if [ ! -z "$$EXTERNAL_IP" ] && [ "$$EXTERNAL_IP" != "null" ]; then
    echo "Test service got IP: $$EXTERNAL_IP"
    break
  fi
  echo "Waiting for IP assignment... ($$timeout seconds remaining)"
  sleep 10
  timeout=$$((timeout-10))
done

# Verify BGP peering status
echo "Checking BGP peering status..."
kubectl get ciliumlloadbalancerippools -n kube-system
kubectl get ciliumlbgppeeringpolicies -n kube-system
kubectl get svc bgp-test-service

# Save BGP status for troubleshooting
echo "Saving BGP configuration status..."
{
  echo "=== BGP Configuration Summary ==="
  echo "Date: $$(date)"
  echo "Cluster: $$CLUSTER_NAME"
  echo "Local ASN: $$LOCAL_ASN"
  echo "Peer ASN: $$DRG_ASN"
  echo "Peer IP: $$DRG_PEER_IP"
  echo "Announced CIDR: $$BGP_ANNOUNCED_CIDR"
  echo ""
  echo "=== Cilium BGP Resources ==="
  kubectl get ciliumlloadbalancerippools -n kube-system -o yaml
  echo ""
  echo "=== BGP Peering Policies ==="
  kubectl get ciliumlbgppeeringpolicies -n kube-system -o yaml
  echo ""
  echo "=== Test Service Status ==="
  kubectl get svc bgp-test-service -o yaml
} > /tmp/bgp-status.yaml

echo "BGP setup completed successfully!"
echo "Test service IP: $${EXTERNAL_IP:-"pending"}"
echo "Full status saved to /tmp/bgp-status.yaml"

# Final verification
echo "Running final BGP verification..."
if command -v cilium >&/dev/null; then
  cilium bgp peers 2>/dev/null || echo "BGP peer status not available via CLI"
fi

echo "BGP configuration complete. Monitor logs with: kubectl logs -n kube-system -l k8s-app=cilium"
