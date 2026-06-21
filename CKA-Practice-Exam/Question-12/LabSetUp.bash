#!/bin/bash
# setup-ingress-tls.sh
# Question 12 - Networking: Ingress with TLS and Path-Based Routing
set -uo pipefail

echo "Setting up Question 12: Ingress with TLS..."

kubectl create namespace ingress-demo --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-app
  namespace: ingress-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: shop-app
  template:
    metadata:
      labels:
        app: shop-app
    spec:
      containers:
      - name: shop-app
        image: nginx:1.27
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: shop-app
  namespace: ingress-demo
spec:
  selector:
    app: shop-app
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blog-app
  namespace: ingress-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: blog-app
  template:
    metadata:
      labels:
        app: blog-app
    spec:
      containers:
      - name: blog-app
        image: nginx:1.27
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: blog-app
  namespace: ingress-demo
spec:
  selector:
    app: blog-app
  ports:
  - port: 80
    targetPort: 80
EOF

echo "Generating a self-signed TLS certificate for shop.example.com..."
TMPDIR=$(mktemp -d)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$TMPDIR/tls.key" -out "$TMPDIR/tls.crt" \
  -subj "/CN=shop.example.com/O=shop.example.com" \
  -addext "subjectAltName=DNS:shop.example.com" 2>/dev/null

kubectl create secret tls shop-tls-secret \
  --cert="$TMPDIR/tls.crt" --key="$TMPDIR/tls.key" \
  -n ingress-demo --dry-run=client -o yaml | kubectl apply -f -
rm -rf "$TMPDIR"

echo "[OK] Question 12 lab environment ready"
echo "NOTE: An ingress controller (e.g. ingress-nginx) must be installed"
echo "and its IngressClass available for the Ingress to be fully functional."
