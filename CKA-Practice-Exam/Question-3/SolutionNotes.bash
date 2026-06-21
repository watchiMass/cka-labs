# Step 0: confirm the node is NotReady from the control plane
kubectl get nodes worker-node-1

# Step 1: SSH to the broken node
ssh user@worker-node-1

# Step 2: check kubelet service status
sudo systemctl status kubelet --no-pager
# Look for "Active: failed" or frequent restarts

# Step 3: check logs for the specific error
sudo journalctl -u kubelet -n 100 --no-pager
# Look for something like:
#   "error: failed to load kubelet config file /etc/kubernetes/kubelet-MISSING.conf:
#    open /etc/kubernetes/kubelet-MISSING.conf: no such file or directory"

# Step 4: inspect the systemd drop-in that defines the kubeconfig flag
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf | grep kubeconfig
# Confirm the file referenced in --kubeconfig= actually exists:
ls -l /etc/kubernetes/kubelet.conf

# Step 5: fix the drop-in to point at the correct, existing file
sudo sed -i 's#--kubeconfig=/etc/kubernetes/kubelet-MISSING.conf#--kubeconfig=/etc/kubernetes/kubelet.conf#' \
  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Step 6: reload systemd and restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl enable kubelet

# Step 7: confirm it's healthy
sudo systemctl status kubelet --no-pager
sudo journalctl -u kubelet -n 30 --no-pager

# Step 8 (back on control plane): confirm node is Ready
kubectl get nodes worker-node-1 -w
