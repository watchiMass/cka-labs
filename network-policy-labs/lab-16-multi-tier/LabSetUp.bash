#!/bin/bash
# Lab Setup - Question 16: Multi-Tier Network Isolation
set -e

echo "Creating namespaces..."
for ns in web api db; do
  kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -
done

echo "Deploying web tier..."
kubectl apply -n web -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-frontend
  namespace: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-frontend
      tier: web
  template:
    metadata:
      labels:
        app: web-frontend
        tier: web
    spec:
      containers:
      - name: web
        image: curlimages/curl
        command: ["sleep", "3600"]
EOF

echo "Deploying api tier..."
kubectl apply -n api -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-server
      tier: api
  template:
    metadata:
      labels:
        app: api-server
        tier: api
    spec:
      containers:
      - name: api
        image: nginx
        ports:
        - containerPort: 8080
        - containerPort: 80
EOF

kubectl expose deployment api-server -n api --port=8080 --target-port=80 --name=api-service

echo "Deploying db tier..."
kubectl apply -n db -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
      tier: db
  template:
    metadata:
      labels:
        app: mysql
        tier: db
    spec:
      containers:
      - name: mysql
        image: nginx          # simulating MySQL with nginx for connectivity test
        ports:
        - containerPort: 3306
        - containerPort: 80
EOF

kubectl expose deployment mysql -n db --port=3306 --target-port=80 --name=mysql-service

echo "[OK] Lab 16 setup complete. Three-tier architecture deployed:"
echo "     web (web-frontend) → api (api-server:8080) → db (mysql:3306)"
echo "     web → db must be BLOCKED"
