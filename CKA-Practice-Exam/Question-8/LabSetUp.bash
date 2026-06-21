#!/bin/bash
# setup-networkpolicy-complex.sh
# Question 8 - Networking: Complex Multi-Rule NetworkPolicy
set -uo pipefail

echo "Setting up Question 8: Complex NetworkPolicy..."

kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

kubectl label namespace frontend tier=frontend --overwrite
kubectl label namespace backend tier=backend --overwrite
kubectl label namespace monitoring tier=monitoring --overwrite

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
        role: api
    spec:
      containers:
      - name: api-server
        image: nginx:1.27
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: api-server
  namespace: backend
spec:
  selector:
    app: api-server
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-client
  namespace: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-client
  template:
    metadata:
      labels:
        app: web-client
    spec:
      containers:
      - name: web-client
        image: busybox
        command: ["sleep", "infinity"]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-scraper
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: metrics-scraper
  template:
    metadata:
      labels:
        app: metrics-scraper
    spec:
      containers:
      - name: metrics-scraper
        image: busybox
        command: ["sleep", "infinity"]
EOF

echo "[OK] Question 8 lab environment ready"
echo "NOTE: This task requires a CNI that enforces NetworkPolicy (e.g. Calico)."
