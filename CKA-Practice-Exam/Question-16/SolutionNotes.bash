# Step 0: confirm pods are Running but not Ready
kubectl get pods -n nodeport-demo -l app=webapp
# READY column shows 0/1 for all pods despite STATUS=Running

# Step 1: check the Service and Endpoints
kubectl get svc webapp -n nodeport-demo
kubectl get endpoints webapp -n nodeport-demo
# ENDPOINTS column is empty -- no healthy backends, even though pods exist

# Step 2: describe a pod to see the failing readiness probe
POD=$(kubectl get pods -n nodeport-demo -l app=webapp -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod "$POD" -n nodeport-demo
# Look in Events for repeated:
#   "Readiness probe failed: HTTP probe failed with statuscode: 404"

# Step 3: confirm the probe path is wrong
kubectl get deployment webapp -n nodeport-demo -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}'
echo

# Step 4: fix the readiness probe path
kubectl patch deployment webapp -n nodeport-demo --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}]'

# Step 5: roll out and watch pods become Ready
kubectl rollout status deployment webapp -n nodeport-demo
kubectl get pods -n nodeport-demo -l app=webapp -w

# Step 6: confirm endpoints are now populated
kubectl get endpoints webapp -n nodeport-demo

# Step 7: test reachability via NodePort
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s "http://$NODE_IP:30080" | head -5
