#!/bin/bash
# setup-broken-kubelet.sh
# Objectif : Casser le kubelet pour l'entraînement CKA
set -euo pipefail

# Vérification des privilèges root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Veuillez exécuter ce script en tant que root (ex: sudo ./setup-broken-kubelet.sh)."
  exit 1
fi

echo "⚙️  Mise en place de la Question 3 : Kubelet en panne..."

KUBELET_DROPIN="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"

if [[ -f "$KUBELET_DROPIN" ]]; then
  # Création d'une sauvegarde de triche/secours (optionnel pour l'entraînement, mais bonne pratique)
  cp "$KUBELET_DROPIN" "${KUBELET_DROPIN}.bak"
  
  # Remplacement du chemin de manière plus globale (capture toutes les occurrences de kubelet.conf)
  sed -i 's#/etc/kubernetes/kubelet.conf#/etc/kubernetes/kubelet-MISSING.conf#g' "$KUBELET_DROPIN"
  echo "✅ Modification du fichier $KUBELET_DROPIN effectuée."
else
  echo "⚠️  ATTENTION: $KUBELET_DROPIN introuvable. Assurez-vous que ce nœud a été bootstrappé avec kubeadm."
  exit 1
fi

# Rechargement et redémarrage (le restart va échouer, d'où le || true)
echo "🔄 Redémarrage de systemd et du service kubelet..."
systemctl daemon-reload
systemctl restart kubelet || true

echo "------------------------------------------------------"
echo "[OK] Environnement de laboratoire prêt !"
echo "Le service kubelet sur ce nœud est maintenant mal configuré."
echo "Il devrait être dans un état d'échec (CrashLoopBackOff)."
echo "Depuis le control plane, le nœud finira par afficher 'NotReady'."
echo "Ton objectif : Le réparer !"
