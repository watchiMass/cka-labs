#!/bin/bash
# Cleanup script for Question 8 - Complex NetworkPolicy
set -uo pipefail
echo "Cleaning up Question 8: Complex NetworkPolicy..."

kubectl delete namespace frontend --ignore-not-found
kubectl delete namespace backend --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found

echo "[OK] Question 8 cleanup complete"
