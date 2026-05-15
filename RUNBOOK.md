# 📖 GreenDevCorp - Operational Runbook

## 0. Quick start (resumit)
```bash
# Desplegament complet des de zero:
./disaster-recovery.sh
```

## 1. Architecture overview
Veure [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) per al diagrama complet.

Flux de dades resumit:
```
Internet -> nginx (NodePort:30080) -> backend (8080) -> redis (6379, PVC)
```
Monitoring: Prometheus (`:30090`) -> Grafana (`:30030`).

## 2. Component summary
| Component  | Manifest                  | Rol                                  |
|------------|---------------------------|--------------------------------------|
| nginx      | terraform/main.tf         | Reverse proxy (replicas=2)           |
| backend    | terraform/main.tf         | Python HTTP server (replicas=2)      |
| redis      | terraform/main.tf         | Persistent state (StatefulSet+PVC)  |
| Prometheus | observability/01-*.yaml   | Metrics scraper                      |
| Grafana    | observability/02-*.yaml   | Dashboards + visualizacio alertes    |
| NetPolicy  | week12/02-*.yaml          | Dev no pot tocar prod                |

## 3. Operational tasks

| Accio                          | Comanda                                                                |
|--------------------------------|------------------------------------------------------------------------|
| Desplegar des de zero          | `./disaster-recovery.sh`                                               |
| Desplegar nomes app (dev)      | `cd terraform && terraform apply -var-file=envs/dev.tfvars`            |
| Promoure imatge a staging      | `terraform apply -var-file=envs/staging.tfvars -var="image_tag=<sha>"` |
| Escalar nginx                  | `kubectl scale deployment nginx -n greendev-dev --replicas=5`          |
| Veure logs backend             | `kubectl logs -l app=backend -n greendev-dev --tail=100`               |
| Auditoria de xarxa             | `./week12/test-seguretat.sh`                                           |
| Obrir UI frontend              | `minikube service nginx-service -n greendev-dev`                       |
| Obrir Prometheus               | `minikube service prometheus -n monitoring`                            |
| Obrir Grafana                  | `minikube service grafana -n monitoring`                               |
| Rollback a versio anterior     | `kubectl rollout undo deployment/backend -n greendev-dev`              |
| Rollback complet via Terraform | `terraform apply -var="image_tag=<sha-anterior>"`                       |
| Veure recursos d'un namespace  | `kubectl top pods -n greendev-dev`                                     |

## 4. Deploy a una nova versio (workflow standard)
```bash
# 1. Codi: fes canvis a app-python/app.py
# 2. Commit & push:
git add . && git commit -m "feat: nova funcionalitat X" && git push

# 3. GitHub Actions construeix la imatge automaticament i la tagueja amb el commit SHA
#    Veure: https://github.com/paucabestanyyy/gsx-practica2/actions

# 4. Quan el CI esta verd, fes deploy local:
SHA=$(git rev-parse --short=8 HEAD)
cd terraform/
terraform apply -var-file=envs/dev.tfvars -var="image_tag=$SHA"

# 5. Verificar:
kubectl get pods -n greendev-dev
kubectl rollout status deployment/backend -n greendev-dev
```

## 5. Troubleshooting
Veure [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) per a la guia completa
(10 problemes comuns documentats).

## 6. Backup & Recovery

### Backup
El PVC de Redis es persistent localment a Minikube. Per a un backup real:
```bash
kubectl exec redis-0 -n greendev-dev -- redis-cli BGSAVE
kubectl cp greendev-dev/redis-0:/data/dump.rdb ./backup-$(date +%Y%m%d).rdb
```

### Recovery
```bash
./disaster-recovery.sh
# Despres del deploy:
kubectl cp ./backup-YYYYMMDD.rdb greendev-dev/redis-0:/data/dump.rdb
kubectl delete pod redis-0 -n greendev-dev  # forçar restart per a llegir el dump
```
