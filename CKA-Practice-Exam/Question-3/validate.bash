#!/bin/bash
# validate-kubelet.sh
# Objectif : Valider la résolution de la panne kubelet
set -euo pipefail

# Vérification des privilèges root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Veuillez exécuter ce script en tant que root."
  exit 1
fi

echo "🔍 Vérification de l'état du kubelet..."

# 1. Vérifier si le service est actif
KUBELET_STATUS=$(systemctl is-active kubelet || true)

if [ "$KUBELET_STATUS" = "active" ]; then
  echo "✅ Étape 1 : Le service kubelet est 'active'."
else
  echo "❌ Échec : Le service kubelet est actuellement '$KUBELET_STATUS'."
  echo "💡 Indice : Regarde les logs avec 'journalctl -u kubelet -e --no-pager'"
  exit 1
fi

# 2. Vérifier si le mauvais fichier a bien été retiré du drop-in
KUBELET_DROPIN="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"

if grep -q "kubelet-MISSING.conf" "$KUBELET_DROPIN"; then
   echo "❌ Échec : Le fichier $KUBELET_DROPIN contient toujours la mauvaise configuration ('kubelet-MISSING.conf')."
   echo "💡 Indice : As-tu bien corrigé le fichier et fait un 'systemctl daemon-reload' ?"
   exit 1
else
   echo "✅ Étape 2 : Le fichier de configuration ne contient plus l'erreur injectée."
fi

echo "------------------------------------------------------"
echo "🎉 FÉLICITATIONS ! Tu as réparé le kubelet avec succès."
echo "Le nœud devrait maintenant être 'Ready' depuis le Control Plane."
