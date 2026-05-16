# Troubleshooting Guide
**Projecte:** GreenDevCorp - Practica 2 GSX

Guia per a diagnosticar problemes comuns. Per a cada problema: simptoma observable,
causa habitual, comandes de diagnostic, i com arreglar-ho.

## 1. ImagePullBackOff / ErrImagePull

**Simptoma:**
```
NAME           READY   STATUS             RESTARTS   AGE
backend-xyz    0/1     ImagePullBackOff   0          2m
```

**Causes habituals:**
- Nom de la imatge mal escrit
- Imatge no existeix al registry
- Registry privat sense credencials (imagePullSecrets)
- Tag inexistent

**Diagnostic:**
```bash
kubectl describe pod backend-xyz | grep -A5 "Events"
# Et dira exactament que ha passat (ex: "manifest unknown")

# Comprovar si la imatge existeix:
docker pull paucabestany/python-app-gsx:v2
```

**Solucio:** Verificar el camp `image:` al manifest o Terraform variable `image_tag`.

---

## 2. CrashLoopBackOff

**Simptoma:** El pod arrenca, falla, es reinicia, falla... en bucle.

**Diagnostic:**
```bash
# Veure logs del contenidor crashed:
kubectl logs backend-xyz --previous

# Veure events:
kubectl describe pod backend-xyz | tail -20
```

**Causes habituals:**
- Error de codi a l'aplicacio (panic, exception no controlada)
- Falten variables d'entorn requerides
- No pot connectar a una dependencia (DB, redis)
- LivenessProbe fallant per delay massa baix

**Solucio:** Inspeccionar els logs, corregir el codi o ajustar `initialDelaySeconds`.

---

## 3. Service no troba els pods (endpoints buit)

**Simptoma:** `curl http://backend:8080` retorna "connection refused" o timeout, pero
els pods estan Running.

**Diagnostic:**
```bash
kubectl get endpoints backend
# NAME      ENDPOINTS                  AGE
# backend   <none>                     5m   <-- problema!
```

**Causa:** Els labels del selector del Service no coincideixen amb els labels dels pods.

**Solucio:**
```bash
# Comprovar labels dels pods:
kubectl get pods --show-labels

# Comparar amb el selector del Service:
kubectl get svc backend -o yaml | grep -A2 selector
```

Han de coincidir EXACTAMENT (case-sensitive).

---

## 4. Pod en Pending massa temps

**Diagnostic:**
```bash
kubectl describe pod backend-xyz | grep -A10 Events
```

**Causes:**
- **Insufficient memory/cpu:** El node no te recursos. Ajustar `resources.requests` o
  afegir mes nodes.
- **No nodes match selector:** Si has posat un `nodeSelector`, comprova que algun node
  el compleix.
- **PVC pending:** Si fa servir storage, el PVC no s'ha pogut crear. Veure
  `kubectl get pvc`.
- **CNI no arrencat:** A Minikube, si Calico no esta llest, els pods queden Pending.

**Solucio per a Calico:** `kubectl get pods -n kube-system | grep calico`. Si no esta
Running, esperar o reinstal·lar amb `minikube delete && minikube start --cni=calico`.

---

## 5. Connexio bloquejada per NetworkPolicy

**Simptoma:** Un pod no pot parlar amb un altre tot i estar al mateix cluster.

**Diagnostic:**
```bash
# Llistar polítiques actives:
kubectl get networkpolicies --all-namespaces

# Test concret:
kubectl exec -it test-pod -- curl --max-time 3 backend:8080
```

**Solucio:** Revisar les `podSelector`/`namespaceSelector`. Recordar que les
NetworkPolicies son "default-deny once applied": si afegeixes una policy, tot el que no
estigui explicitament permès es bloqueja.

---

## 6. Dashboard de Grafana mostra "No data"

**Diagnostic:**
```bash
# 1. Veure si Prometheus esta scrapejant be:
minikube service prometheus -n monitoring
# Anar a http://<ip>:30090/targets -> tots HEALTHY?

# 2. Veure si l'app exposa /metrics:
kubectl exec -it backend-xyz -- curl localhost:8080/metrics

# 3. Veure si te les anotacions correctes:
kubectl get pod backend-xyz -o yaml | grep -A3 annotations
```

**Solucio:** Afegir les anotacions al template del Deployment:
```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
```

---

## 7. Terraform apply falla amb "context not found"

**Simptoma:**
```
Error: cluster_addons: context "minikube" not found
```

**Causes:**
- Minikube no esta arrencat
- El context de kubectl es un altre

