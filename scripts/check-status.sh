#!/bin/bash

echo "=== Statut du déploiement ==="

echo ""
echo "🔍 Pods:"
kubectl get pods -n metallb-system
echo ""
kubectl get pods -n traefik-system
echo ""
kubectl get pods -n cattle-system

echo ""
echo "🌐 Services:"
kubectl get svc -n traefik-system
kubectl get svc -n cattle-system

echo ""
echo "🚪 Ingress:"
kubectl get ingress -A

echo ""
echo "📡 IPs MetalLB:"
kubectl get configmap -n metallb-system config -o yaml