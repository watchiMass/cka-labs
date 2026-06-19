# Solution Notes - Question 14

# Step 1: Default deny all ingress in namespace "app"
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: app
spec:
  podSelector: {}        # selects ALL pods in the namespace
  policyTypes:
  - Ingress
  # No ingress rules = deny all ingress
EOF

# Step 2: Allow ingress from prometheus only
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-prometheus
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: webapp
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: monitoring
      podSelector:                 # ← AND condition (same list item)
        matchLabels:
          app: prometheus
    ports:
    - protocol: TCP
      port: 80
EOF

# KEY CONCEPT:
# When namespaceSelector and podSelector are in the SAME list item (same "-"),
# they act as AND: pod must be in "monitoring" AND have label app=prometheus.
# If they were in SEPARATE list items ("-"), it would be OR.

# Step 3: Verify policies
kubectl get networkpolicy -n app

# Step 4: Test connectivity
# Get pod names
kubectl get pods -n monitoring

# Prometheus should SUCCEED (exit 0):
PROMETHEUS_POD=$(kubectl get pod -n monitoring -l app=prometheus -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n monitoring $PROMETHEUS_POD -- curl -s --connect-timeout 5 webapp-service.app.svc.cluster.local:80

# Rogue should FAIL (timeout):
ROGUE_POD=$(kubectl get pod -n monitoring -l app=rogue -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n monitoring $ROGUE_POD -- curl -s --connect-timeout 5 webapp-service.app.svc.cluster.local:80
