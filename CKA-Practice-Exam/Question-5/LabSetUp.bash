#!/bin/bash
# setup-hpa.sh
# Question 5 - Workloads: HorizontalPodAutoscaler with Scaling Behavior
set -uo pipefail

echo "Setting up Question 5: HPA..."

kubectl create namespace hpa-demo --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-stress
  namespace: hpa-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cpu-stress
  template:
    metadata:
      labels:
        app: cpu-stress
    spec:
      containers:
      - name: cpu-stress
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "200m"
          limits:
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: cpu-stress
  namespace: hpa-demo
spec:
  selector:
    app: cpu-stress
  ports:
  - port: 80
    targetPort: 80
EOF

echo "Checking for metrics-server..."
if ! kubectl get deployment metrics-server -n kube-system >/dev/null 2>&1; then
  echo "WARNING: metrics-server not detected in kube-system."
  echo "Install it (with --kubelet-insecure-tls for lab clusters) before proceeding:"
  echo "  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
fi

echo "[OK] Question 5 lab environment ready"
