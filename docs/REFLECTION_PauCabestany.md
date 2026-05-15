# Reflection Essay - Practica 2 GSX
**Autor:** Pau Cabestany
**Data:** Maig 2026

## Aspecte mes desafiant

Si he de triar una sola cosa que m'ha fet patir durant aquestes sis setmanes, ha estat
**comprendre quan utilitzar cada eina**. La diferencia entre Docker, Docker Compose i
Kubernetes a primera vista sembla una qüestio de "mes potencia, millor", pero a mesura que
he anat construint el projecte m'he adonat que escollir K8s per a una aplicacio que cabria
perfectament en un docker-compose es como matar mosques amb una bazooka. La complexitat
operativa que afegeix Kubernetes (els 7 manifests YAML que necessites per desplegar dues
aplicacions, els Services, els ConfigMaps, els probes...) nomes te sentit quan tens un
volum de trafic, requeriments de disponibilitat o necessitats de scaling que justifiquen
aquest cost.

L'altre repte gros ha estat la **gestio de la xarxa**. Entendre que dins de Kubernetes hi
ha tres capes de IPs diferents (nodes, pods, services) i que cada Service crea automaticament
una entrada de DNS interna era contraintuitiu. Quan vaig configurar la NetworkPolicy per
prohibir l'acces de `dev-hacker` cap a `prod-db` i va funcionar a la primera (gracies a
Calico), va ser una de les sensacions mes satisfactories del projecte.

## Que m'ha sorprès de la infraestructura moderna

Tres coses:

1. **El cost real esta en la complexitat, no en el hardware**. Una decada enrere, aixecar
   "una infra" volia dir comprar servidors. Avui, amb 30 minuts d'aprenentatge tens un
   cluster a Minikube. Pero saber-lo gestionar, monitoritzar, fer-lo segur i mantenir-lo
   actualitzat - aquest es el veritable cost. No el hardware.

2. **Tot s'expressa com a codi**. Que un fitxer YAML de 50 linies pugui descriure una
   aplicacio complerta, amb les seves replicas, healthchecks, configuracions, networking
   i persistencia... no m'imaginava que aixo fos possible. La transicio a Terraform per
   substituir aquests YAMLs per HCL parametritzat ha estat un descobriment.

3. **El nivell de detall de l'ecosistema cloud-native**. Hi ha eines per a literalment
   qualsevol cosa: Prometheus per metriques, Grafana per dashboards, Trivy per security
   scanning, Cosign per signar imatges, OPA per policies, Falco per runtime security...
   Es un univers que continua creixent.

## Que faria diferent si comences de nou

Tres lliçons:

- **Començar abans amb la documentacio.** Les primeres setmanes vaig escriure el codi
  primer i la documentacio al final. Cada vegada que tornava al README a explicar quelcom,
  ja no recordava per qué havia pres una decisio. La proxima vegada escriuria el README
  i la justificacio ABANS d'escriure el codi.

- **Crear el CI/CD a la W8.** Vaig retardar la Setmana 11 fins al final pensant "ja muntare
  el pipeline despres". Error. Si haguessim tingut GitHub Actions des del W8 fent build
  automatic, hauria estat trivial mantenir actualitzades les imatges a Docker Hub. En
  comptes, vaig haver de fer `docker build && docker push` manualment moltes vegades.

- **Invertir mes temps en Networking.** Em va costar mig dia entendre per qué Nginx no
  podia trobar `backend:8080` la primera vegada. Si hagues estudiat com funciona el
  DNS intern de K8s primer, m'hauria estalviat aquest temps.

## Com ha canviat la meva visio de DevOps i sistemes cloud-native

Abans pensava que "DevOps" era simplement un developer que tambe sap fer deploy. Ara
veig que es una **filosofia**: tot ha de ser reproduible, automatitzat, observable i
versionat. No es un job title, es una manera de treballar.

Cloud-native em sonava a "tot al nuvol" (AWS, GCP, Azure). Pero ara entenc que es una
arquitectura: aplicacions stateless, dades a serveis especialitzats, escalat horitzontal,
recuperacio automatica davant fallades. El cloud nomes facilita aquesta arquitectura,
no la defineix.

Tambe he aprés que **les bones practiques no son un luxe, son una necessitat**. Cada cop
que he saltat un pas (no posar resource limits, no fer healthchecks, no escanejar imatges
per vulnerabilitats), el sistema ha donat problemes mes tard. Cada control aparentment
"opcional" estalvia hores de debugging despres.

## Que vull aprendre mes endavant

Tres temes que m'agradaria explorar despres d'aquest projecte:

- **GitOps** amb ArgoCD o FluxCD: la idea que el cluster s'auto-reconcili amb el que diu
  Git em sembla la culminacio natural d'IaC.
- **Service Mesh** (Istio, Linkerd): observabilitat, encriptacio i traffic management
  com a capa transversal sembla potent pero complex.
- **eBPF** i seguretat avancada de runtime: Cilium, Falco. Veure que passa dins del kernel
  en temps real.

I sobretot, vull continuar **construint coses** en lloc de nomes llegir-ne. La diferencia
entre saber Docker per haver vist tutorials i saber Docker per haver desplegat 5 aplicacions
diferents amb les seves peculiaritats es brutal.

## Conclusio

Aquesta practica m'ha demostrat que la infraestructura moderna no es magia: son moltes
peces senzilles ben combinades. La complexitat percebuda ve de la quantitat de capes,
no del que fa cada capa. Si entenc cada peca per separat (que es un contenidor, com
funciona DNS, qué es un pod), entendre el conjunt es nomes una qüestio de practica.

Crec que sortejo de la practica amb una bona base de fluencia (no mestria, com diu
l'enunciat) sobre tot l'stack: Docker, Compose, Kubernetes, Terraform, GitHub Actions,
NetworkPolicies, Prometheus i Grafana. I, sobretot, amb la capacitat d'explicar per qué
cada eina existeix i quan utilitzar-la.

Es l'objectiu que es marcava l'enunciat. Crec que l'hem assolit.

---
**Comptador de paraules:** ~830 paraules
