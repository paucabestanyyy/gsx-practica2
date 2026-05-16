#!/bin/bash
# Test automatic de totes les capacitats - 10 proves
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
PASS=0; FAIL=0
ck() { if [ $? -eq 0 ]; then echo -e "${GREEN}✅ $1${NC}"; PASS=$((PASS+1)); else echo -e "${RED}❌ $1${NC}"; FAIL=$((FAIL+1)); fi; }

echo "===== GSX Practica 2 - 10 TESTS ====="
kubectl cluster-info >/dev/null 2>&1; ck "T1: Cluster respon"
RUN=$(kubectl get pods -n greendev-dev --no-headers 2>/dev/null | grep -c Running)
[ "$RUN" -ge 2 ]; ck "T2: $RUN pods Running a greendev-dev"
URL=$(minikube service nginx-service -n greendev-dev --url 2>/dev/null)
curl -s --max-time 5 "$URL" | grep -q GreenDevCorp; ck "T3: Frontend HTTP OK"
kubectl get networkpolicy -n prod >/dev/null 2>&1; ck "T4: NetworkPolicy prod existeix"
kubectl get namespace dev prod >/dev/null 2>&1; ck "T5: Namespaces dev/prod"
DB=$(kubectl get pod prod-db -n prod -o jsonpath='{.status.podIP}' 2>/dev/null)
if [ -n "$DB" ]; then
  timeout 5 kubectl exec dev-hacker -n dev -- curl -s --max-time 3 "$DB" >/dev/null 2>&1
  [ $? -ne 0 ]; ck "T6: dev NO accedeix a prod ($DB)"
fi
PURL=$(minikube service prometheus -n monitoring --url 2>/dev/null | head -1)
curl -s --max-time 5 "$PURL/-/healthy" 2>/dev/null | grep -q Healthy; ck "T7: Prometheus OK"
GURL=$(minikube service grafana -n monitoring --url 2>/dev/null | head -1)
curl -s --max-time 5 "$GURL/api/health" 2>/dev/null | grep -q ok; ck "T8: Grafana OK"
[ -d terraform/.terraform ]; ck "T9: Terraform inicialitzat"
[ -f .github/workflows/ci.yml ]; ck "T10: CI/CD workflow definit"
echo ""; echo "===== $PASS/$((PASS+FAIL)) PASSATS ====="
