#!/bin/bash
# Lab Setup for Question 2 - Service Unreachable Troubleshooting
set -e

echo "Creating namespace..."
kubectl create namespace q2-service --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying web application..."
kubectl apply -n q2-service -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: q2-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
      tier: frontend
  template:
    metadata:
      labels:
        app: web-app
        tier: frontend
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

echo "Deploying broken service (selector mismatch)..."
kubectl apply -n q2-service -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: q2-service
spec:
  selector:
    app: web-app
    tier: backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
EOF

echo "Deploying debug pod to test connectivity..."
kubectl apply -n q2-service -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: debug-pod
  namespace: q2-service
spec:
  containers:
  - name: debug
    image: curlimages/curl
    command: ["sleep", "3600"]
EOF

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=available deployment/web-app -n q2-service --timeout=60s || true

echo "[OK] Lab Q2 setup complete."
echo ""
echo "Your tasks:"
echo "  1. The service 'web-service' is not routing traffic to the 'web-app' pods"
echo "  2. Identify ALL the issues with the service and fix them"
echo "  3. Verify connectivity using the debug-pod:"
echo "     kubectl exec -n q2-service debug-pod -- curl -s http://web-service"
