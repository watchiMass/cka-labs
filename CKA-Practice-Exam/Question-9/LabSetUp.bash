#!/bin/bash
# setup-cri-dockerd.sh
# Question 9 - Cluster Architecture: Container Runtime Migration to containerd
set -uo pipefail

echo "Setting up Question 9: Container Runtime Misconfiguration..."
echo "This script must run with root privileges on worker-node-2."

# Simulate a worker node where the kubelet is misconfigured to talk to a
# non-existent/incorrect CRI socket, so the node cannot run any pods.
KUBELET_DROPIN="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"

if [[ -f "$KUBELET_DROPIN" ]]; then
  cp "$KUBELET_DROPIN" "${KUBELET_DROPIN}.bak"
  # Point kubelet at a non-existent CRI socket
  if grep -q "container-runtime-endpoint" "$KUBELET_DROPIN"; then
    sed -i 's#--container-runtime-endpoint=unix:///run/containerd/containerd.sock#--container-runtime-endpoint=unix:///run/containerd/WRONG.sock#' "$KUBELET_DROPIN"
  else
    sed -i 's#$#--container-runtime-endpoint=unix:///run/containerd/WRONG.sock"#' "$KUBELET_DROPIN"
  fi
else
  echo "WARNING: $KUBELET_DROPIN not found; adjust for this distro/init system."
fi

systemctl daemon-reload
systemctl restart kubelet || true

echo "[OK] Question 9 lab environment ready"
echo "kubelet on worker-node-2 now points at an invalid CRI socket and"
echo "cannot create any new pods; existing pods may also start failing."
