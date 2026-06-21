#!/bin/bash
# setup-etcd-disaster-recovery.sh
# Question 15 - Troubleshooting: API Server Down Due to Corrupted etcd
set -uo pipefail

echo "Setting up Question 15: etcd Disaster Recovery..."
echo "This script must run with root privileges on the control-plane node."

# Take a known-good snapshot first (so the lab is recoverable even if
# something goes wrong), then corrupt the live etcd data directory to
# simulate catastrophic data loss requiring a full restore.

mkdir -p /opt/backups
ETCDCTL_API=3 etcdctl snapshot save /opt/backups/pre-corruption-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

echo "Stopping etcd static pod by moving its manifest out of the watched directory..."
mkdir -p /etc/kubernetes/manifests-disabled
mv /etc/kubernetes/manifests/etcd.yaml /etc/kubernetes/manifests-disabled/etcd.yaml

echo "Corrupting the etcd data directory..."
mv /var/lib/etcd /var/lib/etcd-corrupted-$(date +%s) 2>/dev/null || true

echo "[OK] Question 15 lab environment ready"
echo "etcd is now stopped and its data directory has been moved aside,"
echo "simulating catastrophic data loss. The API server will be unreachable"
echo "until etcd is restored. A pre-corruption snapshot is saved at"
echo "/opt/backups/pre-corruption-snapshot.db for the candidate to restore from."
