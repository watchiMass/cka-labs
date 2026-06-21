#!/bin/bash
# Cleanup script for Question 10 - Taints, Tolerations & Affinity
set -uo pipefail
echo "Cleaning up Question 10: Taints & Affinity..."

kubectl delete namespace scheduling-demo --ignore-not-found

GPU_NODE=$(kubectl get nodes -l hardware=gpu -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
if [[ -n "$GPU_NODE" ]]; then
  kubectl taint node "$GPU_NODE" dedicated=gpu-workloads:NoSchedule- 2>/dev/null || true
  kubectl label node "$GPU_NODE" hardware- 2>/dev/null || true
  echo "Removed taint and label from node $GPU_NODE"
fi

echo "[OK] Question 10 cleanup complete"
