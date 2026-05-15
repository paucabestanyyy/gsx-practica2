# Week 11 - Infrastructure as Code (Terraform)
**Autors:** Pau Cabestany i Eric Hernandez

## 1. Per que Terraform i no Ansible?
Hem escollit **Terraform** (declaratiu) en lloc d'Ansible (procedimental) per dos motius principals:

1. **Idempotencia natural**: Terraform compara l'estat desitjat amb l'estat real i nomes aplica
   els canvis necessaris. No cal escriure logica condicional.
2. **`terraform plan`**: Abans de qualsevol `apply` veiem exactament que canviara. Aixo redueix
   l'error huma a zero.

> Mantenim els manifests YAML originals a `kubernetes/` com a referencia, pero la font de
> veritat en CI/CD es el codi Terraform d'aquest directori.

## 2. Estructura del modul

```
terraform/
├── main.tf          # Definicio de tots els recursos (NS, Deployments, SS, Services, ConfigMaps)
├── variables.tf     # Variables parametritzables (replicas, ports, imatges, etc.)
├── outputs.tf       # Informacio mostrada despres del desplegament
└── envs/
    ├── dev.tfvars       # Valors per a entorn de desenvolupament
    ├── staging.tfvars   # Valors per a staging
    └── prod.tfvars      # Valors per a produccio
```

## 3. Com desplegar (CD local a Minikube)

```bash
# 0. Arrencar Minikube amb Calico (per a NetworkPolicies de la W12)
minikube start --cni=calico

# 1. Inicialitzar Terraform (descarrega el provider de Kubernetes)
cd terraform/
terraform init

# 2. Veure que es creara (DEV)
terraform plan -var-file=envs/dev.tfvars

# 3. Aplicar a DEV
terraform apply -var-file=envs/dev.tfvars -auto-approve

# 4. Aplicar a STAGING (entorn separat, mateix codi)
terraform apply -var-file=envs/staging.tfvars -auto-approve

# 5. Desplegar una versio especifica produida pel CI (commit SHA)
terraform apply -var-file=envs/prod.tfvars -var="image_tag=abc1234"

# 6. Destruir-ho tot (rollback total)
terraform destroy -var-file=envs/dev.tfvars -auto-approve
```

## 4. Multi-entorn (Intermediate **)
Cada fitxer `.tfvars` defineix valors diferents:

| Variable           | dev       | staging   | prod      |
|--------------------|-----------|-----------|-----------|
| backend_replicas   | 1         | 2         | 3         |
| nginx_replicas     | 1         | 2         | 2         |
| nginx_node_port    | 30080     | 30081     | 30082     |
| redis_storage_size | 512Mi     | 1Gi       | 2Gi       |
| namespace          | greendev-dev | greendev-staging | greendev-prod |

**Politica**: nomes promocionem a `prod` un `image_tag` que ja s'hagi validat a `staging`.

## 5. Estrategia d'image tags (lligada al CI)
- El CI construeix la imatge i la tagueja amb `${GITHUB_SHA::8}` (els primers 8 caracters del SHA).
- A mes, fa un `latest` per al branca main (referencia comoda en dev).
- Per desplegar una versio concreta:
  `terraform apply -var-file=envs/prod.tfvars -var="image_tag=a1b2c3d4"`

## 6. Rollback (Advanced ***)
Tres opcions de rollback documentades:

1. **Via Terraform** (recomanat): tornar a fer apply amb el SHA anterior.
   ```bash
   terraform apply -var-file=envs/prod.tfvars -var="image_tag=<sha-previ>"
   ```

2. **Via kubectl** (per a emergencies):
   ```bash
   kubectl rollout undo deployment/backend -n greendev-prod
   ```

3. **Disaster recovery total**: `terraform destroy` + `terraform apply` amb tag estable.

## 7. Variables i outputs
Tota la configuracio es parametritza a `variables.tf`. Despres d'un apply veuras:
- Quin namespace s'ha creat
- Quina imatge esta corrent
- La comanda exacta per obrir el frontend
