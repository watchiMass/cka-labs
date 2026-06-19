#!/bin/bash
# Cleanup script for Question 5 - Deployment Rollout & RBAC
set -uo pipefail

echo "Cleaning up Question 5: Deployment Rollout & RBAC..."
kubectl delete namespace q5-rollout --ignore-not-found
echo "[OK] Question 5 cleanup complete"
