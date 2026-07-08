# CKA Practice Exercises — Killercoda-style (setup / question / validate / cleanup)

Ce dossier contient 16 exercices au format Killercoda, chacun avec :
- `setup.sh` — prépare l'environnement (namespaces, ressources, fichiers de base)
- `question.md` — l'énoncé (avec indices repliables)
- `validate.sh` — vérifie automatiquement si l'exercice est résolu correctement (exit 0 = succès)
- `cleanup.sh` — nettoie les ressources créées

## Structure

```
q1/  Contexts (kubeconfig)
q2/  CRD, Helm, cert-manager
q3/  Scale down StatefulSet
q4/  Find Pods first to be terminated (QoS)
q5/  Kustomize configure HPA Autoscaler
q6/  Storage, PV, PVC, Pod volume
q7/  Node and Pod Resource Usage (kubectl top)
q8/  Update Kubernetes Version and join cluster
q9/  Contact K8s Api from inside Pod
q10/ RBAC ServiceAccount Role RoleBinding
q11/ DaemonSet on all Nodes
q12/ Deployment on all Nodes (anti-affinity)
q13/ Gateway Api Ingress
q14/ Check how long certificates are valid
q15/ NetworkPolicy
q16/ Update CoreDNS Configuration
```

## Utilisation générique (sur ton propre cluster, pas besoin de multi-VM Killercoda)

```bash
cd q1
bash setup.sh
# ... résous l'exercice en lisant question.md ...
bash validate.sh
bash cleanup.sh
```

## Notes importantes par exercice

- **q1** : génère un kubeconfig factice à plusieurs contextes localement, aucune vraie connexion cluster requise pour cette partie.
- **q2** : nécessite `helm` installé et un accès réseau vers `charts.jetstack.io`. Le script `setup.sh` installe helm si absent.
- **q5** : le dossier `api-gateway/` (kustomize) doit être présent à côté de `setup.sh` — copie tout le dossier `q5/` entier, pas seulement les scripts.
- **q7** : installe `metrics-server` si absent. Le patch `--kubelet-insecure-tls` est ajouté pour fonctionner sur clusters de test/kind. Compte 1-2 min avant que `kubectl top` retourne des données.
- **q8** : nécessite un cluster **multi-nœuds** kubeadm avec un `node01` non joint et volontairement sur une version antérieure. Ce n'est pas simulable sur un cluster single-node — adapte les noms de nœuds à ton scénario Killercoda réel.
- **q13** : le plus lourd. Installe les CRDs Gateway API officielles + NGINX Gateway Fabric comme implémentation concrète pour que les tests `curl` fonctionnent réellement. Nécessite un accès réseau sortant vers GitHub. Après setup, il faut exposer le Service du Gateway en NodePort 30080 (instructions affichées à la fin du setup).
- **q14** et **q16** : supposent un cluster kubeadm classique avec les certs dans `/etc/kubernetes/pki` et CoreDNS géré comme Deployment/ConfigMap standard dans `kube-system`. Doivent être exécutés sur le control-plane.
- **q15** : nécessite un CNI supportant les NetworkPolicy (Calico, Cilium...). Sur flannel simple, la policy sera acceptée par l'API mais pas appliquée — le script le signale.

## Idée de format Killercoda "scenario"

Pour un vrai déploiement Killercoda multi-step, tu peux mapper chaque question à un "step" avec :
- `step1/setup.sh` (background_actions du step)
- `step1/verify.sh` (step's `verify` script, utilise `validate.sh`)
- `step1/text.md` (question.md renommé)

et référencer les scripts dans `index.json` du scénario.
