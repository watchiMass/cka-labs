#!/bin/bash
# setup-broken-kubelet.sh
# Question 3 - Troubleshooting: Repair a Broken kubelet systemd Service
set -uo pipefail

echo "Setting up Question 3: Broken kubelet..."
echo "This script must run with root privileges on the target worker node (worker-node-1)."

# Intentionally break the kubelet by pointing its systemd drop-in at a
# non-existent kubeconfig path, then stop and disable the service so the
# node goes NotReady.
KUBELET_DROPIN="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"

if [[ -f "$KUBELET_DROPIN" ]]; then
  cp "$KUBELET_DROPIN" "${KUBELET_DROPIN}.bak"
  sed -i 's#--kubeconfig=/etc/kubernetes/kubelet.conf#--kubeconfig=/etc/kubernetes/kubelet-MISSING.conf#' "$KUBELET_DROPIN"
else
  echo "WARNING: $KUBELET_DROPIN not found; adjust path for this distro."
fi

systemctl daemon-reload
systemctl restart kubelet || true

echo "[OK] Question 3 lab environment ready"
echo "kubelet on this node has been intentionally misconfigured and should"
echo "now be in a failed/crash-looping state. The node will show NotReady"
echo "or stop reporting status entirely from the control plane."
