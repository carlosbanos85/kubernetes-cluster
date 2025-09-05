#!/bin/bash

set -e
export PATH="/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin"
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Configuration from Terraform template
HOSTNAME="${hostname}"
BGP_ANNOUNCED_CIDR="${bgp_announced_cidr}"
CLUSTER_NAME="${cluster_name}"

echo "=== ENHANCED BGP SETUP WITH NODE PUBLIC IPs ==="
echo "Date: $(date)"
echo "Cluster: $CLUSTER_NAME"
echo "Node: $HOSTNAME"

# Wait for Cilium to be ready
echo "Waiting for Cilium to be ready..."
kubectl wait --for=condition=ready --all pods -n kube-system -l k8s-app=cilium --timeout=300s

# Wait for BGP CRDs
echo "Waiting for Cilium LoadBalancer CRDs..."
until kubectl get crd ciliumloadbalancerippools.cilium.io >/dev/null 2>&1; do
  sleep 10
done

# Get node public IP
echo "Discovering node public IP..."
MASTER_PUBLIC_IP=$(kubectl get node $HOSTNAME -o jsonpath='{.status.addresses[?(@.type=="ExternalIP")].address}')
echo "Master public IP: $MASTER_PUBLIC_IP"

# Create internal BGP pool
echo "Creating internal BGP IP pool..."
cat <<EOF | kubectl apply -f -
apiVersion: "cilium.io/v2alpha1"
kind: CiliumLoadBalancerIPPool
metadata:
  name: internal-bgp-pool
  namespace: kube-system
  labels:
    pool-type: "internal"
spec:
  blocks:
  - cidr: "${BGP_ANNOUNCED_CIDR}"
  serviceSelector:
    matchLabels:
      service-type: "internal"
EOF

# Create external public IP pool using node public IP
if [ ! -z "$MASTER_PUBLIC_IP" ]; then
  echo "Creating external public IP pool..."
  cat <<EOF | kubectl apply -f -
apiVersion: "cilium.io/v2alpha1"
kind: CiliumLoadBalancerIPPool
metadata:
  name: external-public-pool
  namespace: kube-system
  labels:
    pool-type: "external"
spec:
  blocks:
  - start: "${MASTER_PUBLIC_IP}"
    stop: "${MASTER_PUBLIC_IP}"
  serviceSelector:
    matchLabels:
      service-type: "external"
EOF
fi

# Create test services
echo "Creating example services..."

# Internal service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: internal-api
  labels:
    service-type: "internal"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: internal-api
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: internal-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: internal-api
  template:
    metadata:
      labels:
        app: internal-api
    spec:
      containers:
      - name: api
        image: nginx:alpine
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
          limits:
            memory: "64Mi"
            cpu: "50m"
EOF

# External service (if we have public IP)
if [ ! -z "$MASTER_PUBLIC_IP" ]; then
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: external-web
  labels:
    service-type: "external"
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  ports:
  - port: 80
    targetPort: 8080
    name: http
  - port: 8080
    targetPort: 8080
    name: http-alt
  selector:
    app: external-web
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: external-web
  template:
    metadata:
      labels:
        app: external-web
    spec:
      nodeSelector:
        kubernetes.io/hostname: ${HOSTNAME}
      containers:
      - name: web
        image: nginx:alpine
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
          limits:
            memory: "64Mi"
            cpu: "50m"
EOF
fi

# Wait for IP assignments
echo "Waiting for service IP assignments..."
sleep 30

# Display results
echo ""
echo "=== SERVICE STATUS ==="
kubectl get svc internal-api external-web 2>/dev/null || kubectl get svc

# Verify external service got public IP
if [ ! -z "$MASTER_PUBLIC_IP" ]; then
  EXTERNAL_SVC_IP=$(kubectl get svc external-web -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
  if [ "$EXTERNAL_SVC_IP" = "$MASTER_PUBLIC_IP" ]; then
    echo ""
    echo "✓ External service using node public IP: $EXTERNAL_SVC_IP"
    echo "Test external access: curl http://$EXTERNAL_SVC_IP"
  fi
fi

echo ""
echo "=== SETUP COMPLETE ==="
echo "Internal services: Use service-type: internal (BGP pool)"
echo "External services: Use service-type: external (public IP)"
