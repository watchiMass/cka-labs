#!/bin/bash
# Cleanup script for Question 7 - PriorityClass & Preemption
set -uo pipefail
echo "Cleaning up Question 7: PriorityClass..."

kubectl delete pod critical-task -n priority-demo --ignore-not-found
kubectl delete namespace priority-demo --ignore-not-found
kubectl delete priorityclass low-priority --ignore-not-found
kubectl delete priorityclass high-priority-critical --ignore-not-found

echo "[OK] Question 7 cleanup complete"
