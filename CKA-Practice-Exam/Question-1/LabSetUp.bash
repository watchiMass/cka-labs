#!/bin/bash
# setup-etcd-backup.sh
# Question 1 - etcd Backup & Restore with TLS
set -uo pipefail

echo "Setting up Question 1: etcd Backup & Restore..."

# Create a namespace and a ConfigMap that represents "important cluster state"
# The candidate will snapshot etcd while this exists, delete it, then restore
# from the snapshot to prove the restore worked.
kubectl create namespace etcd-demo --dry-run=client -o yaml | kubectl apply -f -

kubectl create configmap pre-backup-marker \
  --from-literal=marker="this-must-survive-the-restore" \
  -n etcd-demo --dry-run=client -o yaml | kubectl apply -f -

# Ensure the etcdctl binary is available on the control plane node
if ! command -v etcdctl >/dev/null 2>&1; then
  echo "WARNING: etcdctl not found on PATH. Install via:"
  echo "  apt-get update && apt-get install -y etcd-client"
fi

echo "[OK] Question 1 lab environment ready"
echo "Namespace 'etcd-demo' and ConfigMap 'pre-backup-marker' created."
