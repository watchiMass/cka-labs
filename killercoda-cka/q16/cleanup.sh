#!/bin/bash
# Restore original coredns config if backup exists, else just clean test artifacts
if [ -f /opt/course/16/coredns_backup.yaml ]; then
  kubectl apply -f /opt/course/16/coredns_backup.yaml 2>/dev/null || true
  kubectl -n kube-system rollout restart deployment coredns 2>/dev/null || true
fi
kubectl delete pod dns-test-16 --ignore-not-found=true --wait=false
rm -rf /opt/course/16
echo "Cleanup complete"
