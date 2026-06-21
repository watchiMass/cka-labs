#!/bin/bash
# setup-nodeport-readiness.sh
# Question 16 - Troubleshooting: NodePort Service Unreachable Due to Bad Readiness Probe
set -uo pipefail

echo "Setting up Question 16: NodePort & Readiness Probe..."

kubectl create namespace nodeport-demo --dry-run=client -o yaml | kubectl apply -f -

# Deploy an app with an intentionally broken readiness probe (wrong path),
# so the pods never become Ready and the Service has no healthy endpoints,
# making the NodePort effectively unreachable even though everything
# "looks" deployed.
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: nodeport-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx:1.27
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /this-path-does-not-exist
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: webapp
  namespace: nodeport-demo
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF

echo "[OK] Question 16 lab environment ready"
echo "Service 'webapp' is exposed as NodePort 30080 but pods are NOT Ready."
