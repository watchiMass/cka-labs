# Solution Notes — Question 2: Service Unreachable
#
# ─── DIAGNOSIS ───────────────────────────────────────────────────────────────

# Step 1: Check endpoints — are there any?
kubectl get endpoints web-service -n q2-service
# Expected output: web-service   <none>   ...
# → No endpoints = service selector doesn't match any pod

# Step 2: Compare service selector vs pod labels
kubectl describe svc web-service -n q2-service | grep Selector
# Selector: app=web-app,tier=backend   ← problem #1: should be tier=frontend

kubectl get pods -n q2-service --show-labels
# Pods have labels: app=web-app,tier=frontend

# Step 3: Check targetPort
kubectl get svc web-service -n q2-service -o yaml | grep targetPort
# targetPort: 8080   ← problem #2: nginx listens on 80, not 8080

# ─── FIX ─────────────────────────────────────────────────────────────────────

# Fix both issues by patching the service:
kubectl patch svc web-service -n q2-service --type='json' -p='[
  {"op":"replace","path":"/spec/selector/tier","value":"frontend"},
  {"op":"replace","path":"/spec/ports/0/targetPort","value":80}
]'

# Or edit directly:
# kubectl edit svc web-service -n q2-service
#   → change tier: backend → tier: frontend
#   → change targetPort: 8080 → targetPort: 80

# ─── VERIFY ──────────────────────────────────────────────────────────────────

# Endpoints should now be populated:
kubectl get endpoints web-service -n q2-service
# Expected: web-service   10.x.x.x:80,10.x.x.x:80   ...

# Test connectivity from debug pod:
kubectl exec -n q2-service debug-pod -- curl -s http://web-service
# Expected: nginx HTML welcome page
