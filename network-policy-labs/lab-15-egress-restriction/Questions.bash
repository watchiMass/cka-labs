# Question 15: Egress Restriction
# ─────────────────────────────────────────────
# Context:
#   - Namespace "payments" → contains "payment-service" (label: app=payment-service)
#   - Namespace "database" → contains "postgres" (label: app=postgres, tier=db), port 5432
#   - Namespace "external" → contains "external-api" ← access must be BLOCKED

# Task:
# Create a NetworkPolicy named "restrict-egress-payments" in the "payments" namespace
# that:
#   1. Applies to pods with label app=payment-service
#   2. Allows egress ONLY to pods with label tier=db in the "database" namespace, on port 5432
#   3. Also allows egress to kube-dns on UDP port 53 (so DNS still resolves)
#   4. Blocks ALL other egress (including to namespace "external")
#
# Expected result:
#   - payment-service → postgres (database:5432)          ✅ allowed
#   - payment-service → external-api (external:80)        ❌ blocked
#   - payment-service → kube-dns (kube-system:53/UDP)     ✅ allowed (DNS)

# Video Link - https://youtu.be/rA8mXYTU0W8
