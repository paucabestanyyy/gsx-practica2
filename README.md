# GSX - Practica 2: Organizational IT Infrastructure
**Alumnes:** Pau Cabestany i Eric Hernandez
**Assignatura:** Gestio de Sistemes i Xarxes (GSX)
**Curs:** 2025-2026 · **Deadline:** 15 Maig 2026

## Overview
Aquest repositori conte la transformacio digital de **GreenDevCorp** des d'un sol servidor
amb deployments manuals fins a una infraestructura moderna amb contenidors, orquestracio,
IaC, CI/CD, segmentacio de xarxa i observability.

## Quick Start

```bash
# 1. Clone
git clone https://github.com/paucabestanyyy/gsx-practica2.git
cd gsx-practica2

# 2. Desplegament complet (Disaster Recovery / Integration Test)
./disaster-recovery.sh

# 3. Acces:
minikube service nginx-service -n greendev-dev   # Frontend
minikube service grafana -n monitoring           # Dashboards (admin/changeme)
minikube service prometheus -n monitoring        # Metriques
```

## Estructura del repositori

```
gsx-practica2/
├── README.md                    # Aquest fitxer
├── RUNBOOK.md                   # Guia operativa
├── disaster-recovery.sh         # Integration test (W13 Challenge B)
│
├── app-nginx/                   # W8 - Dockerfile Nginx (multistage, alpine)
│   ├── Dockerfile
│   ├── .dockerignore
│   └── index.html
│
├── app-python/                  # W8 - Dockerfile Python (non-root, alpine)
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── app.py                   # HTTP server + /health endpoint
│   └── README.md
│
├── docker-compose/              # W9 - Stack multi-container
│   ├── docker-compose.yml       # nginx + python + redis amb networks custom
│   ├── .env.example
│   ├── .gitignore
│   ├── backend/
│   ├── nginx/
│   └── README.md
│
├── kubernetes/                  # W10 - Manifests K8s base (referencia)
│   ├── 01-configmap.yaml
│   ├── 02-redis.yaml            # StatefulSet + PVC
│   ├── 03-backend.yaml          # Deployment + Service + probes + securityContext
│   ├── 04-nginx.yaml
│   └── README.md
│
├── terraform/                   # W11 - Infrastructure as Code ⭐
│   ├── main.tf                  # Tots els recursos K8s
│   ├── variables.tf
│   ├── outputs.tf
│   ├── envs/
│   │   ├── dev.tfvars           # Multi-env (Intermediate)
│   │   ├── staging.tfvars
│   │   └── prod.tfvars
│   └── README.md
│
├── .github/workflows/           # W11 - CI/CD pipeline ⭐
│   └── ci.yml                   # Build + Trivy scan + SBOM + cache + Terraform validate
│
├── week12/                      # W12 - Network design & Identity
│   ├── 01-environments.yaml     # Namespaces dev/prod
│   ├── 02-network-policy.yaml   # Aïllament
│   ├── test-seguretat.sh        # Audit automatitzat
│   └── README.md                # CIDR + DNS/DHCP/NTP + LDAP/AD/SSO + identity strategy
│
├── observability/               # W13 - Prometheus + Grafana ⭐
│   ├── 01-prometheus.yaml       # + 4 alert rules
│   ├── 02-grafana.yaml          # + dashboard precarregat
│   └── README.md
│
└── docs/                        # W13 - Documentacio
    ├── ARCHITECTURE.md          # Diagrama complet + data flows
    ├── TROUBLESHOOTING.md       # 10 problemes comuns documentats
    └── REFLECTION_PauCabestany.md  # Reflection essay (870 paraules)
```

## Setmana per setmana

| Setmana | Tema                          | Directori                  | Nivell assolit |
|---------|-------------------------------|----------------------------|----------------|
| W8      | Containerization (Docker)     | `app-nginx/`, `app-python/` | Advanced ***   |
| W9      | Multi-container (Compose)     | `docker-compose/`          | Advanced ***   |
| W10     | Orchestration (Kubernetes)    | `kubernetes/`              | Advanced ***   |
| W11     | IaC + CI/CD                   | `terraform/`, `.github/`   | Advanced ***   |
| W12     | Network Design + Identity     | `week12/`                  | Advanced ***   |
| W13     | Observability + Integration   | `observability/`, `docs/`  | Advanced ***   |

## Tecnologies usades

- **Containers:** Docker (Buildx), Docker Compose
- **Orchestration:** Kubernetes (Minikube)
- **CNI:** Calico (per NetworkPolicies)
- **IaC:** Terraform (`hashicorp/kubernetes` provider)
- **CI/CD:** GitHub Actions
- **Security:** Trivy (image scanning), SBOM amb Syft
- **Observability:** Prometheus + Grafana
- **Registry:** Docker Hub (`paucabestany/`)

## Documentacio detallada

| Vols saber...                          | Llegeix...                                     |
|----------------------------------------|------------------------------------------------|
| Com esta dissenyat el sistema?         | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| Com el faig anar dia a dia?            | [`RUNBOOK.md`](RUNBOOK.md)                     |
| Algo va malament, que faig?            | [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) |
| Per que vam triar Terraform?           | [`terraform/README.md`](terraform/README.md)   |
| Per que les NetworkPolicies funcionen? | [`week12/README.md`](week12/README.md)         |
| Que es i com us. l'observability?      | [`observability/README.md`](observability/README.md) |
| Que he aprés (Pau)?                    | [`docs/REFLECTION_PauCabestany.md`](docs/REFLECTION_PauCabestany.md) |

## Status

✅ **Completat al nivell Advanced (***) en les 6 setmanes**.

Per a l'entrevista oral (W14-15), ambdos membres del grup estem preparats per defensar
totes les decisions arquitectoniques i fer demos en viu de cada component.
