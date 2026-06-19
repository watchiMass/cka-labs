# Network Policy Labs (14–16)

Three progressive labs focused on Kubernetes Network Policies.

| # | Topic | Concept clé |
|---|-------|-------------|
| 14 | Default Deny + Selective Allow | podSelector + namespaceSelector (AND), default-deny ingress |
| 15 | Egress Restriction | policyTypes: Egress, DNS allow, restriction sortante |
| 16 | Multi-Tier Isolation | Architecture 3 tiers, combinaison ingress + deny-all |

## Progression

**Lab 14** — Poser les bases : bloquer tout le trafic entrant dans un namespace puis autoriser un seul pod source via une combinaison AND `namespaceSelector` + `podSelector`.

**Lab 15** — Passer à l'egress : contrôler les connexions *sortantes* d'un pod, tout en autorisant le DNS (piège classique à l'examen).

**Lab 16** — Synthèse : architecture web/api/db réaliste avec plusieurs policies à combiner. Teste la compréhension des flux autorisés vs bloqués sur plusieurs namespaces.

## Utilisation

```bash
# Setup
bash lab-14-default-deny/LabSetUp.bash

# Lire la question
cat lab-14-default-deny/Questions.bash

# Valider ta solution
bash lab-14-default-deny/validate.bash

# Consulter la solution
cat lab-14-default-deny/SolutionNotes.bash

# Nettoyer
bash lab-14-default-deny/cleanup.bash
```

## Concept à retenir : AND vs OR

```yaml
# AND — le pod doit être dans "monitoring" ET avoir app=prometheus
from:
- namespaceSelector:
    matchLabels:
      kubernetes.io/metadata.name: monitoring
  podSelector:           # ← même item (tiret commun)
    matchLabels:
      app: prometheus

# OR — le pod vient de "monitoring" OU a le label app=prometheus (n'importe où)
from:
- namespaceSelector:
    matchLabels:
      kubernetes.io/metadata.name: monitoring
- podSelector:           # ← tiret séparé
    matchLabels:
      app: prometheus
```
