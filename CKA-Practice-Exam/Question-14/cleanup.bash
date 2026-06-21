#!/bin/bash
# Cleanup script for Question 14 - StorageClass & Volume Expansion
set -uo pipefail
echo "Cleaning up Question 14: StorageClass & Volume Expansion..."

kubectl delete pod storage-test -n storage-demo --ignore-not-found
kubectl delete pvc app-data-claim -n storage-demo --ignore-not-found
kubectl delete namespace storage-demo --ignore-not-found
kubectl delete storageclass expandable-storage --ignore-not-found

echo "[OK] Question 14 cleanup complete"
