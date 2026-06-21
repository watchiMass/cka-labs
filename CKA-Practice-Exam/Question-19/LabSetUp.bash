#!/bin/bash
# setup-resource-allocation-v2.sh
# Question 19 - Workloads: Resource Allocation v2 — Pod Scheduling Across Labeled Nodes
set -uo pipefail

echo "Setting up Question 19: Resource Allocation v2..."

kubectl create namespace alloc-v2-demo --dry-run=client -o yaml | kubectl apply -f -

# Label two worker nodes differently to represent two pools with distinct
# capacity profiles.
NODES=($(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[*].metadata.name}'))
if [[ ${#NODES[@]} -lt 2 ]]; then
  echo "WARNING: fewer than 2 worker nodes detected; this lab is designed"
  echo "for a multi-worker-node cluster. Proceeding with what's available."
fi

if [[ ${#NODES[@]} -ge 1 ]]; then
  kubectl label node "${NODES[0]}" pool=standard --overwrite
fi
if [[ ${#NODES[@]} -ge 2 ]]; then
  kubectl label node "${NODES[1]}" pool=highmem --overwrite
fi

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: analytics-worker
  namespace: alloc-v2-demo
spec:
  replicas: 4
  selector:
    matchLabels:
      app: analytics-worker
  template:
    metadata:
      labels:
        app: analytics-worker
    spec:
      containers:
      - name: analytics-worker
        image: nginx:1.27
EOF

echo "[OK] Question 19 lab environment ready"
echo "Nodes labeled: pool=standard / pool=highmem (where available)."
