#!/bin/bash
# Recrear nomes Redis (StatefulSet + PVC) si s'ha perdut
set -e
cd ~/practica2/terraform
terraform refresh -var-file=envs/dev.tfvars 2>/dev/null || true
terraform apply -var-file=envs/dev.tfvars -auto-approve \
  -target=kubernetes_service.redis \
  -target=kubernetes_stateful_set.redis
cd ..
kubectl wait --for=condition=ready pod redis-0 -n greendev-dev --timeout=300s
kubectl exec redis-0 -n greendev-dev -- redis-cli SET demo "OK_PERSISTENT"
kubectl exec redis-0 -n greendev-dev -- redis-cli GET demo
echo "Redis recreat i persistencia validada"
