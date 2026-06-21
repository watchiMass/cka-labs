# Question 17 (Hard) — Troubleshooting: TLS Certificate / Hostname Mismatch
# Domain: Troubleshooting (30%) / Services & Networking (20%)

# Scenario
# Clients connecting to https://api.example.com (routed through the
# "api-ingress" Ingress in namespace "tls-demo") receive TLS certificate
# warnings about a hostname mismatch, even though the Ingress and Service
# both appear correctly configured.

# Tasks
# 1. Inspect the Ingress "api-ingress" in "tls-demo" and confirm the TLS
#    block's host (api.example.com) and the referenced secretName
#    (api-tls-secret).
# 2. Extract and inspect the certificate inside Secret "api-tls-secret"
#    using openssl (decode the base64 tls.crt and run
#    `openssl x509 -noout -text`) to find its actual Common
#    Name/Subject Alternative Name.
# 3. Confirm the certificate was issued for "wrong-host.example.com",
#    not "api.example.com" — this mismatch is the root cause of the
#    TLS warning.
# 4. Generate a NEW self-signed certificate with CN and SAN set correctly
#    to "api.example.com".
# 5. Replace the data in Secret "api-tls-secret" (in place, same secret
#    name, same namespace) with the new certificate and key so the
#    Ingress reference does not need to change.
# 6. Confirm the new certificate inside the secret now has a Subject/SAN
#    matching api.example.com.

# Constraints
# - Do not change the Ingress's tls.secretName or host fields; fix the
#   certificate content inside the existing Secret instead.
# - The replacement certificate may be self-signed (no real CA available
#   in this lab).

# Documentation Reference
# Concepts -> Services, Load Balancing, and Networking -> Ingress -> TLS
# https://kubernetes.io/docs/concepts/services-networking/ingress/#tls
