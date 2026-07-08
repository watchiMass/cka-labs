#!/bin/bash
set -e

mkdir -p /opt/course/13
kubectl create namespace project-r500 --dry-run=client -o yaml | kubectl apply -f -

# Install Gateway API CRDs (standard channel)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

# Install a lightweight Gateway API implementation: nginx-gateway-fabric (NGF)
# Using the simple deploy manifests for demo purposes
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.5.0/deploy/crds.yaml 2>/dev/null || true
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.5.0/deploy/default/deploy.yaml 2>/dev/null || true

# Backend deployments + services (desktop and mobile)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: desktop-backend
  namespace: project-r500
spec:
  replicas: 1
  selector:
    matchLabels:
      app: desktop-backend
  template:
    metadata:
      labels:
        app: desktop-backend
    spec:
      containers:
      - name: backend
        image: httpd:2-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: desktop-backend
  namespace: project-r500
spec:
  selector:
    app: desktop-backend
  ports:
  - port: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mobile-backend
  namespace: project-r500
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mobile-backend
  template:
    metadata:
      labels:
        app: mobile-backend
    spec:
      containers:
      - name: backend
        image: httpd:2-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: mobile-backend
  namespace: project-r500
spec:
  selector:
    app: mobile-backend
  ports:
  - port: 80
EOF

# GatewayClass + Gateway (using NGF's gatewayclass name "nginx")
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: r500-gateway
  namespace: project-r500
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    hostname: "r500.gateway"
    allowedRoutes:
      namespaces:
        from: Same
EOF

# The old Ingress that needs to be replaced
cat <<EOF > /opt/course/13/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: r500-ingress
  namespace: project-r500
spec:
  rules:
  - host: r500.gateway
    http:
      paths:
      - path: /desktop
        pathType: Prefix
        backend:
          service:
            name: desktop-backend
            port:
              number: 80
      - path: /mobile
        pathType: Prefix
        backend:
          service:
            name: mobile-backend
            port:
              number: 80
EOF

echo "Setup complete. Note: expose the Gateway service as NodePort 30080 manually if your"
echo "distribution doesn't auto-provision a LoadBalancer, e.g.:"
echo "  kubectl -n project-r500 patch svc <gateway-svc-name> -p '{\"spec\":{\"type\":\"NodePort\"}}'"
echo "  kubectl -n project-r500 get svc"
