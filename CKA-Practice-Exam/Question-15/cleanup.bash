#!/bin/bash
# Cleanup script for Question 15 - etcd Disaster Recovery
set -uo pipefail
echo "Cleaning up Question 15: etcd Disaster Recovery..."

rm -f /opt/backups/pre-corruption-snapshot.db
rmdir /etc/kubernetes/manifests-disabled 2>/dev/null || true
rm -rf /var/lib/etcd-corrupted-* 2>/dev/null || true

echo "NOTE: The restored /var/lib/etcd directory is now the cluster's live"
echo "etcd state and should NOT be deleted; it is the cluster's data."
echo "[OK] Question 15 cleanup complete"
