# Step 0: inspect the Ingress TLS config
kubectl get ingress api-ingress -n tls-demo -o yaml

# Step 1: extract and inspect the current certificate's CN/SAN
kubectl get secret api-tls-secret -n tls-demo -o jsonpath='{.data.tls\.crt}' | \
  base64 -d | openssl x509 -noout -subject -ext subjectAltName
# Output will show:
#   subject=CN = wrong-host.example.com, O = wrong-host.example.com
#   X509v3 Subject Alternative Name:
#       DNS:wrong-host.example.com
# This confirms the mismatch: the cert is for the wrong hostname.

# Step 2: generate a correct certificate for api.example.com
TMPDIR=$(mktemp -d)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$TMPDIR/tls.key" -out "$TMPDIR/tls.crt" \
  -subj "/CN=api.example.com/O=api.example.com" \
  -addext "subjectAltName=DNS:api.example.com"

# Step 3: replace the existing secret's contents in place
kubectl create secret tls api-tls-secret \
  --cert="$TMPDIR/tls.crt" --key="$TMPDIR/tls.key" \
  -n tls-demo --dry-run=client -o yaml | kubectl apply -f -

rm -rf "$TMPDIR"

# Step 4: verify the fix
kubectl get secret api-tls-secret -n tls-demo -o jsonpath='{.data.tls\.crt}' | \
  base64 -d | openssl x509 -noout -subject -ext subjectAltName
# Should now show CN = api.example.com and DNS:api.example.com

# Step 5: test the live endpoint (ingress controller will pick up the new
# cert automatically since it watches Secret changes)
NGINX_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -kv --resolve api.example.com:443:"$NGINX_IP" https://api.example.com 2>&1 | grep -i "subject:"
