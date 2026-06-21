# Question 19 (Hard) — Workloads & Scheduling: Resource Allocation v2
# Domain: Workloads & Scheduling (15%)

# Scenario
# The "analytics-worker" Deployment (4 replicas) in namespace
# "alloc-v2-demo" currently has no resource requests/limits and no
# scheduling constraints, so pods land unpredictably. You must constrain
# it to the node pool labeled "pool=highmem" ONLY, and size its resource
# requests/limits to fit evenly within that single node's allocatable
# capacity, while preferring (not strictly requiring) spreading replicas
# across pods using pod anti-affinity.

# Tasks
# 1. Identify the allocatable CPU and memory of the node labeled
#    pool=highmem (kubectl describe node <node> | grep -A5 Allocatable).
# 2. Scale the analytics-worker Deployment down to 0 replicas before
#    editing its resource configuration.
# 3. Edit the Deployment so each pod's container requests/limits are
#    sized to fit exactly 4 pods evenly on the single highmem node, with
#    ~10% headroom subtracted from the even split before setting
#    requests (mirror the approach: divide allocatable by replica count,
#    then trim ~10% off for scheduling headroom on requests; limits can
#    sit at or near the full even-split value).
# 4. Add a nodeSelector (or required node affinity) for pool=highmem so
#    all replicas are constrained to that node only.
# 5. Add a preferredDuringSchedulingIgnoredDuringExecution pod
#    anti-affinity rule (weight 100) on label app=analytics-worker with
#    topologyKey "kubernetes.io/hostname", expressing a soft preference
#    to spread replicas — even though with only one matching node this
#    preference cannot actually change placement, it must still be
#    present in the spec.
# 6. Scale the Deployment back to 4 replicas and confirm all 4 pods are
#    Running and scheduled exclusively on the pool=highmem node.

# Constraints
# - All 4 pods must end up on the SAME (highmem) node — this is expected
#   given there is only one node with that label; do not add a second
#   label to a different node to "fix" this.
# - requests must be strictly less than limits for both cpu and memory.

# Documentation Reference
# Concepts -> Configuration -> Resource Management for Pods and Containers
# https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
# Concepts -> Scheduling, Preemption and Eviction -> Assigning Pods to Nodes
# https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
