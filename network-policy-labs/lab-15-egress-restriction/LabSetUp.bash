#!/bin/bash
# Lab Setup - Question 15: Egress Restriction
set -e

echo "Creating namespaces..."
kubectl create namespace payments --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace database --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace external --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying payment-service..."
kubectl apply -n payments -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
  namespace: payments
spec:
  replicas: 1
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
    spec:
      containers:
      - name: payment-service
        image: curlimages/curl
        command: ["sleep", "3600"]
EOF

echo "Deploying postgres (database)..."
kubectl apply -n database -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
        tier: db
    spec:
      containers:
      - name: postgres
        image: nginx         # simulating a DB with nginx for connectivity test
        ports:
        - containerPort: 5432
          name: postgres
        - containerPort: 80
          name: http
EOF

kubectl expose deployment postgres -n database --port=5432 --target-port=80 --name=postgres-service

echo "Deploying external-api (forbidden target)..."
kubectl apply -n external -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-api
  namespace: external
spec:
  replicas: 1
  selector:
    matchLabels:
      app: external-api
  template:
    metadata:
      labels:
        app: external-api
    spec:
      containers:
      - name: external-api
        image: nginx
        ports:
        - containerPort: 80
EOF

kubectl expose deployment external-api -n external --port=80 --name=external-api-service

echo "[OK] Lab 15 setup complete."
echo "     payment-service (payments) must reach postgres (database:5432) only"
echo "     Access to namespace 'external' must be blocked"
