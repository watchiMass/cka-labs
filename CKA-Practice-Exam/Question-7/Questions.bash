# Question 7 (Hard) — Workloads & Scheduling: PriorityClass & Preemption
# Domain: Workloads & Scheduling (15%)

# Scenario
# The cluster is saturated with low-priority "filler" pods in namespace
# "priority-demo". A critical workload now needs to be scheduled and should
# be allowed to preempt lower-priority pods if the cluster lacks capacity.

# Tasks
# 1. Create a PriorityClass named "low-priority" with value 100 and
#    globalDefault set to false.
# 2. Create a PriorityClass named "high-priority-critical" with value
#    1000000, globalDefault false, and a preemptionPolicy of
#    "PreemptLowerPriority".
# 3. Patch the existing "filler" Deployment in "priority-demo" so its pod
#    template uses priorityClassName "low-priority", then roll the
#    Deployment to apply it.
# 4. Create a Pod named "critical-task" in "priority-demo" using image
#    "nginx:1.27", requesting "1500m" CPU, with priorityClassName set to
#    "high-priority-critical".
# 5. Confirm that "critical-task" becomes Running, and that Kubernetes
#    preempted (evicted) one or more "filler" pods to make room for it
#    (check `kubectl get events -n priority-demo` for Preempted events).

# Constraints
# - Do not manually delete filler pods yourself; the scheduler must
#   perform the preemption based on priority.
# - Do not increase cluster node count or resources to work around the
#   capacity constraint.

# Documentation Reference
# Concepts -> Scheduling, Preemption and Eviction -> Pod Priority and Preemption
# https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/
