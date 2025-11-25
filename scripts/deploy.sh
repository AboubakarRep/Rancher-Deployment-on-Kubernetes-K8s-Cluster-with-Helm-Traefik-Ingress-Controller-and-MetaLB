#!/bin/bash

set -e

echo "=== Déploiement de Rancher avec Traefik et MetalLB ==="

# Variables
KUBECONFIG=${KUBECONFIG:-~/.kube/config}
METALLB_VERSION="v0.13.12"
TRAEFIK_VERSION="23.0.0"
RANCHER_VERSION="2.12.2"

echo "📦 Installation des namespaces..."
kubectl apply -f namespaces/namespaces.yaml

echo "🔧 Installation de MetalLB..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml

echo "⏳ Attente du déploiement de MetalLB..."
kubectl -n metallb-system wait --for=condition=ready pod -l app=metallb --timeout=120s

echo "📡 Configuration de MetalLB..."
kubectl apply -f metallb/metallb-config.yaml

# Vérifier si le dépôt Traefik existe déjà
if ! helm repo list | grep -q "traefik"; then
  echo "🚀 Installation de Traefik avec Helm..."
  helm repo add traefik https://traefik.github.io/charts
  helm repo update
else
  echo "⚠️ Le dépôt Traefik est déjà ajouté, on saute cette étape."
fi

helm upgrade --install traefik traefik/traefik \
  --namespace traefik-system \
  --version ${TRAEFIK_VERSION} \
  --values traefik/traefik-values.yaml

echo "⏳ Attente du déploiement de Traefik..."
kubectl -n traefik-system wait --for=condition=ready pod -l app.kubernetes.io/name=traefik --timeout=120s

echo "🐮 Installation de Rancher avec Helm..."
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version ${RANCHER_VERSION} \
  --values rancher/rancher-values.yaml

echo "📋 Application de l'ingress Rancher..."
kubectl apply -f rancher/rancher-ingress.yaml

echo "⏳ Attente du déploiement de Rancher..."
kubectl -n cattle-system wait --for=condition=ready pod -l app=rancher --timeout=600s

echo "✅ Déploiement terminé!"
echo ""
echo "📊 Tableau de bord Traefik: https://10.64.13.210:9000/dashboard/"
echo "🐮 Rancher: https://rancher.10.64.13.211.nip.io"
echo ""
echo "🔍 Vérification des services:"
kubectl get svc -n traefik-system
kubectl get svc -n cattle-system
