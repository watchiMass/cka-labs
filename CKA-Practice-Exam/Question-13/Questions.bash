# Question 13 (Hard) — Services & Networking: Default-Deny + Namespace Selector
# Domain: Services & Networking (20%)

# Scenario
# Namespace "secure-zone" hosts the "secure-app" Deployment. Security
# policy requires that, by default, NOTHING can reach pods in
# "secure-zone" — and the only exception is pods originating from
# namespaces explicitly labeled "access=allowed".

# Tasks
# 1. Create a NetworkPolicy named "default-deny-all" in namespace
#    "secure-zone" that selects all pods (empty podSelector) and sets
#    policyTypes to Ingress only, with no ingress rules defined (this
#    establishes default-deny for all ingress traffic in the namespace).
# 2. Create a second NetworkPolicy named "allow-from-trusted" in namespace
#    "secure-zone" that:
#    - selects pods with label app=secure-app
#    - allows ingress from any pod in any namespace labeled
#      access=allowed
#    - restricts allowed traffic to TCP port 80
# 3. Confirm a busybox client in namespace "trusted-clients" (labeled
#    access=allowed) CAN reach secure-app.secure-zone.svc.cluster.local
#    on port 80.
# 4. Confirm a busybox client in namespace "untrusted-clients" (labeled
#    access=denied) CANNOT reach the same Service.

# Constraints
# - Both NetworkPolicy objects must remain in place together; do not
#   merge them into a single policy (the exam scenario specifically
#   tests layering a namespace-wide default-deny with a more specific
#   allow rule).
# - Use networking.k8s.io/v1 only.

# Documentation Reference
# Concepts -> Services, Load Balancing, and Networking -> Network Policies
# https://kubernetes.io/docs/concepts/services-networking/network-policies/#default-deny-all-ingress-traffic
