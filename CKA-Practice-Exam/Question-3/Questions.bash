# Question 3 (Hard) — Troubleshooting: Repair a Broken kubelet
# Domain: Troubleshooting (30%)

# Scenario
# Worker node "worker-node-1" has gone NotReady. The on-call engineer
# reports no recent workload changes, suggesting a node-level issue rather
# than an application issue.

# Tasks
# 1. SSH into worker-node-1.
# 2. Check the kubelet service status with `systemctl status kubelet` and
#    review logs with `journalctl -u kubelet -n 100 --no-pager`.
# 3. Identify the root cause (a misconfigured --kubeconfig path in the
#    systemd drop-in unit at
#    /etc/systemd/system/kubelet.service.d/10-kubeadm.conf).
# 4. Correct the kubeconfig path so it points back to the valid file at
#    /etc/kubernetes/kubelet.conf.
# 5. Reload the systemd daemon and restart the kubelet service.
# 6. Confirm the kubelet service is active (running) and enabled at boot.
# 7. From the control-plane node, confirm worker-node-1 transitions back
#    to STATUS=Ready within a couple of minutes.

# Constraints
# - Do not delete and re-join the node; this must be fixed in place.
# - Do not modify any other systemd drop-in files.

# Documentation Reference
# Tasks -> Troubleshooting -> Troubleshoot Clusters
# https://kubernetes.io/docs/tasks/debug/debug-cluster/
