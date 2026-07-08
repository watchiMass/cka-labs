# Question 2 | CRD, Helm, cert-manager

Difficulty: Medium

Install cert-manager using Helm in Namespace `cert-manager`. Then configure and create the `ClusterIssuer` CRD:

1. Create Namespace `cert-manager`
2. Install Helm chart `jetstack/cert-manager` (with `crds.enabled=true`) into the new Namespace. The Helm Release should be called `cert-manager`
3. Update the `ClusterIssuer` resource in `/opt/course/2/cluster-issuer.yaml` to include `crlDistributionPoints: ["http://example.com/crl"]` under `spec.selfSigned`
4. Create the `ClusterIssuer` resource from `/opt/course/2/cluster-issuer.yaml`

<details><summary>Need a hint?</summary>

- `kubectl create namespace cert-manager`
- `helm repo add jetstack https://charts.jetstack.io && helm repo update`
- `helm install cert-manager jetstack/cert-manager --namespace cert-manager --set crds.enabled=true`
- Edit the yaml file to add the `crlDistributionPoints` field under `spec.selfSigned`
- `kubectl apply -f /opt/course/2/cluster-issuer.yaml`

</details>
