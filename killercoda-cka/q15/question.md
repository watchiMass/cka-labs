# Question 15 | NetworkPolicy

Difficulty: Hard

There was a security incident where an intruder was able to access the whole cluster from a single hacked backend Pod.

To prevent this create a NetworkPolicy called `np-backend` in Namespace `project-snake`. It should allow the `backend-*` Pods only to:

- Connect to `db1-*` Pods on port `1111`
- Connect to `db2-*` Pods on port `2222`

Use the `app` Pod labels in your policy.

<details><summary>Need a hint?</summary>

- `podSelector` on the policy should match `app: backend-1` (or however your backend pods are labelled with prefix backend)
- Use two entries in `egress` with `to.podSelector.matchLabels.app` for `db1-main` and `db2-main` respectively, each with its own `ports`
- Don't forget `policyTypes: [Egress]` — without it the egress rules won't apply
- Remember: an empty/no ingress rule combined with `policyTypes` only listing `Egress` leaves ingress traffic unaffected by this specific policy

</details>
