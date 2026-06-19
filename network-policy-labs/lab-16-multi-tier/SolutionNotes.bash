# Solution Notes - Question 16

# Policy 1: Default deny ingress in "db" (must come first conceptually)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-db
  namespace: db
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

# Policy 2: Allow api → db only (AND condition: namespace=api AND tier=api)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-db
  namespace: db
spec:
  podSelector:
    matchLabels:
      tier: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: api
      podSelector:             # AND with namespaceSelector (same list item)
        matchLabels:
          tier: api
    ports:
    - protocol: TCP
      port: 3306
EOF

# Policy 3: Allow web → api (ingress into api namespace from web)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-api
  namespace: api
spec:
  podSelector:
    matchLabels:
      tier: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: web
    ports:
    - protocol: TCP
      port: 8080
EOF

# IMPORTANT NOTE:
# Without a default-deny in "api", pods NOT in the "web" namespace could still
# reach api-server on OTHER ports. If you want full isolation, also apply:
#
#   kubectl apply -n api -f - <<EOF
#   apiVersion: networking.k8s.io/v1
#   kind: NetworkPolicy
#   metadata:
#     name: default-deny-api
#     namespace: api
#   spec:
#     podSelector: {}
#     policyTypes:
#     - Ingress
#   EOF
#
# The exam task only asks for the 3 listed policies, but knowing this is important.

# Verify
kubectl get networkpolicy -n api
kubectl get networkpolicy -n db

# Test web → api (SHOULD work)
WEB_POD=$(kubectl get pod -n web -l tier=web -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n web $WEB_POD -- curl -s --connect-timeout 5 api-service.api.svc.cluster.local:8080

# Test api → db (SHOULD work)
API_POD=$(kubectl get pod -n api -l tier=api -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n api $API_POD -- curl -s --connect-timeout 5 mysql-service.db.svc.cluster.local:3306

# Test web → db (SHOULD be BLOCKED)
kubectl exec -n web $WEB_POD -- curl -s --connect-timeout 5 mysql-service.db.svc.cluster.local:3306
