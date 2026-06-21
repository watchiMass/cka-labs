# Step 0: confirm Gateway API CRDs and a GatewayClass exist
kubectl get crds | grep gateway.networking.k8s.io
kubectl get gatewayclass

# Step 1: create the Gateway
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: demo-gateway
  namespace: gw-demo
spec:
  gatewayClassName: demo-gateway-class
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
EOF

# Step 2: create the HTTPRoute
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: store-route
  namespace: gw-demo
spec:
  parentRefs:
  - name: demo-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /store
    backendRefs:
    - name: store-backend
      port: 80
EOF

# Step 3: check Gateway status conditions
kubectl get gateway demo-gateway -n gw-demo -o yaml
kubectl get gateway demo-gateway -n gw-demo \
  -o jsonpath='{.status.conditions[?(@.type=="Programmed")].status}'

# Step 4: check HTTPRoute status conditions
kubectl get httproute store-route -n gw-demo -o yaml
kubectl get httproute store-route -n gw-demo \
  -o jsonpath='{.status.parents[0].conditions[?(@.type=="ResolvedRefs")].status}'

# Step 5 (if a controller is reconciling and assigns an external address):
kubectl get gateway demo-gateway -n gw-demo -o jsonpath='{.status.addresses}'
