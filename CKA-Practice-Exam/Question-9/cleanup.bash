#!/bin/bash
# Cleanup script for Question 9 - Container Runtime Misconfiguration
set -uo pipefail
echo "Cleaning up Question 9: Container Runtime..."

KUBELET_DROPIN="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"

if [[ -f "${KUBELET_DROPIN}.bak" ]]; then
  mv "${KUBELET_DROPIN}.bak" "$KUBELET_DROPIN"
  systemctl daemon-reload
  systemctl restart kubelet
  echo "Restored original kubelet drop-in from backup."
else
  echo "No backup file found; nothing to restore."
fi

echo "[OK] Question 9 cleanup complete"
