#!/bin/bash
# setup-tls-mismatch.sh
# Question 17 - Troubleshooting: Ingress TLS Secret/Hostname Mismatch
set -uo pipefail

echo "Setting up Question 17: TLS Cert Mismatch..."

kubectl create namespace tls-demo --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-backend
  namespace: tls-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-backend
  template:
    metadata:
      labels:
        app: api-backend
    spec:
      containers:
      - name: api-backend
        image: nginx:1.27
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: api-backend
  namespace: tls-demo
spec:
  selector:
    app: api-backend
  ports:
  - port: 80
    targetPort: 80
EOF

echo "Generating a TLS certificate for the WRONG hostname (mismatch)..."
TMPDIR=$(mktemp -d)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$TMPDIR/tls.key" -out "$TMPDIR/tls.crt" \
  -subj "/CN=wrong-host.example.com/O=wrong-host.example.com" \
  -addext "subjectAltName=DNS:wrong-host.example.com" 2>/dev/null

kubectl create secret tls api-tls-secret \
  --cert="$TMPDIR/tls.crt" --key="$TMPDIR/tls.key" \
  -n tls-demo --dry-run=client -o yaml | kubectl apply -f -
rm -rf "$TMPDIR"

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: tls-demo
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.example.com
    secretName: api-tls-secret
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-backend
            port:
              number: 80
EOF

echo "[OK] Question 17 lab environment ready"
echo "Ingress 'api-ingress' references host api.example.com, but the TLS"
echo "secret was issued for wrong-host.example.com — a deliberate mismatch."
