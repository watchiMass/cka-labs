#!/bin/bash
# setup-priorityclass.sh
# Question 7 - Workloads: PriorityClass and Pod Preemption
set -uo pipefail

echo "Setting up Question 7: PriorityClass..."

kubectl create namespace priority-demo --dry-run=client -o yaml | kubectl apply -f -

# Deploy a low-priority Deployment that intentionally consumes most of a
# node's allocatable CPU, so a later high-priority pod cannot be scheduled
# without preempting one of these.
NODE_CPU_MILLI=$(kubectl get nodes -o jsonpath='{.items[0].status.allocatable.cpu}')
echo "Detected node allocatable CPU: $NODE_CPU_MILLI"

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: filler
  namespace: priority-demo
spec:
  replicas: 4
  selector:
    matchLabels:
      app: filler
  template:
    metadata:
      labels:
        app: filler
    spec:
      containers:
      - name: filler
        image: nginx:1.27
        resources:
          requests:
            cpu: "500m"
          limits:
            cpu: "500m"
EOF

echo "[OK] Question 7 lab environment ready"
echo "Namespace 'priority-demo' has 4 'filler' pods consuming cluster CPU."
