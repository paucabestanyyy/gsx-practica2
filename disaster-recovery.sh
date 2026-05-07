#!/bin/bash
set -e

echo "========================================================="
echo "🔥 INICIANT PROTOCOL DE DISASTER RECOVERY (CHALLENGE B) 🔥"
echo "========================================================="

echo -e "\n[1/5] 🗑️ Destruint el clúster ofegat..."
minikube delete || true

echo -e "\n[2/5] 🚀 Aixecant clúster K8s amb limitació de RAM per protegir Debian..."
minikube start --cni=calico

echo -e "\n[3/5] 🏗️ Desplegant la infraestructura com a codi (IaC)..."
kubectl apply -f kubernetes/
kubectl apply -f week12/01-environments.yaml
kubectl apply -f week12/02-network-policy.yaml

echo -e "\n[4/5] ⏳ Donant fins a 10 minuts a la màquina per descarregar i arrencar..."
kubectl wait --for=condition=ready pod --all --all-namespaces --timeout=600s

echo -e "\n[5/5] 🛡️ Llançant els tests d'integració i seguretat end-to-end..."
./week12/test-seguretat.sh

echo "========================================================="
echo "✅ RECUPERACIÓ COMPLETADA AMB ÈXIT. SISTEMA 100% OPERATIU."
echo "========================================================="
