# Architecture Diagram & Component Documentation
**Projecte:** GreenDevCorp - Practica 2 GSX
**Autors:** Pau Cabestany i Eric Hernandez

## 1. Diagrama d'arquitectura complet

```
                            ┌──────────────────────────────────┐
                            │           INTERNET                │
                            └────────────────┬─────────────────┘
                                             │
                                             │ HTTP :80
                                             ▼
                            ┌──────────────────────────────────┐
                            │   MINIKUBE NODE (Host)            │
                            │   - Calico CNI                    │
                            │   - kubelet                       │
                            │   - container runtime (containerd)│
                            └────────────────┬─────────────────┘
                                             │
              ┌──────────────────────────────┼──────────────────────────────┐
              │                              │                              │
   ┌──────────▼──────────┐       ┌──────────▼──────────┐       ┌──────────▼──────────┐
   │  Namespace: prod    │       │  Namespace: dev     │       │  Namespace:         │
   │  (NetPol applied)   │       │  (no policies)      │       │  monitoring         │
   └──────────┬──────────┘       └─────────────────────┘       └──────────┬──────────┘
              │                                                            │
   ┌──────────▼─────────────────────────────────────────┐                  │
   │           Service: nginx-service (NodePort 30080)  │       ┌──────────▼──────────┐
   └──────────┬─────────────────────────────────────────┘       │  Prometheus (9090)  │
              │ proxy_pass                                       │  - scrapes all pods │
              ▼                                                  │  - 4 alert rules    │
   ┌──────────────────────┐                                      └──────────┬──────────┘
   │ Deployment: nginx    │ replicas=2                                      │
   │ - readinessProbe     │                                                 │
   │ - resource limits    │                                                 ▼
   └──────────┬───────────┘                                      ┌─────────────────────┐
              │ http://backend:8080                              │  Grafana (3000)     │
              ▼                                                  │  - Provisioned DS   │
   ┌──────────────────────┐                                      │  - 4-panel dash     │
   │ Service: backend     │                                      └─────────────────────┘
   └──────────┬───────────┘
              │
              ▼
   ┌──────────────────────┐
   │ Deployment: backend  │ replicas=2
   │ - readiness+liveness │
   │ - python-app-gsx:vX  │
   └──────────┬───────────┘
              │ redis://redis:6379
              ▼
   ┌──────────────────────┐
   │ Service: redis       │ (headless)
   └──────────┬───────────┘
              │
              ▼
   ┌──────────────────────┐
   │ StatefulSet: redis   │ replicas=1
   │ + PVC 1Gi (persists) │
   └──────────────────────┘
```

## 2. Data flow

1. **Usuari** -> `minikube ip:30080` -> Service `nginx-service` (round-robin entre les
   2 replicas de nginx)
2. **nginx pod** -> resol DNS intern `backend` -> Service `backend` -> selecciona un
   pod de backend disponible (segons readinessProbe)
3. **backend pod** -> resol `redis` -> Service redis (headless) -> el pod `redis-0`
4. **redis-0** llegeix/escriu al PVC `redis-data-redis-0` (1Gi, persisteix despres de delete)

## 3. Components

| Component       | Tipus            | Replicas | Imatge                        | Per que existeix?                       |
|-----------------|------------------|----------|-------------------------------|----------------------------------------|
| nginx           | Deployment       | 2        | nginx:alpine                  | Reverse proxy, load balancer            |
| backend         | Deployment       | 2        | paucabestany/python-app-gsx   | Logica d'aplicacio                       |
| redis           | StatefulSet      | 1        | redis:alpine                  | Persistencia d'estat                     |
| greendev-config | ConfigMap        | -        | -                             | Variables d'entorn no-secretes           |
| nginx-proxy-config | ConfigMap     | -        | -                             | nginx.conf parametrizat                  |
| Prometheus      | Deployment       | 1        | prom/prometheus:v2.51         | Metrics collection                       |
| Grafana         | Deployment       | 1        | grafana/grafana:10.4          | Dashboards + alerting visual             |

## 4. Networking

### 4.1 Pod-to-pod (intra-namespace)
Tots els pods del mateix namespace poden parlar entre si **excepte** quan hi ha una
NetworkPolicy aplicada (W12).

### 4.2 Cross-namespace
Permès nomes per la NetworkPolicy `isolate-production`: nomes pods amb label
`name: prod` poden entrar a `prod`. Tot el demés es bloqueja.

### 4.3 External access
Nomes via NodePort: 30080 (nginx), 30090 (prometheus), 30030 (grafana).

## 5. Storage

| PVC                  | Mida | StorageClass    | Reclaim |
|----------------------|------|-----------------|---------|
| redis-data-redis-0   | 1Gi  | standard (host) | Retain  |

## 6. CI/CD flow

```
   Developer push to main
            ↓
   GitHub Actions (ci.yml)
   ├─ Job 1: validate-terraform (fmt + validate)
   ├─ Job 2: build-and-scan (matrix per imatge)
   │   ├─ Build amb Buildx + cache
   │   ├─ Trivy scan (HIGH/CRITICAL -> Security tab)
   │   ├─ SBOM amb Syft -> artifact
   │   └─ Push a Docker Hub (sha + latest)
   └─ Job 3: summary
            ↓
   Developer local: terraform apply -var image_tag=$SHA
            ↓
   Minikube cluster updated (rolling update sense downtime)
```

## 7. Justificacio de decisions

- **Per que Terraform i no Ansible?** Idempotencia natural i `plan` abans d'`apply`.
- **Per que Calico i no Flannel?** Calico suporta NetworkPolicies (Flannel no).
- **Per que NodePort i no Ingress?** Simplicitat per a Minikube. En prod real, usariem
  un Ingress Controller (nginx-ingress) amb cert-manager.
- **Per que 2 replicas de nginx i backend?** Permet rolling updates sense downtime.
- **Per que StatefulSet per a Redis?** Identitat de pod estable + PVC propi per replica.
