# Question 1 | Contexts

Difficulty: Low

You're asked to extract the following information out of kubeconfig file `/opt/course/1/kubeconfig`:

1. Write all kubeconfig context names into `/opt/course/1/contexts`, one per line
2. Write the name of the current context into `/opt/course/1/current-context`
3. Write the client-certificate of user `account-0027` base64-decoded into `/opt/course/1/cert`

<details><summary>Need a hint?</summary>

- `kubectl config get-contexts --kubeconfig=/opt/course/1/kubeconfig`
- `kubectl config current-context --kubeconfig=/opt/course/1/kubeconfig`
- `kubectl config view --kubeconfig=/opt/course/1/kubeconfig -o jsonpath='{.users[?(@.name=="account-0027")].user.client-certificate-data}' | base64 -d`

</details>
