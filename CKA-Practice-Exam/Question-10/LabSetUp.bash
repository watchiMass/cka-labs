#!/bin/bash
# setup-taints-affinity.sh
# Question 10 - Workloads: Taints, Tolerations & Node Affinity Combined
set -uo pipefail

echo "Setting up Question 10: Taints, Tolerations & Affinity..."

kubectl create namespace scheduling-demo --dry-run=client -o yaml | kubectl apply -f -

# Label and taint a node to represent a dedicated GPU node pool
WORKER=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')
if [[ -z "$WORKER" ]]; then
  echo "ERROR: no worker node found to taint."
  exit 1
fi
echo "Using node: $WORKER"

kubectl label node "$WORKER" hardware=gpu --overwrite
kubectl taint node "$WORKER" dedicated=gpu-workloads:NoSchedule --overwrite

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: generic-app
  namespace: scheduling-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: generic-app
  template:
    metadata:
      labels:
        app: generic-app
    spec:
      containers:
      - name: generic-app
        image: nginx:1.27
EOF

echo "[OK] Question 10 lab environment ready"
echo "Node '$WORKER' is labeled hardware=gpu and tainted dedicated=gpu-workloads:NoSchedule"
