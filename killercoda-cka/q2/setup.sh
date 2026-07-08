#!/bin/bash
set -e

mkdir -p /opt/course/2

cat <<'EOF' > /opt/course/2/cluster-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  selfSigned: {}
EOF

# Make sure helm is available
if ! command -v helm &> /dev/null; then
  echo "Installing helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Add jetstack repo if not present
helm repo add jetstack https://charts.jetstack.io 2>/dev/null || true
helm repo update

echo "Setup complete. cluster-issuer.yaml created at /opt/course/2/cluster-issuer.yaml"
