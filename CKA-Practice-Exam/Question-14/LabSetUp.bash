#!/bin/bash
# setup-storageclass-expansion.sh
# Question 14 - Storage: StorageClass, Dynamic Provisioning & Volume Expansion
set -uo pipefail

echo "Setting up Question 14: StorageClass & Volume Expansion..."

kubectl create namespace storage-demo --dry-run=client -o yaml | kubectl apply -f -

echo "Checking for an existing provisioner to base the StorageClass on..."
kubectl get storageclass

echo "[OK] Question 14 lab environment ready"
echo "Namespace 'storage-demo' created. Candidate must create the"
echo "StorageClass, PVC, and Pod from scratch."
