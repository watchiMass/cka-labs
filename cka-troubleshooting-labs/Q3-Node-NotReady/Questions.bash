# Question 3 — Node Scheduling Troubleshooting
#
# Context:
#   A worker node in your cluster has been placed under maintenance.
#   Two workloads in the namespace 'q3-scheduling' are affected:
#   - 'critical-app' deployment: pods stuck in Pending state
#   - 'gpu-workload' pod: also stuck in Pending
#
# Task 1 — critical-app (3 replicas):
#   The node was placed under maintenance using standard Kubernetes mechanisms.
#   Identify which node is affected, what was done to it, and restore it
#   to a schedulable state so that all 3 critical-app replicas become Running.
#
# Task 2 — gpu-workload pod:
#   This pod cannot be scheduled for a different reason unrelated to the node.
#   Identify the issue in the pod spec and fix it so the pod becomes Running.
#   CONSTRAINT: Do NOT modify any node labels. Fix the pod only.
#
# Investigation commands:
#   kubectl get pods -n q3-scheduling -o wide
#   kubectl describe pod <pod-name> -n q3-scheduling
#   kubectl get nodes
#   kubectl describe node <node-name>
#
# Key areas to check:
#   - Node conditions (Ready, SchedulingDisabled)
#   - Node taints
#   - Pod events (especially the "reason" field)
