# Question 2 — Service Unreachable Troubleshooting
#
# Context:
#   A web application is deployed in namespace 'q2-service'.
#   The application pods are Running, but the service 'web-service'
#   is not routing any traffic to them.
#   A debug pod is available to test connectivity.
#
# Task:
#   1. Investigate why 'web-service' has no endpoints
#   2. Fix ALL issues with the service so that traffic reaches the web-app pods
#   3. Confirm that the following command succeeds and returns an nginx response:
#
#      kubectl exec -n q2-service debug-pod -- curl -s http://web-service
#
# Expected result: nginx default HTML page (200 OK)
#
# Investigation commands:
#   kubectl get svc web-service -n q2-service
#   kubectl get endpoints web-service -n q2-service
#   kubectl describe svc web-service -n q2-service
#   kubectl get pods -n q2-service --show-labels
#
# Hint: There are TWO distinct issues to fix.
