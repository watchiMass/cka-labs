#!/bin/bash
# Cleanup script for Question 3 - Node Scheduling Troubleshooting
set -uo pipefail

echo "Cleaning up Question 3: Node Scheduling..."

WORKER1=$(cat /tmp/q3-worker1-name.txt 2>/dev/null || kubectl get nodes --no-headers | grep -v 'control-plane\|master' | awk 'NR==1{print $1}')

if [[ -n "$WORKER1" ]]; then
  echo "Removing maintenance taint from $WORKER1 (if present)..."
  kubectl taint node "$WORKER1" maintenance=true:NoSchedule- 2>/dev/null || true
  echo "Uncordoning $WORKER1 (if cordoned)..."
  kubectl uncordon "$WORKER1" 2>/dev/null || true
fi

kubectl delete namespace q3-scheduling --ignore-not-found
rm -f /tmp/q3-worker1-name.txt /tmp/q3-worker2-name.txt

echo "[OK] Question 3 cleanup complete"
