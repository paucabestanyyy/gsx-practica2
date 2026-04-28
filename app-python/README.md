# Week 8 - Docker Containers (GreenDevCorp)
**Autors:** Pau Cabestany i company/a

## 1. Aplicació Python (Advanced Level)
* **Base Image:** `python:3.9-alpine`. Hem escollit Alpine perquè és extremadament lleugera (només uns 5MB en lloc de gairebé 1GB de la versió Ubuntu), la qual cosa redueix el temps de descàrrega i la superfície d'atac.
* **Dependencies:** Només requereix les llibreries estàndard de Python (`http.server`), sense dependències externes.
* **Security Hardening:** Hem creat un usuari `appuser` sense privilegis (non-root) per executar el procés. Així complim amb el principi de mínim privilegi.
* **Build & Run:** - `docker build -t paucabestany/python-app-gsx:v1 .`
  - `docker run -d -p 8080:8080 paucabestany/python-app-gsx:v1`

## 2. Servidor Nginx Web
* **Base Image:** `nginx:latest` (tal com demanava l'enunciat base).
* **Dependencies:** Cap dependència externa, només el nostre fitxer HTML personalitzat de la Pràctica 1 (`index.html`).
* **Build & Run:**
  - `docker build -t paucabestany/nginx-gsx:v1 .`
  - `docker run -d -p 80:80 paucabestany/nginx-gsx:v1`
