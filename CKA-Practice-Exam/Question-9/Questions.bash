# Question 9 (Hard) — Troubleshooting / Cluster Architecture: Container Runtime
# Domain: Troubleshooting (30%) / Cluster Architecture, Installation & Configuration (25%)

# Scenario
# Worker node "worker-node-2" cannot schedule or run any new pods. Existing
# pods on the node may also be reporting CreateContainerError or similar
# CRI-related failures. You suspect the kubelet is misconfigured to talk
# to the wrong Container Runtime Interface (CRI) socket.

# Tasks
# 1. SSH into worker-node-2.
# 2. Confirm containerd is installed and its actual CRI socket path
#    (typically /run/containerd/containerd.sock) using
#    `systemctl status containerd` and `crictl --runtime-endpoint
#    unix:///run/containerd/containerd.sock info`.
# 3. Inspect the kubelet's configured --container-runtime-endpoint flag
#    in /etc/systemd/system/kubelet.service.d/10-kubeadm.conf and compare
#    it to the actual containerd socket path.
# 4. Correct the --container-runtime-endpoint flag to point at the real
#    socket (unix:///run/containerd/containerd.sock).
# 5. Also set the default endpoint for crictl itself by creating/updating
#    /etc/crictl.yaml with:
#      runtime-endpoint: unix:///run/containerd/containerd.sock
#      image-endpoint: unix:///run/containerd/containerd.sock
#      timeout: 10
#      debug: false
# 6. Reload systemd and restart kubelet.
# 7. Confirm `crictl ps` (without flags, using the new default endpoint)
#    lists running containers, and that worker-node-2 returns to
#    STATUS=Ready in `kubectl get nodes`.

# Constraints
# - Do not reinstall containerd or reset the node; this is a configuration
#   fix only.
# - Do not switch to a different CRI implementation (e.g. CRI-O); the
#   cluster standardizes on containerd.

# Documentation Reference
# Setup -> Production Environment -> Container Runtimes
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
