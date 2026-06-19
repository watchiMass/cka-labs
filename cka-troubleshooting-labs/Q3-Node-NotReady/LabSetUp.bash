#!/bin/bash
# Lab Setup for Question 3 - Node NotReady / Scheduling Troubleshooting
set -e

echo "Detecting worker nodes..."
WORKER1=$(kubectl get nodes --no-headers | grep -v 'control-plane\|master' | awk 'NR==1{print $1}')
WORKER2=$(kubectl get nodes --no-headers | grep -v 'control-plane\|master' | awk 'NR==2{print $1}')

if [[ -z "$WORKER1" ]]; then
  echo "ERROR: No worker node found. This lab requires at least 1 worker node."
  exit 1
fi

echo "Worker nodes found: $WORKER1 ${WORKER2:-'(only one worker)'}"

echo "Creating namespace..."
kubectl create namespace q3-scheduling --dry-run=client -o yaml | kubectl apply -f -

echo "Cordoning node $WORKER1 (simulating maintenance)..."
kubectl cordon "$WORKER1"

echo "Adding a blocking taint to $WORKER1..."
kubectl taint node "$WORKER1" maintenance=true:NoSchedule --overwrite

echo "Deploying a critical application..."
kubectl apply -n q3-scheduling -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-app
  namespace: q3-scheduling
spec:
  replicas: 3
  selector:
    matchLabels:
      app: critical-app
  template:
    metadata:
      labels:
        app: critical-app
    spec:
      containers:
      - name: app
        image: nginx:1.25
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "64Mi"
EOF

echo "Deploying a pod with wrong node selector (will stay Pending)..."
kubectl apply -n q3-scheduling -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: gpu-workload
  namespace: q3-scheduling
spec:
  containers:
  - name: compute
    image: busybox:1.36
    command: ["sleep", "3600"]
    resources:
      requests:
        cpu: "50m"
        memory: "32Mi"
  nodeSelector:
    accelerator: nvidia-tesla-v100
EOF

echo "Saving worker node name for validation..."
echo "$WORKER1" > /tmp/q3-worker1-name.txt
[[ -n "${WORKER2:-}" ]] && echo "$WORKER2" > /tmp/q3-worker2-name.txt

echo "[OK] Lab Q3 setup complete."
echo ""
echo "Affected node : $WORKER1"
echo ""
echo "Your tasks:"
echo "  1. The 'critical-app' deployment has pods stuck in Pending."
echo "     Find out why and fix the node so all 3 replicas can run."
echo "  2. The pod 'gpu-workload' is also Pending."
echo "     Identify the reason and fix it so the pod can be scheduled."
echo "     (Do NOT add GPU labels to the node — fix the pod spec instead)"
