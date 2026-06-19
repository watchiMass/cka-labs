#!/bin/bash
# Lab Setup - Question 14: Default Deny + Selective Allow
set -e

echo "Creating namespaces..."
kubectl create namespace app --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying app (web server)..."
kubectl apply -n app -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
        tier: frontend
    spec:
      containers:
      - name: webapp
        image: nginx
        ports:
        - containerPort: 80
EOF

echo "Exposing webapp as ClusterIP service..."
kubectl expose deployment webapp -n app --port=80 --target-port=80 --name=webapp-service

echo "Deploying allowed client (prometheus scraper)..."
kubectl apply -n monitoring -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: curlimages/curl
        command: ["sleep", "3600"]
EOF

echo "Deploying forbidden client (rogue pod)..."
kubectl apply -n monitoring -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rogue
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rogue
  template:
    metadata:
      labels:
        app: rogue
    spec:
      containers:
      - name: rogue
        image: curlimages/curl
        command: ["sleep", "3600"]
EOF

echo "[OK] Lab 14 setup complete. Namespaces: app, monitoring"
echo "     webapp-service exposed on port 80 in namespace app"
