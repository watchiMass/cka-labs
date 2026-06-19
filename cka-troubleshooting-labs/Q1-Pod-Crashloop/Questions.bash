# Question 1 — Pod CrashLoopBackOff / ImagePullBackOff Troubleshooting
#
# Context:
#   A development team has deployed two workloads in the namespace 'q1-crashloop'.
#   Neither is working correctly. Your job is to identify and fix both issues.
#
# Task 1:
#   The pod 'api-server-pod' is deployed but is not reaching a Ready state.
#   - Investigate why the pod's probes are failing
#   - Fix the pod in-place (edit it) so that it becomes Ready
#   - The container must remain nginx-based and keep listening on port 80
#
# Task 2:
#   The deployment 'worker-deployment' has 0 pods running.
#   - Identify the root cause
#   - Fix the deployment so that exactly 2 replicas are Running
#   - Use image busybox:1.36 as the corrected image
#
# Hints (only if stuck):
#   kubectl get pods -n q1-crashloop
#   kubectl describe pod api-server-pod -n q1-crashloop
#   kubectl logs api-server-pod -n q1-crashloop
#   kubectl get events -n q1-crashloop --sort-by='.lastTimestamp'
#
# Video reference: https://youtu.be/rA8mXYTU0W8 (concept walkthrough)
