# Step 0: confirm the cert-manager CRDs are installed
kubectl get crds | grep cert-manager.io

# Step 1: create the self-signed ClusterIssuer
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF

kubectl get clusterissuer selfsigned-issuer -o wide

# Step 2: create the Certificate resource
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: internal-tls
  namespace: cert-demo
spec:
  secretName: internal-tls-secret
  duration: 2160h
  renewBefore: 360h
  commonName: internal.cert-demo.svc.cluster.local
  dnsNames:
  - internal.cert-demo.svc.cluster.local
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
EOF

# Step 3: watch for the certificate to become Ready
kubectl get certificate internal-tls -n cert-demo -w
# Ctrl+C once READY shows True

kubectl describe certificate internal-tls -n cert-demo

# Step 4: confirm the resulting Secret
kubectl get secret internal-tls-secret -n cert-demo
kubectl get secret internal-tls-secret -n cert-demo -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -text | head -20
