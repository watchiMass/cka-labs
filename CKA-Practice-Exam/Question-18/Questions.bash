# Question 18 (Hard) — Troubleshooting: kubectl patch — Resource Limit Hot-Fix
# Domain: Troubleshooting (30%) / Workloads & Scheduling (15%)

# Scenario
# The "report-generator" Deployment in namespace "patch-demo" is
# repeatedly crash-looping. `kubectl get pods -n patch-demo` shows pods
# cycling through CrashLoopBackOff / OOMKilled states.

# Tasks
# 1. Confirm the root cause: describe one of the report-generator pods
#    and check the "Last State" section for "Reason: OOMKilled".
# 2. Without editing a YAML file by hand, use `kubectl patch` with a
#    strategic merge patch (or JSON patch) to update the
#    report-generator Deployment's container resources so that:
#    - requests.memory is "150Mi"
#    - limits.memory is "300Mi"
#    - requests.cpu and limits.cpu remain unchanged
# 3. Confirm the patch triggers a new rollout (Deployments automatically
#    roll pods when the pod template changes).
# 4. Confirm all report-generator pods reach STATUS=Running and stay
#    Running (no further restarts) for at least 60 seconds.
# 5. Confirm via `kubectl get deployment report-generator -n patch-demo
#    -o jsonpath=...` that the new memory limit (300Mi) is reflected in
#    the live object, proving the patch was applied via the API
#    (not just locally).

# Constraints
# - You must use `kubectl patch` (not `kubectl edit` or a re-applied
#   YAML file) to make this change — this question specifically tests
#   the patch workflow.
# - Do not change the container image or command/args.

# Documentation Reference
# Reference -> kubectl -> Update Field(s) of a Resource (patch)
# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#patch
