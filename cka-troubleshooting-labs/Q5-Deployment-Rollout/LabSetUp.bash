#!/bin/bash
# Lab Setup for Question 5 - Deployment Rollout Stuck
set -e

echo "Creating namespace..."
kubectl create namespace q5-rollout --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying app with resource limits too low (OOMKilled / CPU throttle)..."
kubectl apply -n q5-rollout -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-hog
  namespace: q5-rollout
spec:
  replicas: 2
  selector:
    matchLabels:
      app: memory-hog
  template:
    metadata:
      labels:
        app: memory-hog
    spec:
      containers:
      - name: app
        image: nginx:1.25
        resources:
          requests:
            cpu: "10m"
            memory: "4Mi"
          limits:
            cpu: "20m"
            memory: "4Mi"
EOF

echo "Deploying app with stuck rollout (bad maxUnavailable + wrong image)..."
kubectl apply -n q5-rollout -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-app
  namespace: q5-rollout
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 0
  selector:
    matchLabels:
      app: rolling-app
  template:
    metadata:
      labels:
        app: rolling-app
    spec:
      containers:
      - name: app
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

echo "Waiting for rolling-app to be ready..."
kubectl rollout status deployment/rolling-app -n q5-rollout --timeout=30s || true

echo "Triggering a broken update on rolling-app (invalid image)..."
kubectl set image deployment/rolling-app app=nginx:does-not-exist -n q5-rollout

echo "Deploying app with RBAC issue (ServiceAccount missing permissions)..."
kubectl apply -n q5-rollout -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-reader-sa
  namespace: q5-rollout
EOF

kubectl apply -n q5-rollout -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rbac-app
  namespace: q5-rollout
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rbac-app
  template:
    metadata:
      labels:
        app: rbac-app
    spec:
      serviceAccountName: pod-reader-sa
      containers:
      - name: kubectl-sidecar
        image: bitnami/kubectl:latest
        command: ["sh", "-c", "while true; do kubectl get pods -n q5-rollout; sleep 10; done"]
EOF

echo "[OK] Lab Q5 setup complete."
echo ""
echo "Your tasks:"
echo "  1. 'memory-hog' pods are OOMKilled. Fix resources so the pods stay Running."
echo "     Set memory limit to at least 32Mi."
echo "  2. 'rolling-app' rollout is stuck. Find out why and roll it back to"
echo "     the last working version."
echo "  3. 'rbac-app' pod runs but gets 'Forbidden' when listing pods."
echo "     Create the necessary RBAC resources so pod-reader-sa can list"
echo "     pods in namespace q5-rollout."
