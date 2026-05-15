#!/bin/bash
###############################################################################
# Disaster Recovery / Full Integration Test (W13 Challenge B - REQUIRED)
#
# Aquest script desplega tot el sistema des de zero usant Terraform (IaC).
# Es el "from-scratch deployment" requerit per la practica.
###############################################################################
set -e

echo "========================================================="
echo "🔥 DISASTER RECOVERY - GreenDevCorp - Practica 2 GSX 🔥"
echo "========================================================="
START_TIME=$(date +%s)

###############################################################################
# Pas 1: Destruccio total
###############################################################################
echo -e "\n[1/6] 🗑️  Destruint el cluster actual..."
minikube delete || true

###############################################################################
# Pas 2: Arrencada de Minikube amb Calico (per a NetworkPolicies)
###############################################################################
echo -e "\n[2/6] 🚀 Arrencant Minikube amb Calico..."
minikube start --cni=calico --memory=4096 --cpus=2

###############################################################################
# Pas 3: Aplicacio principal via Terraform (IaC)
###############################################################################
echo -e "\n[3/6] 🏗️  Desplegant l'aplicacio amb Terraform (dev env)..."
cd terraform/
terraform init -no-color
terraform apply -var-file=envs/dev.tfvars -auto-approve -no-color
cd ..

###############################################################################
# Pas 4: NetworkPolicies de W12 (segregacio dev/prod)
###############################################################################
echo -e "\n[4/6] 🛡️  Aplicant NetworkPolicies (W12)..."
kubectl apply -f week12/

###############################################################################
# Pas 5: Stack d'observability (Prometheus + Grafana)
###############################################################################
echo -e "\n[5/6] 📊 Desplegant Prometheus + Grafana..."
kubectl apply -f observability/

# Esperar fins que tot estigui Ready (max 10 min)
echo -e "\n    Esperant a que tots els pods estiguin Ready (max 10 min)..."
kubectl wait --for=condition=ready pod --all --all-namespaces --timeout=600s

###############################################################################
# Pas 6: Tests d'integracio
###############################################################################
echo -e "\n[6/6] ✅ Llançant tests d'integracio..."

# Test 1: NetworkPolicies
echo -e "\n    Test 1: NetworkPolicies (dev !-> prod)"
./week12/test-seguretat.sh

# Test 2: Frontend accessible
echo -e "\n    Test 2: Frontend nginx accessible des de fora"
NGINX_URL=$(minikube service nginx-service -n greendev-dev --url)
curl -sf $NGINX_URL > /dev/null && echo "    ✅ Frontend OK ($NGINX_URL)" || echo "    ❌ Frontend KO"

# Test 3: Prometheus accessible
echo -e "\n    Test 3: Prometheus UI accessible"
PROM_URL=$(minikube service prometheus -n monitoring --url)
curl -sf $PROM_URL > /dev/null && echo "    ✅ Prometheus OK ($PROM_URL)" || echo "    ❌ Prometheus KO"

# Test 4: Grafana accessible
echo -e "\n    Test 4: Grafana UI accessible"
GRAF_URL=$(minikube service grafana -n monitoring --url)
curl -sf $GRAF_URL/api/health > /dev/null && echo "    ✅ Grafana OK ($GRAF_URL)" || echo "    ❌ Grafana KO"

###############################################################################
# Resum final
###############################################################################
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MIN=$((DURATION / 60))
SEC=$((DURATION % 60))

echo "========================================================="
echo "✅ INTEGRATION TEST COMPLERT EN ${MIN}m ${SEC}s"
echo "========================================================="
echo ""
echo "Acces a les UIs:"
echo "  Frontend:   $NGINX_URL"
echo "  Prometheus: $PROM_URL"
echo "  Grafana:    $GRAF_URL  (admin / changeme)"
echo ""
echo "Per veure pods:"
echo "  kubectl get pods --all-namespaces"
echo "========================================================="
