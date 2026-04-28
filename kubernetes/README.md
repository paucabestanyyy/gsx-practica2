# Week 10 - Orchestration (Kubernetes)
**Autors:** Pau Cabestany i Eric Hernandez

## 1. Explicació dels Recursos de Kubernetes
* **Deployment:** Gestiona els Pods de la nostra aplicació (Nginx i Backend). S'encarrega d'assegurar que sempre hi hagi el nombre desitjat de rèpliques funcionant i permet actualitzacions sense temps de caiguda.
* **Service:** Actua com un balancejador de càrrega intern i un DNS. Com que els Pods canvien d'IP en reiniciar-se, el Service proporciona una adreça fixa perquè Nginx sempre trobi el Backend.
* **ConfigMap:** Separa la configuració del codi font. Ho fem servir per injectar el fitxer `default.conf` a Nginx i les variables d'entorn al nostre Backend de Python sense haver de reconstruir les imatges de Docker.

## 2. Comunicació i Xarxes
* **Interna:** Els Pods es comuniquen utilitzant el nom del Service (ex: `http://backend:8080`). El DNS intern de Kubernetes resol aquest nom cap als Pods actius.
* **Externa:** Els clients arriben al Nginx a través d'un servei tipus `NodePort` exposat al port `30080` de la màquina host (Minikube).

## 3. Advanced Features (Nivell ***)
* **Scaling:** Hem escalat manualment el Deployment de Nginx (`kubectl scale --replicas=3`). El ReplicaSet ha creat els nous pods de forma instantània.
* **Resiliència (Self-Healing):** En eliminar forçosament un Pod (`kubectl delete pod`), el Deployment Controller ho ha detectat i n'ha instanciat un de nou automàticament per mantenir l'estat desitjat.
* **Límits de Recursos i Probes:** Tots els contenidors tenen definits `requests` i `limits` de CPU/RAM per evitar col·lapses del node. A més, hem configurat `livenessProbes` per detectar si una aplicació es penja i necessita ser reiniciada.
* **Persistència de Dades:** Hem desplegat Redis com un `StatefulSet` associat a un `PersistentVolumeClaim` d'1GB. Això garanteix que, encara que el pod de la base de dades es destrueixi, les dades sobreviuran en un disc independent i es tornaran a muntar quan el pod ressusciti.
