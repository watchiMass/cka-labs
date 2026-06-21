# Question 1 (Hard) — Cluster Architecture: etcd Backup & Restore with TLS
# Domain: Cluster Architecture, Installation & Configuration (25%)

# Scenario
# Your organization requires a disaster-recovery drill on the etcd datastore
# of a stacked control-plane cluster. You must take a TLS-secured snapshot
# of etcd, simulate data loss, and restore the cluster from that snapshot.

# Tasks
# 1. Identify the etcd endpoint, CA certificate, server certificate, and key
#    used by the etcd static pod (inspect /etc/kubernetes/manifests/etcd.yaml
#    on the control-plane node).
# 2. Take a snapshot of etcd and save it to /opt/backups/etcd-snapshot.db
#    using `etcdctl snapshot save`, authenticating with the correct
#    --cacert, --cert, and --key flags.
# 3. Verify the snapshot is valid using `etcdctl snapshot status`.
# 4. Simulate data loss: delete the ConfigMap "pre-backup-marker" in the
#    "etcd-demo" namespace.
# 5. Restore etcd from the snapshot into a new data directory
#    /var/lib/etcd-from-backup using `etcdctl snapshot restore`.
# 6. Update the etcd static pod manifest to point hostPath volume
#    "etcd-data" at /var/lib/etcd-from-backup instead of the original
#    data directory, so kubelet restarts etcd against the restored data.
# 7. Confirm the cluster recovers and the ConfigMap "pre-backup-marker"
#    exists again in the "etcd-demo" namespace (proving the restore
#    rolled back to the pre-deletion state).

# Constraints
# - Do not stop the kubelet manually unless required for the static pod
#   to pick up the manifest change; static pods restart automatically
#   when their manifest file changes.
# - The original snapshot file must remain at /opt/backups/etcd-snapshot.db
#   for grading.

# Documentation Reference
# Tasks -> Cluster Administration -> Operating etcd clusters for Kubernetes
# https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
