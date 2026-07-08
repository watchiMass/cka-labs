#!/bin/bash
set -e

kubectl create namespace project-h800 --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: o3db
  namespace: project-h800
spec:
  clusterIP: None
  selector:
    app: o3db
  ports:
  - port: 80
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: o3db
  namespace: project-h800
spec:
  serviceName: "o3db"
  replicas: 2
  selector:
    matchLabels:
      app: o3db
  template:
    metadata:
      labels:
        app: o3db
    spec:
      containers:
      - name: o3db
        image: httpd:2-alpine
        ports:
        - containerPort: 80
EOF

echo "Setup complete. Waiting for pods to be ready..."
kubectl -n project-h800 wait --for=condition=ready pod -l app=o3db --timeout=90s || true
