#!/bin/bash
# setup-kubectl-patch.sh
# Question 18 - Troubleshooting: kubectl patch — Live Resource Limit Hot-Fix
set -uo pipefail

echo "Setting up Question 18: kubectl patch Resource Limits..."

kubectl create namespace patch-demo --dry-run=client -o yaml | kubectl apply -f -

# Deploy an app that is being OOMKilled because its memory limit is set
# far too low for the workload.
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: report-generator
  namespace: patch-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: report-generator
  template:
    metadata:
      labels:
        app: report-generator
    spec:
      containers:
      - name: report-generator
        image: polinux/stress
        command: ["stress"]
        args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]
        resources:
          requests:
            memory: "50Mi"
            cpu: "50m"
          limits:
            memory: "100Mi"
            cpu: "200m"
EOF

echo "[OK] Question 18 lab environment ready"
echo "Deployment 'report-generator' will repeatedly OOMKill because its"
echo "100Mi memory limit is too low for a 200M memory workload."
