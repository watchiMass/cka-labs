#!/bin/bash
# setup-broken-kubelet.sh
# Objectif : Casser le kubelet pour l'entraînement CKA
set -euo pipefail

# Vérification des privilèges root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Veuillez exécuter ce script en tant que root (ex: sudo ./LabSetUp.bash)."
  exit 1
fi

echo "⚙️  Mise en place de la Question 3 : Kubelet en panne..."

# Recherche automatique de l'emplacement du drop-in kubeadm
KUBELET_DROPIN=""
POSSIBLE_PATHS=(
  "/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
  "/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf"
  "/lib/systemd/system/kubelet.service.d/10-kubeadm.conf"
)

for path in "${POSSIBLE_PATHS[@]}"; do
  if [[ -f "$path" ]]; then
    KUBELET_DROPIN="$path"
    break
  fi
done

if [[ -n "$KUBELET_DROPIN" ]]; then
  echo "✅ Fichier de configuration trouvé : $KUBELET_DROPIN"
  
  # Création d'une sauvegarde
  cp "$KUBELET_DROPIN" "${KUBELET_DROPIN}.bak"
  
  # Remplacement du chemin pour casser la configuration
  sed -i 's#/etc/kubernetes/kubelet.conf#/etc/kubernetes/kubelet-MISSING.conf#g' "$KUBELET_DROPIN"
  echo "✅ Modification du fichier effectuée (erreur injectée)."
else
  echo "⚠️  ATTENTION : Impossible de trouver 10-kubeadm.conf."
  echo "Assurez-vous que ce nœud a bien été bootstrappé avec kubeadm."
  exit 1
fi

# Rechargement et redémarrage (le restart va échouer, ce qui est le but recherché)
echo "🔄 Redémarrage de systemd et du service kubelet..."
systemctl daemon-reload
systemctl restart kubelet || true

echo "------------------------------------------------------"
echo "[OK] Environnement de laboratoire prêt !"
echo "Le service kubelet sur ce nœud est maintenant mal configuré."
echo "Il devrait être dans un état d'échec (CrashLoopBackOff)."
