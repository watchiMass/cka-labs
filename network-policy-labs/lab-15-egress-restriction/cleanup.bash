#!/bin/bash
# Cleanup script - Question 15: Egress Restriction
set -uo pipefail
echo "Cleaning up Question 15: Egress Restriction..."

kubectl delete networkpolicy restrict-egress-payments -n payments --ignore-not-found
kubectl delete namespace payments --ignore-not-found
kubectl delete namespace database --ignore-not-found
kubectl delete namespace external --ignore-not-found

echo "[OK] Question 15 cleanup complete"
