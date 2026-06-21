# Question 8 (Hard) — Services & Networking: Complex NetworkPolicy
# Domain: Services & Networking (20%)

# Scenario
# Namespace "backend" runs "api-server" pods (label app=api-server) that
# must be locked down with strict traffic rules:
#   - Only pods in "frontend" namespace (label tier=frontend) may send
#     HTTP traffic to api-server on port 80.
#   - Pods in "monitoring" namespace (label tier=monitoring) may scrape
#     api-server on port 9090 (metrics) only — not port 80.
#   - api-server pods must be allowed to make egress DNS lookups
#     (UDP/TCP port 53 to kube-system) and egress HTTPS calls to anywhere
#     (port 443) for external API calls, but no other egress.
#   - All other ingress/egress to api-server must be denied by default.

# Tasks
# 1. Create a NetworkPolicy named "api-server-policy" in namespace
#    "backend" that selects pods with label app=api-server.
# 2. Define two separate ingress rules:
#    - one allowing TCP port 80 from pods in namespaces labeled
#      tier=frontend
#    - one allowing TCP port 9090 from pods in namespaces labeled
#      tier=monitoring
# 3. Define egress rules:
#    - allow UDP and TCP port 53 to any pod in the kube-system namespace
#      (DNS)
#    - allow TCP port 443 to 0.0.0.0/0 (external HTTPS)
# 4. Ensure the policy sets policyTypes to both Ingress and Egress so the
#    default-deny behavior applies to anything not explicitly allowed.
# 5. Verify: a busybox pod in "frontend" can reach
#    http://api-server.backend.svc.cluster.local on port 80; a busybox
#    pod in "monitoring" CANNOT reach port 80 but timing out is expected
#    on port 9090 only if nothing listens there (focus validation on the
#    policy rules, not the missing metrics endpoint).

# Constraints
# - Use networking.k8s.io/v1 NetworkPolicy resources only (no CNI-specific
#   CRDs like Calico NetworkPolicy/GlobalNetworkPolicy).
# - Do not modify the Deployments or Services; only add the NetworkPolicy.

# Documentation Reference
# Concepts -> Services, Load Balancing, and Networking -> Network Policies
# https://kubernetes.io/docs/concepts/services-networking/network-policies/
