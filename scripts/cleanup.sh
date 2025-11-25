#!/bin/bash

echo "=== Nettoyage du déploiement ==="

helm uninstall rancher -n cattle-system || true
helm uninstall traefik -n traefik-system || true

kubectl delete -f ../rancher/rancher-ingress.yaml || true
kubectl delete -f ../metallb/metallb-config.yaml || true

kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml || true

kubectl delete namespace cattle-system traefik-system metallb-system || true

echo "✅ Nettoyage terminé"