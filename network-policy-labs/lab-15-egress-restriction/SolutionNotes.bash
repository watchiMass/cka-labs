# Solution Notes - Question 15

# The key here: specifying Egress in policyTypes WITHOUT egress rules = deny all egress.
# So we list policyTypes: [Egress] and add only the rules we want.

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-egress-payments
  namespace: payments
spec:
  podSelector:
    matchLabels:
      app: payment-service
  policyTypes:
  - Egress
  egress:
  # Rule 1: allow DNS (required for any hostname resolution)
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53

  # Rule 2: allow access to postgres only
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: database
      podSelector:                   # AND: namespace=database AND tier=db
        matchLabels:
          tier: db
    ports:
    - protocol: TCP
      port: 5432
EOF

# Verify the policy
kubectl get networkpolicy restrict-egress-payments -n payments -o yaml

# Test: should SUCCEED (DNS + postgres reachable via service name)
PAYMENT_POD=$(kubectl get pod -n payments -l app=payment-service -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n payments $PAYMENT_POD -- curl -s --connect-timeout 5 postgres-service.database.svc.cluster.local:5432

# Test: should FAIL (external blocked)
kubectl exec -n payments $PAYMENT_POD -- curl -s --connect-timeout 5 external-api-service.external.svc.cluster.local:80
