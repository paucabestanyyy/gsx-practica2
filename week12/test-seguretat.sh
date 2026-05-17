#!/bin/bash
###############################################################################
# Test de NetworkPolicies (W12) - GreenDevCorp
# Detecta correctament si dev pot o no accedir a prod
###############################################################################
set +e

echo "========================================================="
echo "🛡️  SCRIPT D'AUDITORIA DE XARXES (NETWORK POLICIES)"
echo "========================================================="

DB_IP=$(kubectl get pod prod-db -n prod -o jsonpath='{.status.podIP}')
echo "[*] IP de prod-db: $DB_IP"
echo ""

# Detectar CNI per saber si NetworkPolicies s'enforcen
CNI=$(kubectl get pods -n kube-system -o jsonpath='{.items[*].metadata.labels.k8s-app}' | tr ' ' '\n' | grep -E "calico|cilium" | head -1)

if [ -z "$CNI" ]; then
    echo "⚠️  AVÍS: CNI detectat = bridge (per defecte de minikube)"
    echo "   El CNI per defecte NO enforça NetworkPolicies."
    echo "   Per a una validació real, instal·lar Calico:"
    echo "   kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml"
    echo ""
else
    echo "[*] CNI detectat: $CNI (enforça NetworkPolicies)"
    echo ""
fi

echo "[PROVA 1] Atac des de Desenvolupament -> Producció"
echo "    S'espera: Bloqueig (timeout o connection refused)"
CODE=$(kubectl exec dev-hacker -n dev -- curl -s -o /dev/null --max-time 3 -w "%{http_code}" "$DB_IP" 2>/dev/null)
echo "    Codi HTTP rebut: $CODE"
if [ "$CODE" = "000" ] || [ -z "$CODE" ]; then
    echo "    ✅ PASSAT: La NetworkPolicy BLOQUEJA l'atac correctament"
    T1=0
else
    echo "    ❌ FALLAT: dev-hacker HA POGUT accedir a prod-db (codi $CODE)"
    echo "       Causa: CNI sense suport de NetworkPolicies. Instal·lar Calico."
    T1=1
fi
echo ""

echo "[PROVA 2] Connexió legítima Producció -> Producció"
echo "    S'espera: HTTP 200"
CODE=$(kubectl exec prod-worker -n prod -- curl -s -o /dev/null --max-time 3 -w "%{http_code}" "$DB_IP" 2>/dev/null)
echo "    Codi HTTP rebut: $CODE"
if [ "$CODE" = "200" ]; then
    echo "    ✅ PASSAT: prod-worker accedeix correctament a prod-db"
    T2=0
else
    echo "    ❌ FALLAT: prod-worker NO ha pogut accedir (codi $CODE)"
    T2=1
fi
echo ""

echo "========================================================="
if [ "$T1" -eq 0 ] && [ "$T2" -eq 0 ]; then
    echo "✅ TOTS ELS TESTS DE SEGURETAT HAN PASSAT"
    exit 0
else
    echo "❌ Algun test ha fallat. Veure missatges anteriors."
    exit 1
fi
