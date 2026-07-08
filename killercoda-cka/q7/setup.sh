#!/bin/bash
set -e

mkdir -p /opt/course/7

# Install metrics-server if not present (needed for kubectl top)
if ! kubectl get deployment metrics-server -n kube-system &>/dev/null; then
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  # Patch for insecure kubelet TLS in test/kind-like environments
  kubectl patch deployment metrics-server -n kube-system --type='json' \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' 2>/dev/null || true
fi

echo "Setup complete. Waiting a bit for metrics-server to warm up (may take 1-2 min for 'kubectl top' to return data)."
