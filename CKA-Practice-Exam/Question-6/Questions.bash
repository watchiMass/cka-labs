# Question 6 (Hard) — CRDs: cert-manager Issuer and Certificate
# Domain: Services & Networking (20%) / Cluster Architecture (CRDs)

# Scenario
# cert-manager has been installed in your cluster via CRDs. You must
# configure a self-signed certificate authority and issue a TLS certificate
# for an internal service, then verify the resulting Kubernetes Secret.

# Tasks
# 1. In namespace "cert-demo", create a self-signed ClusterIssuer named
#    "selfsigned-issuer".
# 2. Create a Certificate resource named "internal-tls" in "cert-demo"
#    that:
#    - references "selfsigned-issuer" as its issuerRef (kind: ClusterIssuer)
#    - sets secretName to "internal-tls-secret"
#    - sets commonName to "internal.cert-demo.svc.cluster.local"
#    - includes a dnsNames entry for "internal.cert-demo.svc.cluster.local"
#    - sets a duration of 2160h (90 days) and renewBefore of 360h (15 days)
# 3. Wait for cert-manager to issue the certificate and confirm the
#    Certificate resource shows Ready=True.
# 4. Confirm the Secret "internal-tls-secret" exists in "cert-demo" and
#    contains both tls.crt and tls.key data keys.

# Constraints
# - Use apiVersion cert-manager.io/v1 for all cert-manager custom resources.
# - Do not use a CA issuer that depends on an external ACME server (no
#   internet-dependent Let's Encrypt staging in this lab); self-signed only.

# Documentation Reference
# Concepts -> Extending Kubernetes -> Custom Resources
# https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/
# (cert-manager docs: https://cert-manager.io/docs/configuration/selfsigned/)
