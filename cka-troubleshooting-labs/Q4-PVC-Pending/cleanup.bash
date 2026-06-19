#!/bin/bash
# Cleanup script for Question 4 - PVC Pending Troubleshooting
set -uo pipefail

echo "Cleaning up Question 4: PVC Pending..."
kubectl delete namespace q4-storage --ignore-not-found
kubectl delete storageclass fast-ssd --ignore-not-found
echo "[OK] Question 4 cleanup complete"
