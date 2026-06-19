# CKA Troubleshooting Labs

Labs de troubleshooting inspirés du format CKA pour pratiquer le diagnostic et la résolution de problèmes sur un cluster Kubernetes réel (1 controlplane + 2 workers).

> **Prérequis** : un cluster Kubernetes accessible via `kubectl`, avec au moins 2 worker nodes.
> Recommandé : [Killercoda CKA playground](https://killercoda.com/playgrounds/scenario/cka)

---

## Structure

Chaque lab est dans son propre dossier avec 5 fichiers :

| Fichier | Rôle |
|---|---|
| `LabSetUp.bash` | Crée les ressources cassées dans le cluster |
| `Questions.bash` | Énoncé du scénario à résoudre |
| `SolutionNotes.bash` | Solution commentée étape par étape |
| `validate.bash` | Validation automatique de ta solution |
| `cleanup.bash` | Supprime toutes les ressources du lab |

---

## Labs disponibles

| # | Thème | Concepts clés |
|---|---|---|
| Q1 | Pod CrashLoopBackOff | Probes, ImagePullBackOff, image tag invalide |
| Q2 | Service Unreachable | Selector mismatch, targetPort incorrect, endpoints |
| Q3 | Node Scheduling | Cordon, taint, nodeSelector, pod Pending |
| Q4 | PVC Pending | StorageClass inexistante, accessMode incompatible |
| Q5 | Deployment Rollout & RBAC | OOMKilled, rolling update bloqué, Role/RoleBinding |

---

## Utilisation

### 1. Setup du lab

```bash
bash Q1-Pod-Crashloop/LabSetUp.bash
```

### 2. Lire l'énoncé

```bash
cat Q1-Pod-Crashloop/Questions.bash
```

### 3. Résoudre (sans regarder la solution !)

```bash
kubectl get pods -n q1-crashloop
kubectl describe pod ...
# → trouve et corrige le problème
```

### 4. Valider

```bash
bash Q1-Pod-Crashloop/validate.bash
```

Sortie attendue :
```
============================================
 Validating Question 1: Pod Troubleshooting
============================================
  PASS: Pod 'api-server-pod' exists in namespace q1-crashloop
  PASS: Pod 'api-server-pod' is in Running phase
  ...
Results: 7/7 passed, 0 failed
All checks passed!
```

### 5. Voir la solution (si besoin)

```bash
cat Q1-Pod-Crashloop/SolutionNotes.bash
```

### 6. Cleanup

```bash
bash Q1-Pod-Crashloop/cleanup.bash
```

---

## Commandes de diagnostic utiles (à garder sous la main)

```bash
# Vue d'ensemble rapide
kubectl get pods -A
kubectl get events -n <ns> --sort-by='.lastTimestamp'

# Pod en détresse
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous   # crash précédent

# Node
kubectl get nodes
kubectl describe node <node>
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Service / réseau
kubectl get endpoints -n <ns>
kubectl exec -it <debug-pod> -n <ns> -- curl http://<service>

# PVC / Storage
kubectl get pvc -n <ns>
kubectl describe pvc <pvc> -n <ns>
kubectl get storageclass

# Déploiement
kubectl rollout status deployment/<name> -n <ns>
kubectl rollout history deployment/<name> -n <ns>
kubectl rollout undo deployment/<name> -n <ns>

# RBAC
kubectl auth can-i list pods -n <ns> --as=system:serviceaccount:<ns>:<sa>
```
