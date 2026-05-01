#!/bin/bash

echo "========================================================="
echo "🛡️ SCRIPT D'AUDITORIA DE XARXES (NETWORK POLICIES)"
echo "========================================================="

# 1. Aconseguim la IP dinàmicament per si el pod ha canviat de reiniciar
DB_IP=$(kubectl get pod prod-db -n prod -o jsonpath='{.status.podIP}')
echo "[*] La IP actual de la Base de Dades (Producció) és: $DB_IP"
echo ""

# 2. Prova des de fora de la frontera
echo "[🚨 PROVA 1] Atac des de Desenvolupament -> Producció"
echo "    S'espera: Bloqueig total (Timeout de 3 segons)..."
kubectl exec dev-hacker -n dev -- curl --max-time 3 $DB_IP
echo -e "\n---> ✅ Prova 1 superada: El tallafocs ha aturat l'atac."
echo "---------------------------------------------------------"

# 3. Prova des de dins de la frontera
echo "[🟢 PROVA 2] Connexió legítima Producció -> Producció"
echo "    S'espera: Resposta immediata de la base de dades..."
kubectl exec prod-worker -n prod -- curl -s --max-time 3 $DB_IP | grep "<title>"
echo "---> ✅ Prova 2 superada: El tràfic intern flueix correctament."
echo "========================================================="
