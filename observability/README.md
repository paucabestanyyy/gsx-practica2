# Week 13 Challenge A - Observability (Prometheus + Grafana)
**Autors:** Pau Cabestany i Eric Hernandez

## 1. Per que observability?
Sense metriques, els problemes nomes es detecten quan els usuaris es queixen. Amb Prometheus
recollim **what's happening right now** i Grafana ho fa visual.

## 2. Components
- **Prometheus** (`01-prometheus.yaml`): scrapeja metriques cada 15s, retencio 7 dies.
- **Grafana** (`02-grafana.yaml`): dashboard precarregat amb 4 panells clau.
- **Alert rules**: 4 alertes definides al ConfigMap de Prometheus.

## 3. Desplegament
```bash
kubectl apply -f observability/
kubectl get pods -n monitoring        # esperar Running
kubectl get svc -n monitoring         # veure NodePorts
```

## 4. Acces
```bash
# Prometheus UI
minikube service prometheus -n monitoring
# Es obre al port 30090

# Grafana UI
minikube service grafana -n monitoring
# Es obre al port 30030
# Login: admin / changeme
```

## 5. Dashboard precarregat
Quan Grafana s'inicia, ja troba:
- Prometheus com a datasource per defecte
- Dashboard "GreenDevCorp - Overview" amb 4 panells:
  1. **Pods running** per namespace
  2. **CPU per pod**
  3. **Memory per pod**
  4. **HTTP requests/s** per status code

## 6. Alertes definides
| Alerta             | Condicio                                  | Severitat |
|--------------------|-------------------------------------------|-----------|
| HighErrorRate      | Errors HTTP 5xx > 5% durant 2m            | critical  |
| HighCPU            | Pod amb CPU > 80% durant 5m               | warning   |
| PodDown            | Pod sense respondre 1m                    | critical  |
| HighMemoryUsage    | Memoria > 90% del limit durant 5m         | warning   |

Per veure alertes actives: `http://<minikube-ip>:30090/alerts`

## 7. Com generar carrega per veure metriques (test)
```bash
# En un terminal:
NGINX_URL=$(minikube service nginx-service -n greendev --url)
while true; do curl -s $NGINX_URL > /dev/null; sleep 0.1; done
```
A Grafana hauries de veure el panell "HTTP requests/s" pujar a ~10 req/s.

## 8. Per anar mes lluny
- Afegir **node-exporter** per metriques de host (disk, network, etc.)
- Afegir **kube-state-metrics** per estats avancats de K8s
- Configurar **Alertmanager** per enviar notificacions a Slack/email
