# Question 14: Default Deny + Selective Allow
# ─────────────────────────────────────────────
# Context:
#   - Namespace "app"       → contains a Deployment "webapp" (label: app=webapp, tier=frontend)
#   - Namespace "monitoring" → contains two pods:
#       • "prometheus" (label: app=prometheus)   ← legitimate scraper
#       • "rogue"      (label: app=rogue)         ← unauthorized pod

# Task:
# 1. Create a NetworkPolicy named "default-deny-ingress" in the "app" namespace
#    that blocks ALL ingress traffic to every pod in that namespace.
#
# 2. Create a second NetworkPolicy named "allow-prometheus" in the "app" namespace
#    that allows ingress on port 80 ONLY from pods with label app=prometheus
#    in the "monitoring" namespace.
#
# Expected result after applying both policies:
#   - prometheus (monitoring) → webapp (app:80)   ✅ allowed
#   - rogue      (monitoring) → webapp (app:80)   ❌ blocked

# Video Link - https://youtu.be/rA8mXYTU0W8 (Network Policy fundamentals)
