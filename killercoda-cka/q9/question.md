# Question 9 | Contact K8s Api from inside Pod

Difficulty: Medium

There is ServiceAccount `secret-reader` in Namespace `project-swan`. Create a Pod of image `nginx:1-alpine` named `api-contact` which uses this ServiceAccount.

Exec into the Pod and use `curl` to manually query all Secrets from the Kubernetes Api.

Write the result into file `/opt/course/9/result.json`.

<details><summary>Need a hint?</summary>

Inside the Pod:
```
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/$NAMESPACE/secrets
```

Copy the output back out with `kubectl cp` or paste it into the file on the host.

</details>
