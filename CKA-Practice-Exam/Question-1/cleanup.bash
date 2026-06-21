#!/bin/bash
# Cleanup script for Question 1 - etcd Backup & Restore
set -uo pipefail
echo "Cleaning up Question 1: etcd Backup & Restore..."

kubectl delete namespace etcd-demo --ignore-not-found

# Remove backup artifacts. Caution: only remove the *practice* backup,
# never delete real production etcd snapshots.
rm -f /opt/backups/etcd-snapshot.db
rm -rf /var/lib/etcd-from-backup

echo "NOTE: If you modified /etc/kubernetes/manifests/etcd.yaml to point at"
echo "/var/lib/etcd-from-backup, revert the hostPath back to /var/lib/etcd"
echo "(or your distro's original etcd data directory) before continuing,"
echo "otherwise the next kubelet restart will fail to find that path."

echo "[OK] Question 1 cleanup complete"
