#!/bin/bash
# Cleanup script for Question 13 - Default-Deny NetworkPolicy
set -uo pipefail
echo "Cleaning up Question 13: Default-Deny NetworkPolicy..."

kubectl delete namespace secure-zone --ignore-not-found
kubectl delete namespace trusted-clients --ignore-not-found
kubectl delete namespace untrusted-clients --ignore-not-found

echo "[OK] Question 13 cleanup complete"