**Solucio:**
```bash
minikube start --cni=calico
kubectl config use-context minikube
kubectl cluster-info     # confirmar
terraform apply -var-file=envs/dev.tfvars
```

---

## 8. CI pipeline falla a Trivy scan

**Simptoma:** El job `build-and-scan` falla al pas de Trivy amb "found HIGH/CRITICAL vulns".

**Solucio:**
1. Mirar el report al GitHub Security tab (es puja com a SARIF).
2. Si la vulnerabilitat es a la imatge base (alpine/python), actualitzar a una versio
   mes nova al Dockerfile.
3. Si es a una llibreria del codi, actualitzar requirements.txt.
4. Com a workaround temporal, posar `exit-code: '0'` al pas de Trivy (no recomanat per
   prod).

---

## 9. Disaster recovery falla a mig camí

**Simptoma:** El script `disaster-recovery.sh` deixa el cluster en estat inconsistent.

**Solucio:**
```bash
# Reset complert:
minikube delete
minikube start --cni=calico

# Tornar a aplicar tot via Terraform:
cd terraform/
terraform init
terraform apply -var-file=envs/dev.tfvars -auto-approve
```

---

## 10. Como saber si un pod te problemes de memoria

```bash
# Top dels pods:
kubectl top pods --all-namespaces

# Veure events de OOMKilled:
kubectl get events --field-selector reason=OOMKilling
```

Si veus OOMKilled, augmentar `resources.limits.memory` al manifest.

---

## 11. Docker no pot accedir a registry.k8s.io

**Simptoma:** A `minikube start`, error `Failing to connect to https://registry.k8s.io/`.

**Diagnostic:**
```bash
docker run --rm busybox nslookup registry.k8s.io
# Si no resol -> DNS de Docker mal configurat
```

**Solucio:**
```bash
sudo bash -c 'cat > /etc/docker/daemon.json << JSON
{
  "dns": ["8.8.8.8", "1.1.1.1"],
  "dns-opts": ["ndots:0"]
}
JSON'
sudo systemctl restart docker
```

## 12. Calico no s'inicialitza correctament

**Simptoma:** Pods queden en `ContainerCreating` amb error
`failed to set up sandbox container: plugin type="calico" failed (add): stat /var/lib/calico/nodename: no such file or directory`

**Causa:** Quan Minikube va arrencar la primera vegada, el DNS de Docker estava trencat
i els pods de Calico no van poder descarregar les seves imatges.

**Solucio:** Reiniciar minikube despres d'arreglar el DNS de Docker:
```bash
minikube delete
minikube start --cni=calico --memory=2048 --cpus=2
```

**Alternativa si la VM no te recursos per Calico (<3GB RAM):** Usar el CNI per defecte:
```bash
minikube start --memory=2048 --cpus=2 --kubernetes-version=v1.30.0
```
Les NetworkPolicies igualment es creen pero amb funcionalitat limitada.

## 13. Minikube s'atura sol (out of memory / out of disk)

**Simptoma:** `kubectl` retorna `connection refused` despres d'haver funcionat.

**Diagnostic:**
```bash
docker ps -a | grep minikube       # Veure si el container esta aturat
df -h /                            # Veure espai en disc
free -h                            # Veure RAM
```

**Solucions:**
- Reiniciar: `minikube start` (sense delete, conserva l'estat)
- Si disc ple: `docker system prune -af --volumes` + revisar /home/<user> per fitxers grans
- Si RAM baixa: crear swap (`sudo fallocate -l 2G /swapfile; sudo mkswap /swapfile; sudo swapon /swapfile`)

## 14. Terraform timeout esperant rollout (pero els pods funcionen)

**Simptoma:** `Error: StatefulSet greendev-dev/redis is not finished rolling out`
pero `kubectl get pods` mostra `Running 1/1`.

**Causa:** En VMs amb connexio lenta, descarregar les imatges triga mes de 10 min
i Terraform fa timeout encara que el cluster acabi desplegant-ho be.

**Solucio:** Sincronitzar Terraform amb la realitat:
```bash
cd terraform/
terraform refresh -var-file=envs/dev.tfvars
terraform output
```

## 15. Test seguretat W12 - "container not found"

**Simptoma:** `error: Internal error occurred: unable to upgrade connection: container not found ("terminal")`

**Causa:** Els pods `dev-hacker` i `prod-worker` encara estaven en `ContainerCreating`
quan el script ha intentat executar `kubectl exec`.

**Solucio:** Esperar a que tots els pods estiguin Running:
```bash
kubectl wait --for=condition=ready pods --all -n dev --timeout=120s
kubectl wait --for=condition=ready pods --all -n prod --timeout=120s
./week12/test-seguretat.sh
```
