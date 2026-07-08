#!/bin/bash
# Run on controlplane to remove node01 from the cluster (does not reset node01 itself)
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data --force 2>/dev/null || true
kubectl delete node node01 --ignore-not-found=true
echo "Cleanup complete. If reusing node01 for another attempt, run 'kubeadm reset -f' on node01 itself."
