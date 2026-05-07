# 📖 GreenDevCorp - Operational Runbook & Architecture

## 1. Architecture Diagram
Aquest és el flux de dades de la nostra infraestructura:
* **Usuari/Internet** ➔ `Nginx (Proxy/Load Balancer)` [Port 80/30080]
* `Nginx` ➔ `Backend (Python App)` [Port 8080]
* `Backend` ➔ `Redis (Stateful Database)` [Port 6379]

## 2. Component Documentation
* **Nginx (Frontend):** Rep les peticions externes i fa d'intermediari. Llegeix la configuració d'un `ConfigMap`.
* **Backend (Python):** La lògica de l'aplicació. Desplegada amb una imatge personalitzada (`v2`), llegeix variables d'entorn i es connecta a la base de dades.
* **Redis (Database):** Emmagatzematge d'estat desplegat com a `StatefulSet` amb un `PersistentVolume` d'1GB. Si el pod mor, les dades sobreviuen.
* **Network Policies (Calico):** Tallafocs intern que divideix el clúster en `dev` i `prod`, bloquejant qualsevol tràfic no autoritzat cap a la base de dades de producció.

## 3. Operational Guide (Com gestionar el sistema)
* **Com desplegar de zero (Disaster Recovery):** Executar l'script `./disaster-recovery.sh`.
* **Com escalar el frontend si hi ha molt tràfic:** `kubectl scale deployment nginx --replicas=3`
* **Com actualitzar una versió de codi sense caigudes (Rolling Update):** Canviar la versió de la imatge al YAML i fer `kubectl apply -f .`

## 4. Troubleshooting Guide (Solució de problemes)
* **Problema:** "Un servei no pot parlar amb un altre"
  * *Diagnòstic:* Revisar si la *NetworkPolicy* està bloquejant el tràfic o si els *Selectors* del Service estan mal escrits. Comprovar la IP amb `kubectl get endpoints`.
* **Problema:** "Un pod està en estat *CrashLoopBackOff*"
  * *Diagnòstic:* L'aplicació a dins del contenidor està fallant. Mirar els errors amb `kubectl logs <nom-del-pod>`.
* **Problema:** "Un pod està en estat *ImagePullBackOff* o es queda en *Pending* massa temps"
  * *Diagnòstic:* Inspeccionar els esdeveniments amb `kubectl describe pod <nom-del-pod>`. Sol ser un problema de falta de RAM, connexió lenta a Internet, o un error en el nom de la imatge a Docker Hub.
