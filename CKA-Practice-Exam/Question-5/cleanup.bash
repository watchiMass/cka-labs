#!/bin/bash
# Cleanup script for Question 5 - HPA
set -uo pipefail
echo "Cleaning up Question 5: HPA..."

kubectl delete pod load-generator -n hpa-demo --ignore-not-found
kubectl delete hpa cpu-stress-hpa -n hpa-demo --ignore-not-found
kubectl delete namespace hpa-demo --ignore-not-found

echo "[OK] Question 5 cleanup complete"
