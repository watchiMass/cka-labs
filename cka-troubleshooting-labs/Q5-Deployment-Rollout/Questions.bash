# Question 5 — Deployment Rollout & RBAC Troubleshooting
#
# Context:
#   Three deployments in namespace 'q5-rollout' have issues.
#
# Task 1 — memory-hog (OOMKilled):
#   Pods in the 'memory-hog' deployment are being killed due to insufficient memory.
#   Fix the deployment resource limits so that pods remain in Running state.
#   Constraint: memory limit must be at least 32Mi. CPU can stay unchanged.
#
# Task 2 — rolling-app (stuck rollout):
#   A rolling update was triggered on 'rolling-app' but is completely stuck.
#   There are TWO issues: one with the rollout strategy and one with the new image.
#   Goal: get all 3 replicas back to Running with the original nginx:1.25 image.
#   Hint: a rollback is acceptable and recommended.
#
# Task 3 — rbac-app (Forbidden):
#   The 'rbac-app' pod uses ServiceAccount 'pod-reader-sa'.
#   Its container tries to run 'kubectl get pods -n q5-rollout' every 10 seconds
#   but gets a Forbidden error.
#   Create the necessary Role and RoleBinding so pod-reader-sa can:
#     - list and get pods in namespace q5-rollout
#
# Investigation commands:
#   kubectl get pods -n q5-rollout
#   kubectl describe pod <pod> -n q5-rollout    # check OOMKilled, Events
#   kubectl rollout status deployment/rolling-app -n q5-rollout
#   kubectl rollout history deployment/rolling-app -n q5-rollout
#   kubectl logs -l app=rbac-app -n q5-rollout
