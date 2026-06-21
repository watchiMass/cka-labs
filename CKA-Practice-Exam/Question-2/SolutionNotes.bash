# Step 0 (on cp-node-1): retrieve/regenerate the join materials if expired
kubeadm token create --print-join-command
# Example output:
#   kubeadm join 10.0.0.10:6443 --token abcdef.0123456789abcdef \
#     --discovery-token-ca-cert-hash sha256:<hash>

CERT_KEY=$(kubeadm certs certificate-key)
kubeadm init phase upload-certs --upload-certs --certificate-key "$CERT_KEY"
echo "$CERT_KEY"

# Step 1: SSH to the second control-plane node
ssh user@cp-node-2

# Step 2 (on cp-node-2): run the join command with control-plane flags
sudo kubeadm join 10.0.0.10:6443 \
  --token abcdef.0123456789abcdef \
  --discovery-token-ca-cert-hash sha256:REPLACE_WITH_HASH \
  --control-plane \
  --certificate-key REPLACE_WITH_CERT_KEY_FROM_STEP_0

# Step 3 (on cp-node-2): set up kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Step 4: verify from either node
kubectl get nodes -o wide
# Expect both cp-node-1 and cp-node-2 listed with ROLES=control-plane,STATUS=Ready

# Step 5: verify etcd has 2 members (stacked etcd topology)
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  -w table

# Troubleshooting tips:
# - "context deadline exceeded" usually means ports 6443, 2379-2380, or
#   10250 are blocked between nodes; check with `nc -zv <ip> <port>`.
# - If the token expired, regenerate with `kubeadm token create`.
# - If the cert-key expired (2-hour TTL), regenerate with
#   `kubeadm init phase upload-certs --upload-certs --certificate-key $(kubeadm certs certificate-key)`.
