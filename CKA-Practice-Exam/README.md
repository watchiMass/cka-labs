# CKA Hard-Mode Practice Exam (19 Questions)

A full-length, hard-difficulty CKA practice exam, built to match the
official exam's domain weighting and current curriculum
(Kubernetes v1.33). Every question follows the same 4-part structure
used elsewhere in this repo:

- `LabSetUp.bash` — prepares the cluster state for the question
  (creates namespaces, deploys broken/working resources, taints nodes,
  installs CRDs, etc.)
- `Questions.bash` — the scenario, exact tasks, constraints, and a
  documentation reference (read manually — don't just copy commands)
- `SolutionNotes.bash` — a full worked solution with explanations
- `validate.bash` — an automated PASS/FAIL grading script
- `cleanup.bash` — removes everything the question created

## Domain Coverage & Weighting

Mapped to the official CKA exam blueprint:

| Domain | Weight | Questions |
|---|---|---|
| Cluster Architecture, Installation & Configuration | 25% | 1, 2, 6 |
| Workloads & Scheduling | 15% | 4, 5, 7, 10, 19 |
| Services & Networking | 20% | 8, 11, 12, 13, 16, 17 |
| Storage | 10% | 14 |
| Troubleshooting | 30% | 1, 3, 9, 15, 16, 17, 18 |

(Several questions span two domains, reflecting how the real exam mixes
troubleshooting into every category.)

## Question Index

| # | Topic | Domain |
|---|---|---|
| 1 | etcd Backup & Restore with TLS | Cluster Architecture |
| 2 | kubeadm: Join a Second Control-Plane Node (HA) | Cluster Architecture |
| 3 | Repair a Broken kubelet systemd Service | Troubleshooting |
| 4 | Resource Allocation — Pod Resource Division | Workloads & Scheduling |
| 5 | HorizontalPodAutoscaler with Scaling Behavior | Workloads & Scheduling |
| 6 | cert-manager: Self-Signed ClusterIssuer & Certificate (CRDs) | Cluster Architecture |
| 7 | PriorityClass & Pod Preemption | Workloads & Scheduling |
| 8 | Complex Multi-Rule NetworkPolicy (ingress + egress) | Services & Networking |
| 9 | Container Runtime (CRI Socket) Misconfiguration | Troubleshooting / Cluster Architecture |
| 10 | Taints, Tolerations & Node Affinity Combined | Workloads & Scheduling |
| 11 | Gateway API: Gateway + HTTPRoute | Services & Networking |
| 12 | Ingress with TLS & Path-Based Routing | Services & Networking |
| 13 | Default-Deny NetworkPolicy + Namespace Selector | Services & Networking |
| 14 | StorageClass, Dynamic Provisioning & Volume Expansion | Storage |
| 15 | Full etcd Disaster Recovery (Corrupted Cluster) | Troubleshooting |
| 16 | NodePort Service Unreachable (Readiness Probe Bug) | Troubleshooting / Networking |
| 17 | TLS Certificate / Hostname Mismatch Debugging | Troubleshooting / Networking |
| 18 | kubectl patch — Live Resource Limit Hot-Fix | Troubleshooting / Workloads |
| 19 | Resource Allocation v2 — Node-Constrained Pod Scheduling | Workloads & Scheduling |

## How to Use

1. Spin up a multi-node cluster (kubeadm cluster with at least one
   control-plane node and 2+ worker nodes is recommended; some questions
   — 2, 3, 9 — specifically require multiple nodes and SSH access between
   them, and won't work on a single-node Killercoda playground).
2. For each question, in order:
   ```bash
   bash Question-N/LabSetUp.bash
   cat Question-N/Questions.bash        # read the scenario
   # ... attempt the task ...
   bash Question-N/validate.bash        # check your work
   cat Question-N/SolutionNotes.bash    # if you're stuck
   bash Question-N/cleanup.bash         # reset before the next question
   ```

## Prerequisites by Question

- **Questions 1, 15**: root/sudo access on the control-plane node,
  `etcdctl` installed.
- **Questions 2, 3, 9**: a cluster with 2+ nodes and SSH access between
  them; sudo on the target node.
- **Questions 6, 11**: outbound internet access to install cert-manager /
  Gateway API CRDs (or pre-mirrored manifests in an air-gapped lab).
- **Questions 8, 13**: a CNI that enforces NetworkPolicy (e.g. Calico,
  Cilium) — kindnet/flannel alone will NOT enforce these policies.
- **Questions 5**: `metrics-server` installed and reporting metrics.
- **Questions 11, 12, 17**: an Ingress controller / Gateway controller
  installed (e.g. ingress-nginx) for full end-to-end functional testing;
  structural validation still works without one.
- **Question 19**: 2+ worker nodes to label distinctly (pool=standard /
  pool=highmem); falls back gracefully with a warning on single-worker
  clusters.

## Notes

- All YAML uses stable, non-deprecated API versions current as of
  Kubernetes v1.33 (e.g. `autoscaling/v2`, `networking.k8s.io/v1`,
  `gateway.networking.k8s.io/v1`, `scheduling.k8s.io/v1`).
- Several questions intentionally seed a **broken** state (bad readiness
  probe, mismatched TLS cert, misconfigured kubelet, corrupted etcd) — the
  task is to diagnose and repair it, mirroring the troubleshooting-heavy
  nature of the real exam.
- `validate.bash` scripts are designed to be idempotent and safe to
  re-run; they never modify cluster state, only read it.
