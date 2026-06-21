# Step 0: confirm node is unhealthy from control plane
kubectl get node worker-node-2
kubectl describe node worker-node-2 | grep -A5 Conditions

# Step 1: SSH to the affected node
ssh user@worker-node-2

# Step 2: confirm containerd is actually running and find its real socket
sudo systemctl status containerd --no-pager
ls -l /run/containerd/containerd.sock
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock info

# Step 3: inspect the kubelet drop-in for the misconfigured endpoint
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf | grep container-runtime-endpoint
sudo journalctl -u kubelet -n 50 --no-pager | grep -i "runtime"
# Look for errors like:
#   "Failed to connect to runtime: rpc error... connection error...
#    WRONG.sock: no such file or directory"

# Step 4: fix the kubelet drop-in
sudo sed -i 's#--container-runtime-endpoint=unix:///run/containerd/WRONG.sock#--container-runtime-endpoint=unix:///run/containerd/containerd.sock#' \
  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Step 5: set crictl's default endpoint so future commands don't need --runtime-endpoint
sudo tee /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

# Step 6: reload and restart
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl status kubelet --no-pager

# Step 7: verify
sudo crictl ps
kubectl get node worker-node-2 -w
