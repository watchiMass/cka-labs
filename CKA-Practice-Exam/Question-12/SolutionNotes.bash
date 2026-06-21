# Step 0: confirm the TLS secret and backend Services exist
kubectl get secret shop-tls-secret -n ingress-demo
kubectl get svc -n ingress-demo

# Step 1: create the Ingress with TLS and two path-based rules
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shop-ingress
  namespace: ingress-demo
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - shop.example.com
    secretName: shop-tls-secret
  rules:
  - host: shop.example.com
    http:
      paths:
      - path: /shop
        pathType: Prefix
        backend:
          service:
            name: shop-app
            port:
              number: 80
      - path: /blog
        pathType: Prefix
        backend:
          service:
            name: blog-app
            port:
              number: 80
EOF

# Step 2: verify
kubectl describe ingress shop-ingress -n ingress-demo
kubectl get ingress shop-ingress -n ingress-demo -o yaml

# Step 3: find the ingress controller's external address
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Step 4: test routing with curl (replace INGRESS_IP with the actual address)
INGRESS_IP="REPLACE_WITH_INGRESS_IP"
curl -k --resolve shop.example.com:443:"$INGRESS_IP" https://shop.example.com/shop
curl -k --resolve shop.example.com:443:"$INGRESS_IP" https://shop.example.com/blog

# Notes:
# - rewrite-target: / strips the matched prefix ("/shop" or "/blog") before
#   forwarding to the backend, so nginx's default page is served at "/".
# - The self-signed cert requires -k (insecure) for curl since it isn't
#   trusted by a CA, and --resolve is needed since shop.example.com has
#   no real DNS entry in this lab.
