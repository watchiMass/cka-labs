# Step 0: inspect the etcd static pod manifest for cert paths and endpoint
cat /etc/kubernetes/manifests/etcd.yaml | grep -E "cert-file|key-file|trusted-ca-file|listen-client-urls"
# Typical paths:
#   --cert-file=/etc/kubernetes/pki/etcd/server.crt
#   --key-file=/etc/kubernetes/pki/etcd/server.key
#   --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
#   --listen-client-urls=https://127.0.0.1:2379

# Step 1: take the snapshot
mkdir -p /opt/backups
ETCDCTL_API=3 etcdctl snapshot save /opt/backups/etcd-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Step 2: verify snapshot integrity
ETCDCTL_API=3 etcdctl snapshot status /opt/backups/etcd-snapshot.db --write-out=table

# Step 3: simulate data loss
kubectl delete configmap pre-backup-marker -n etcd-demo

# Step 4: restore the snapshot to a NEW data directory (never restore in place)
ETCDCTL_API=3 etcdctl snapshot restore /opt/backups/etcd-snapshot.db \
  --data-dir=/var/lib/etcd-from-backup

# Step 5: point the etcd static pod at the restored data dir
# Edit /etc/kubernetes/manifests/etcd.yaml
# Find the hostPath volume currently mounted at /var/lib/etcd (usually named "etcd-data")
# and change its `path:` field:
#   volumes:
#   - hostPath:
#       path: /var/lib/etcd-from-backup   # was /var/lib/etcd
#       type: DirectoryOrCreate
#     name: etcd-data

# Step 6: kubelet watches the manifests directory and auto-restarts the static pod.
# Confirm:
crictl ps | grep etcd
watch kubectl get pods -n kube-system -l component=etcd

# Step 7: verify the marker ConfigMap is back
kubectl get configmap pre-backup-marker -n etcd-demo -o yaml
