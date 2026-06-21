#!/bin/bash
# setup-ha-controlplane.sh
# Question 2 - kubeadm: Join a Second Control-Plane Node
set -uo pipefail

echo "Setting up Question 2: HA Control Plane Join..."

# This lab assumes a multi-node environment where node "cp-node-2" exists
# but has NOT yet joined the cluster as a control-plane node. We pre-generate
# the certificate key and print the join command components the candidate
# will need to assemble and execute on cp-node-2.

echo "Generating a fresh certificate-key for control-plane join..."
CERT_KEY=$(kubeadm certs certificate-key)
echo "CERT_KEY=$CERT_KEY"

echo "Uploading certificates so a new control-plane node can join..."
kubeadm init phase upload-certs --upload-certs --certificate-key "$CERT_KEY"

echo "Generating a fresh join token..."
JOIN_CMD=$(kubeadm token create --print-join-command)
echo "Base join command: $JOIN_CMD"

cat <<EOF

[OK] Question 2 lab environment ready.

The candidate must SSH to cp-node-2 and run a control-plane join command of
the form:

  $JOIN_CMD \\
    --control-plane \\
    --certificate-key $CERT_KEY

(token and cert-key above are valid for a limited time window; if they
expire, regenerate with 'kubeadm token create --print-join-command' and
'kubeadm init phase upload-certs --upload-certs').
EOF
