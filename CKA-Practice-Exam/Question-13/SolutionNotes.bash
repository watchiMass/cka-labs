# Step 1: create the default-deny-all policy (empty podSelector = all pods)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: secure-zone
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF
# With no `ingress:` field defined at all, this policy denies ALL ingress
# to every pod in secure-zone by default.

# Step 2: create the allow-from-trusted policy as a second, layered policy
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-trusted
  namespace: secure-zone
spec:
  podSelector:
    matchLabels:
      app: secure-app
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          access: allowed
    ports:
    - protocol: TCP
      port: 80
EOF
# NetworkPolicies are additive: a pod's effective ingress rules are the
# UNION of all policies that select it. default-deny-all denies
# everything; allow-from-trusted re-opens just port 80 from
# access=allowed namespaces for pods labeled app=secure-app.

# Step 3: verify from trusted-clients (should succeed)
kubectl exec -n trusted-clients deploy/client -- \
  wget -qO- --timeout=5 http://secure-app.secure-zone.svc.cluster.local

# Step 4: verify from untrusted-clients (should be blocked/time out)
kubectl exec -n untrusted-clients deploy/client -- \
  wget -qO- --timeout=5 http://secure-app.secure-zone.svc.cluster.local || echo "Blocked as expected"

# Step 5: inspect both policies together
kubectl get networkpolicy -n secure-zone
kubectl describe networkpolicy default-deny-all -n secure-zone
kubectl describe networkpolicy allow-from-trusted -n secure-zone
