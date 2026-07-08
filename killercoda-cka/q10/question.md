# Question 10 | RBAC ServiceAccount Role RoleBinding

Difficulty: Low

Create a new ServiceAccount `processor` in Namespace `project-hamster`. Create a Role and RoleBinding, both named `processor` as well. These should allow the new SA to only create Secrets and ConfigMaps in that Namespace.

<details><summary>Need a hint?</summary>

- `kubectl -n project-hamster create serviceaccount processor`
- `kubectl -n project-hamster create role processor --verb=create --resource=secrets,configmaps`
- `kubectl -n project-hamster create rolebinding processor --role=processor --serviceaccount=project-hamster:processor`
- Verify with: `kubectl -n project-hamster auth can-i create secrets --as=system:serviceaccount:project-hamster:processor`

</details>
