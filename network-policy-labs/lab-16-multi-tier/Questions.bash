# Question 16: Multi-Tier Network Isolation
# ─────────────────────────────────────────────
# Context:
#   Three-tier application across three namespaces:
#   - Namespace "web" → web-frontend  (label: tier=web)
#   - Namespace "api" → api-server    (label: tier=api), port 8080
#   - Namespace "db"  → mysql         (label: tier=db),  port 3306
#
# Required communication flow:
#   web-frontend → api-server (port 8080)  ✅
#   api-server   → mysql      (port 3306)  ✅
#   web-frontend → mysql      (port 3306)  ❌  (must be blocked)
#   any external → mysql      (any port)   ❌  (must be blocked)

# Task:
# Create the minimum set of NetworkPolicies to enforce the above flow.
# You must create:
#
#   1. A policy in namespace "api" named "allow-web-to-api"
#      → allows ingress from namespace "web" on port 8080 only
#
#   2. A policy in namespace "db" named "allow-api-to-db"
#      → allows ingress ONLY from pods with label tier=api in namespace "api", on port 3306
#
#   3. A default-deny ingress policy in namespace "db" named "default-deny-db"
#      → blocks everything else going into db
#
# Think carefully about:
#   - AND vs OR in from: selectors
#   - Whether you need to protect "api" ingress with a default-deny as well

# Video Link - https://youtu.be/rA8mXYTU0W8
