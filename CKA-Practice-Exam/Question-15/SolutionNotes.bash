# Step 0: confirm the API server is unreachable
kubectl get nodes
# Expect: "The connection to the server ... was refused" or a timeout

# Step 1: SSH to the control-plane node and investigate
ssh user@control-plane-node
ls /etc/kubernetes/manifests/ | grep etcd
# (missing) -- check the disabled directory:
ls /etc/kubernetes/manifests-disabled/
ls /var/lib/etcd 2>&1
# (No such file or directory) -- confirms data dir is gone

# Step 2: inspect the original etcd manifest for the correct flags
cat /etc/kubernetes/manifests-disabled/etcd.yaml | grep -E "initial-advertise-peer-urls|--name=|initial-cluster="
# Example values:
#   --name=control-plane-node
#   --initial-advertise-peer-urls=https://10.0.0.10:2380
#   --initial-cluster=control-plane-node=https://10.0.0.10:2380

# Step 3: restore the snapshot into a fresh data directory with matching flags
ETCDCTL_API=3 etcdctl snapshot restore /opt/backups/pre-corruption-snapshot.db \
  --data-dir=/var/lib/etcd \
  --name=control-plane-node \
  --initial-cluster=control-plane-node=https://10.0.0.10:2380 \
  --initial-advertise-peer-urls=https://10.0.0.10:2380

# Step 4: fix ownership to match what etcd expects (commonly root:root for
# kubeadm-managed clusters, but check the original directory's owner first)
chown -R root:root /var/lib/etcd

# Step 5: move the etcd manifest back so kubelet relaunches the static pod
mv /etc/kubernetes/manifests-disabled/etcd.yaml /etc/kubernetes/manifests/etcd.yaml

# Step 6: watch for the etcd container to come up
watch crictl ps

# Step 7: once etcd is healthy, confirm API server reachability
kubectl get nodes
kubectl get pods -A

# Step 8: confirm pre-incident objects exist again (proves restore worked)
kubectl get deployments -A
kubectl get configmaps -A
