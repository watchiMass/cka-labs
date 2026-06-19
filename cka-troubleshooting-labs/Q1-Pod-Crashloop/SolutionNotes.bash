# Solution Notes — Question 1: Pod CrashLoopBackOff / ImagePullBackOff
#
# ─── TASK 1: api-server-pod not Ready ────────────────────────────────────────
#
# Diagnosis:
kubectl describe pod api-server-pod -n q1-crashloop
# The readiness/liveness probes check GET /healthz on port 80
# but nginx does not serve /healthz by default → probes fail → pod never Ready
# Additionally: command runs "nginx -g 'daemon on;'" which puts nginx in background,
# then "sleep 3600" keeps the container alive but nginx may not be correctly started.

# Fix option A — patch the probes to use a valid nginx path:
kubectl patch pod api-server-pod -n q1-crashloop --type='json' -p='[
  {"op":"replace","path":"/spec/containers/0/readinessProbe/httpGet/path","value":"/"},
  {"op":"replace","path":"/spec/containers/0/livenessProbe/httpGet/path","value":"/"}
]'
# Note: pods are largely immutable; for probe changes you may need to delete and recreate:
kubectl delete pod api-server-pod -n q1-crashloop
kubectl apply -n q1-crashloop -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: api-server-pod
  namespace: q1-crashloop
  labels:
    app: api-server
spec:
  containers:
  - name: api
    image: nginx:1.25
    ports:
    - containerPort: 80
    env:
    - name: APP_MODE
      value: "production"
    - name: CONFIG_PATH
      value: "/etc/config/app.conf"
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 2
      periodSeconds: 3
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
EOF

# Verify:
kubectl get pod api-server-pod -n q1-crashloop
# Expected: 1/1 Running

# ─── TASK 2: worker-deployment — ImagePullBackOff ────────────────────────────
#
# Diagnosis:
kubectl get pods -n q1-crashloop
# pods show ErrImagePull or ImagePullBackOff
kubectl describe pod -l app=worker -n q1-crashloop | grep -A5 Events
# image "busybox:9.9.9" does not exist on Docker Hub

# Fix — update the image to a valid tag:
kubectl set image deployment/worker-deployment worker=busybox:1.36 -n q1-crashloop

# Verify:
kubectl rollout status deployment/worker-deployment -n q1-crashloop
kubectl get pods -n q1-crashloop -l app=worker
# Expected: 2/2 Running
