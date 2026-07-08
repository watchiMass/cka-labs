#!/bin/bash
# NOTE: This exercise requires a Killercoda scenario with at least 2 VMs
# (a control-plane node already part of the cluster, and a second node
# "node01" that is NOT yet joined and has an older kubeadm/kubelet/kubectl
# version installed). This setup script assumes such a scenario layout
# and should be run on the CONTROL PLANE host.
#
# On genuine Killercoda "CKA" playgrounds this matches the ks1/ks2 or
# controlplane/node01 multi-machine setup. Adjust hostnames as needed.
set -e

echo "This exercise assumes a 2-node scenario:"
echo "  - controlplane (already initialized, this is where you run kubectl)"
echo "  - node01 (NOT joined yet, has an OLDER kubeadm/kubelet installed)"
echo ""
echo "If node01 is not preconfigured with an older k8s version by your"
echo "Killercoda scenario base image, simulate it by downgrading kubelet/kubeadm"
echo "there manually, e.g.:"
echo "  ssh node01"
echo "  apt-get install -y --allow-downgrades kubelet=<older-version> kubeadm=<older-version>"
echo ""
echo "Setup acknowledgement complete. Proceed with the question on the controlplane node."
