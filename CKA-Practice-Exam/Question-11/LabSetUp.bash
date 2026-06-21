#!/bin/bash
# setup-gateway-api.sh
# Question 11 - Networking: Gateway API HTTPRoute
set -uo pipefail

echo "Setting up Question 11: Gateway API..."

kubectl create namespace gw-demo --dry-run=client -o yaml | kubectl apply -f -

echo "Installing Gateway API CRDs (standard channel)..."
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml

echo "Waiting for Gateway API CRDs to register..."
kubectl wait --for=condition=Established --timeout=60s crd/gateways.gateway.networking.k8s.io || true
kubectl wait --for=condition=Established --timeout=60s crd/httproutes.gateway.networking.k8s.io || true

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: store-backend
  namespace: gw-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: store-backend
  template:
    metadata:
      labels:
        app: store-backend
    spec:
      containers:
      - name: store-backend
        image: nginx:1.27
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: store-backend
  namespace: gw-demo
spec:
  selector:
    app: store-backend
  ports:
  - port: 80
    targetPort: 80
EOF

echo "[OK] Question 11 lab environment ready"
echo "NOTE: A GatewayClass / controller (e.g. Contour, Envoy Gateway, or"
echo "the cluster's chosen implementation) must already be installed for"
echo "the Gateway resource to be programmed; if absent, the HTTPRoute"
echo "config can still be authored and validated structurally."
