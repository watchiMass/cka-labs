# Question 16 (Hard) — Troubleshooting: NodePort Service Unreachable
# Domain: Troubleshooting (30%) / Services & Networking (20%)

# Scenario
# Users report that the "webapp" application, exposed via a NodePort
# Service on port 30080 in namespace "nodeport-demo", is unreachable from
# outside the cluster, even though `kubectl get deployment webapp -n
# nodeport-demo` shows 3/3 replicas and the pods appear to be Running.

# Tasks
# 1. Confirm the Service "webapp" exists with type NodePort and nodePort
#    30080.
# 2. Check `kubectl get endpoints webapp -n nodeport-demo` — note that it
#    shows no addresses, meaning the Service has no healthy backends even
#    though pods are Running.
# 3. Investigate why: describe one of the webapp pods and check its
#    readiness probe status and recent events
#    (`kubectl describe pod <pod> -n nodeport-demo`).
# 4. Identify that the readinessProbe's httpGet path
#    (/this-path-does-not-exist) returns a non-2xx/3xx response from
#    nginx, so the probe always fails and the pod never becomes Ready
#    (Ready 0/1 despite STATUS=Running).
# 5. Fix the Deployment's readinessProbe httpGet path to "/" (a path
#    nginx actually serves), then roll out the change.
# 6. Confirm all 3 pods reach READY 1/1, the Service's Endpoints object
#    now lists 3 pod IPs, and the application is reachable via the
#    NodePort.

# Constraints
# - Do not remove the readinessProbe entirely; fix its path instead
#   (it should remain a meaningful health check).
# - Do not change the Service type or nodePort value.

# Documentation Reference
# Tasks -> Configure Pods and Containers -> Configure Liveness, Readiness
# and Startup Probes
# https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
