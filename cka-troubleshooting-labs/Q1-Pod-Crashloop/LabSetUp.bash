#!/bin/bash
# Lab Setup for Question 1 - Pod CrashLoopBackOff Troubleshooting
set -e

echo "Creating namespace..."
kubectl create namespace q1-crashloop --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying broken pod (bad command)..."
kubectl apply -n q1-crashloop -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: api-server-pod
  namespace: q1-crashloop
  labels:
    app: api-server
spec:
  containers:
  - name: api
    image: nginx:1.25
    command: ["/bin/sh", "-c", "nginx -g 'daemon on;' && sleep 3600"]
    ports:
    - containerPort: 80
    env:
    - name: APP_MODE
      value: "production"
    - name: CONFIG_PATH
      value: "/etc/config/app.conf"
    readinessProbe:
      httpGet:
        path: /healthz
        port: 80
      initialDelaySeconds: 2
      periodSeconds: 3
    livenessProbe:
      httpGet:
        path: /healthz
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
EOF

echo "Deploying broken worker deployment (wrong image tag)..."
kubectl apply -n q1-crashloop -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker-deployment
  namespace: q1-crashloop
spec:
  replicas: 2
  selector:
    matchLabels:
      app: worker
  template:
    metadata:
      labels:
        app: worker
    spec:
      containers:
      - name: worker
        image: busybox:9.9.9
        command: ["sh", "-c", "while true; do echo working; sleep 10; done"]
EOF

echo "[OK] Lab Q1 setup complete."
echo ""
echo "Your tasks:"
echo "  1. Identify why 'api-server-pod' is not ready in namespace q1-crashloop"
echo "  2. Fix the pod so it passes its readiness and liveness probes"
echo "  3. Identify why 'worker-deployment' pods are not starting"
echo "  4. Fix the deployment so that its 2 replicas are Running"
