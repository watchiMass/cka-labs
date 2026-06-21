# Question 10 (Hard) — Workloads & Scheduling: Taints, Tolerations & Affinity
# Domain: Workloads & Scheduling (15%)

# Scenario
# One node in the cluster has been dedicated to GPU workloads: it is
# labeled "hardware=gpu" and tainted "dedicated=gpu-workloads:NoSchedule".
# You must deploy a GPU-aware workload that lands ONLY on that node, while
# ensuring the existing "generic-app" Deployment in "scheduling-demo"
# continues to avoid that node entirely (its current behavior, since it
# has no toleration).

# Tasks
# 1. Identify which node carries the taint "dedicated=gpu-workloads" and
#    the label "hardware=gpu".
# 2. Create a Deployment named "gpu-workload" in namespace
#    "scheduling-demo" with 2 replicas, image "nginx:1.27", that:
#    - tolerates the taint dedicated=gpu-workloads:NoSchedule (operator
#      Equal)
#    - uses requiredDuringSchedulingIgnoredDuringExecution node affinity
#      requiring the label hardware=gpu, so it ONLY ever lands on that
#      node (toleration alone is not exclusivity — affinity enforces it)
# 3. Confirm all "gpu-workload" pods are scheduled exclusively onto the
#    tainted/labeled node.
# 4. Confirm "generic-app" pods remain scheduled on other nodes (none of
#    them should land on the GPU node, since they have no toleration).

# Constraints
# - Do not remove the taint from the node.
# - Do not modify the "generic-app" Deployment.

# Documentation Reference
# Concepts -> Scheduling, Preemption and Eviction -> Taints and Tolerations
# https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
# Concepts -> Scheduling, Preemption and Eviction -> Assigning Pods to Nodes
# https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
