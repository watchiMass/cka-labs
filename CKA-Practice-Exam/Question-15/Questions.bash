# Question 15 (Hard) — Troubleshooting: Full etcd Disaster Recovery
# Domain: Troubleshooting (30%) / Cluster Architecture, Installation & Configuration (25%)

# Scenario
# The cluster's API server is completely unreachable. Initial investigation
# shows the etcd static pod is not running and its data directory appears
# to be missing. A pre-incident snapshot exists at
# /opt/backups/pre-corruption-snapshot.db. You must perform a full
# disaster recovery to bring the control plane back online.

# Tasks
# 1. SSH into the control-plane node.
# 2. Confirm the API server is down (kubectl commands will fail/time out)
#    and investigate why: check for the etcd static pod manifest at
#    /etc/kubernetes/manifests/etcd.yaml (it has been moved aside to
#    /etc/kubernetes/manifests-disabled/etcd.yaml) and confirm
#    /var/lib/etcd no longer exists.
# 3. Restore the snapshot at /opt/backups/pre-corruption-snapshot.db into
#    a fresh data directory at /var/lib/etcd using
#    `etcdctl snapshot restore`, specifying the correct
#    --initial-cluster, --initial-cluster-token, and --name flags for a
#    single-member cluster (inspect the original etcd.yaml in
#    manifests-disabled for the correct --name and
#    --initial-advertise-peer-urls values to reuse).
# 4. Move the etcd static pod manifest back into
#    /etc/kubernetes/manifests/ so kubelet picks it up again.
# 5. Confirm etcd starts successfully and the API server becomes reachable
#    again (kubectl get nodes succeeds).
# 6. Confirm previously existing cluster objects (Deployments, Services,
#    etc. that existed before the incident) are present again, proving
#    the restore succeeded.

# Constraints
# - Do not run `kubeadm reset` or rejoin the node; this must be an
#   in-place etcd recovery.
# - Preserve file ownership/permissions on the restored data directory
#   to match what etcd expects (etcd:etcd or root:root depending on the
#   distro — check the original directory's ownership pattern via the
#   static pod's securityContext if unsure).

# Documentation Reference
# Tasks -> Cluster Administration -> Operating etcd clusters for Kubernetes
# https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#restoring-an-etcd-cluster
