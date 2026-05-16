#!/bin/bash
# Demo interactiva per l'entrevista oral - GSX Practica 2
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'
pause() { echo ""; echo -e "${YELLOW}>>> ENTER per continuar...${NC}"; read -r; }
hdr() { echo ""; echo -e "${BLUE}===== $1 =====${NC}"; }
ok() { echo -e "${GREEN}[OK] $1${NC}"; }

hdr "1. VISIO GENERAL DEL CLUSTER"
kubectl get pods --all-namespaces
ok "4 namespaces: greendev-dev (app), monitoring (W13), prod/dev (W12), kube-system"
pause

hdr "2. FRONTEND FUNCIONAL (Nginx -> Backend)"
NGINX_URL=$(minikube service nginx-service -n greendev-dev --url)
echo "URL: $NGINX_URL"
curl -s "$NGINX_URL"; echo ""
ok "HTTP funcional: Internet -> Nginx (30080) -> Backend Python"
pause

hdr "3. SCALING HORITZONTAL"
echo "Escalant nginx a 3 replicas..."
kubectl scale deployment nginx -n greendev-dev --replicas=3
sleep 5
kubectl get pods -n greendev-dev -l app=nginx
echo "Tornant a 1..."
kubectl scale deployment nginx -n greendev-dev --replicas=1
ok "Scaling demostrat"
pause

hdr "4. SELF-HEALING"
POD=$(kubectl get pod -n greendev-dev -l app=backend -o jsonpath='{.items[0].metadata.name}')
echo "Pod actual: $POD - matant-lo..."
kubectl delete pod $POD -n greendev-dev
sleep 10
kubectl get pods -n greendev-dev -l app=backend
ok "Kubernetes ha creat un POD nou automaticament"
pause

hdr "5. PERSISTENCIA (Redis StatefulSet + PVC)"
kubectl get pvc -n greendev-dev
echo ""
kubectl exec redis-0 -n greendev-dev -- redis-cli SET demo_key "GSX-Practica2"
kubectl exec redis-0 -n greendev-dev -- redis-cli GET demo_key
ok "Dades persistents al PVC"
pause

hdr "6. NETWORKPOLICIES (W12)"
kubectl get pods -n prod
kubectl get pods -n dev
kubectl get networkpolicy -n prod
echo ""
./week12/test-seguretat.sh
pause

hdr "7. OBSERVABILITY (W13)"
kubectl get pods -n monitoring
echo ""
echo "URLs (obre-les al navegador):"
echo "  Prometheus: $(minikube service prometheus -n monitoring --url)"
echo "  Grafana:    $(minikube service grafana -n monitoring --url) (admin/changeme)"
ok "Prometheus + Grafana amb 4 alert rules"
pause

hdr "8. INFRASTRUCTURE AS CODE (W11)"
ls terraform/envs/
cd terraform && terraform state list && cd ..
ok "9 recursos K8s gestionats com a codi"
pause

hdr "RESUM"
echo "W8 Docker, W9 Compose, W10 K8s, W11 IaC+CI/CD, W12 Network, W13 Observability"
echo "Repo: https://github.com/paucabestanyyy/gsx-practica2"
ok "Nivell Advanced (***) demostrat"
