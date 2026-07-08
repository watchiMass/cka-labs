#!/bin/bash
set -e

mkdir -p /opt/course/1

# Generate a fake multi-context kubeconfig for the exercise
CERT_DATA=$(echo "-----BEGIN CERTIFICATE-----
MIIDCTCCAfGgAwIBAgIUOWKJyMFmYW1234567890abcdefghijklmnopqrstuv
FAKEBASE64CERTDATAFORTRAININGPURPOSESONLYNOTAREALCERTIFICATE
-----END CERTIFICATE-----" | base64 -w0)

cat <<EOF > /opt/course/1/kubeconfig
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CERT_DATA}
    server: https://cluster1.example.com:6443
  name: cluster1
- cluster:
    certificate-authority-data: ${CERT_DATA}
    server: https://cluster2.example.com:6443
  name: cluster2
contexts:
- context:
    cluster: cluster1
    user: account-0027
    namespace: project-x
  name: workload-cluster1
- context:
    cluster: cluster2
    user: account-0034
    namespace: kube-system
  name: infra-cluster2
- context:
    cluster: cluster1
    user: account-0027
  name: default-cluster1
current-context: infra-cluster2
users:
- name: account-0027
  user:
    client-certificate-data: ${CERT_DATA}
    client-key-data: ${CERT_DATA}
- name: account-0034
  user:
    client-certificate-data: ${CERT_DATA}
    client-key-data: ${CERT_DATA}
EOF

echo "Setup complete. Kubeconfig created at /opt/course/1/kubeconfig"
