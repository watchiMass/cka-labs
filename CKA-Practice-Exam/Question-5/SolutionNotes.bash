# Step 0: confirm metrics-server is reporting metrics
kubectl top pods -n hpa-demo
# If this errors with "metrics not available yet", wait ~1 min and retry.

# Step 1: write the HPA manifest with autoscaling/v2 and custom behavior
cat <<EOF | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cpu-stress-hpa
  namespace: hpa-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: cpu-stress
  minReplicas: 1
  maxReplicas: 6
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Pods
        value: 2
        periodSeconds: 30
    scaleDown:
      stabilizationWindowSeconds: 120
      policies:
      - type: Pods
        value: 1
        periodSeconds: 60
EOF

# Step 2: verify the HPA object
kubectl get hpa cpu-stress-hpa -n hpa-demo
kubectl describe hpa cpu-stress-hpa -n hpa-demo

# Step 3: generate load to trigger scale-up
kubectl run -n hpa-demo load-generator --rm -it --restart=Never --image=busybox -- \
  /bin/sh -c "while true; do wget -q -O- http://cpu-stress.hpa-demo.svc.cluster.local; done"

# In a separate terminal, watch the HPA react:
kubectl get hpa cpu-stress-hpa -n hpa-demo -w

# Step 4: stop the load generator (Ctrl+C, or delete the pod) and observe
# scale-down honoring the 120s stabilization window before removing pods.
