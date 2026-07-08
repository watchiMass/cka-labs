#!/bin/bash
set -e

mkdir -p /opt/course/9
kubectl create namespace project-swan --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-swan create serviceaccount secret-reader --dry-run=client -o yaml | kubectl apply -f -

# Create a few secrets so the query returns something meaningful
kubectl -n project-swan create secret generic swan-secret-1 --from-literal=key=value1 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-swan create secret generic swan-secret-2 --from-literal=key=value2 --dry-run=client -o yaml | kubectl apply -f -

# Grant the service account permission to list secrets in its namespace,
# so the exercise (querying the API) is actually achievable
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader-role
  namespace: project-swan
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: secret-reader-binding
  namespace: project-swan
subjects:
- kind: ServiceAccount
  name: secret-reader
  namespace: project-swan
roleRef:
  kind: Role
  name: secret-reader-role
  apiGroup: rbac.authorization.k8s.io
EOF

echo "Setup complete."
