# Step 1: write the NetworkPolicy with multiple ingress and egress rules
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-server-policy
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: api-server
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 80
  - from:
    - namespaceSelector:
        matchLabels:
          tier: monitoring
    ports:
    - protocol: TCP
      port: 9090
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 443
EOF

# Step 2: verify the policy object
kubectl get networkpolicy api-server-policy -n backend -o yaml

# Step 3: test from frontend (should succeed on port 80)
kubectl exec -n frontend deploy/web-client -- \
  wget -qO- --timeout=5 http://api-server.backend.svc.cluster.local:80

# Step 4: test from monitoring on port 80 (should TIME OUT / be blocked)
kubectl exec -n monitoring deploy/metrics-scraper -- \
  wget -qO- --timeout=5 http://api-server.backend.svc.cluster.local:80 || echo "Blocked as expected"

# Step 5: test from a namespace with NO matching label (e.g. default) — should be blocked
kubectl run test-client --rm -it --restart=Never --image=busybox -n default -- \
  wget -qO- --timeout=5 http://api-server.backend.svc.cluster.local:80 || echo "Blocked as expected"

# Note: kube-system namespace must carry the label
#   kubernetes.io/metadata.name: kube-system
# which is automatically added by Kubernetes >= 1.21 to every namespace,
# so no manual labeling step is required for the egress DNS rule.
