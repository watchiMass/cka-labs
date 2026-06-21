#!/bin/bash
# Cleanup script for Question 2 - HA Control Plane Join
set -uo pipefail
echo "Cleaning up Question 2: HA Control Plane Join..."

echo "This will remove cp-node-2 from the cluster and reset kubeadm state on it."
echo "Run the following on cp-node-2 itself:"
echo "  sudo kubeadm reset -f"
echo "  sudo rm -rf /etc/cni/net.d /etc/kubernetes /var/lib/etcd \$HOME/.kube"

echo "Then, from cp-node-1, drain and delete the node object:"
kubectl drain cp-node-2 --ignore-daemonsets --delete-emptydir-data --force 2>/dev/null || true
kubectl delete node cp-node-2 --ignore-not-found

echo "[OK] Question 2 cleanup complete"
