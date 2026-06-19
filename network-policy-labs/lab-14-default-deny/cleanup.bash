#!/bin/bash
# Cleanup script - Question 14: Default Deny + Selective Allow
set -uo pipefail
echo "Cleaning up Question 14: Default Deny + Selective Allow..."

kubectl delete networkpolicy default-deny-ingress allow-prometheus -n app --ignore-not-found
kubectl delete namespace app --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found

echo "[OK] Question 14 cleanup complete"
