# Question 14 | Check how long certificates are valid

Difficulty: Medium

Perform some tasks on cluster certificates:

1. Check how long the kube-apiserver server certificate is valid using openssl or cfssl. Write the expiration date into `/opt/course/14/expiration`. Run the `kubeadm` command to list the expiration dates and confirm both methods show the same one
2. Write the `kubeadm` command that would renew the kube-apiserver certificate into `/opt/course/14/kubeadm-renew-certs.sh`

<details><summary>Need a hint?</summary>

- `openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate`
- `kubeadm certs check-expiration`
- `kubeadm certs renew apiserver`

</details>
