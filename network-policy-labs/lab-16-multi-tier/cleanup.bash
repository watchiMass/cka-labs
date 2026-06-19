#!/bin/bash
# Cleanup script - Question 16: Multi-Tier Network Isolation
set -uo pipefail
echo "Cleaning up Question 16: Multi-Tier Network Isolation..."

kubectl delete networkpolicy allow-web-to-api -n api --ignore-not-found
kubectl delete networkpolicy allow-api-to-db default-deny-db -n db --ignore-not-found
kubectl delete namespace web --ignore-not-found
kubectl delete namespace api --ignore-not-found
kubectl delete namespace db --ignore-not-found

echo "[OK] Question 16 cleanup complete"
