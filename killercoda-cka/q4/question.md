# Question 4 | Find Pods first to be terminated

Difficulty: Medium

Check all available Pods in the Namespace `project-c13` and find the names of those that would probably be terminated first if the nodes run out of resources (cpu or memory).

Write the Pod names into `/opt/course/4/pods-terminated-first.txt`.

<details><summary>Need a hint?</summary>

Pods with QoS class `BestEffort` (no requests/limits set at all) are evicted first under node pressure, followed by `Burstable`, then `Guaranteed` last.

- `kubectl -n project-c13 get pods -o jsonpath='{range .items[*]}{.metadata.name}{"  "}{.status.qosClass}{"\n"}{end}'`

</details>
