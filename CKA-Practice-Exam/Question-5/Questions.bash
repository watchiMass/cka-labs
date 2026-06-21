# Question 5 (Hard) — Workloads & Scheduling: HorizontalPodAutoscaler
# Domain: Workloads & Scheduling (15%)

# Scenario
# The "cpu-stress" Deployment in namespace "hpa-demo" needs to automatically
# scale based on CPU utilization, but with controlled scale-up/scale-down
# behavior to avoid thrashing during traffic spikes.

# Tasks
# 1. Create a HorizontalPodAutoscaler named "cpu-stress-hpa" in the
#    "hpa-demo" namespace targeting the "cpu-stress" Deployment.
# 2. Configure it to maintain an average CPU utilization target of 50%.
# 3. Set minReplicas to 1 and maxReplicas to 6.
# 4. Configure scaling behavior so that:
#    - Scale-up can add at most 2 pods every 30 seconds (no stabilization
#      delay needed for scale-up; react quickly to load).
#    - Scale-down has a stabilization window of 120 seconds, removing at
#      most 1 pod every 60 seconds (to avoid flapping).
# 5. Apply load to the Service (e.g. with a busybox loop hitting the
#    cpu-stress Service) and observe the HPA scale the Deployment up.
# 6. Confirm `kubectl get hpa -n hpa-demo` shows TARGETS reporting a
#    real CPU percentage (not <unknown>), meaning metrics-server is
#    correctly wired up.

# Constraints
# - Use the autoscaling/v2 API version.
# - Do not set maxReplicas higher than 6; the node lacks capacity beyond
#   that in this lab.

# Documentation Reference
# Tasks -> Run Applications -> Horizontal Pod Autoscaling
# https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
