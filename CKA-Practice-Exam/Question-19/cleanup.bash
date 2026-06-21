#!/bin/bash
# Cleanup script for Question 19 - Resource Allocation v2
set -uo pipefail
echo "Cleaning up Question 19: Resource Allocation v2..."

kubectl delete namespace alloc-v2-demo --ignore-not-found

NODES=($(kubectl get nodes -l 'pool' -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || true))
for n in "${NODES[@]:-}"; do
  [[ -n "$n" ]] && kubectl label node "$n" pool- 2>/dev/null || true
done

echo "[OK] Question 19 cleanup complete"
