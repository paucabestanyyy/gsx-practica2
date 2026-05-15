###############################################################################
# Nginx Dockerfile - GreenDevCorp W8
# - Base: nginx:alpine (5x mes petit que nginx:latest)
# - Non-root: ja inclos a la imatge oficial alpine
# - Multistage: prepara els assets en una stage separada
###############################################################################

# ---------- STAGE 1: Build (prepara els assets) ----------
FROM alpine:3.19 AS builder
WORKDIR /assets
COPY index.html ./
# Aqui es podrien minificar HTML/CSS si calgues. Mantenim simple.

# ---------- STAGE 2: Runtime ----------
FROM nginx:1.27-alpine

# Etiquetes OCI per identificar la imatge
LABEL org.opencontainers.image.title="nginx-gsx" \
      org.opencontainers.image.description="GreenDevCorp Nginx server (W8)" \
      org.opencontainers.image.authors="paucabestany"

# Copiar nomes el resultat de la stage anterior
COPY --from=builder /assets/index.html /usr/share/nginx/html/index.html

# Healthcheck integrat
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

EXPOSE 80

# La imatge oficial nginx-alpine ja s'executa amb usuari nginx (uid 101) si es configura.
# Aqui dropejem capabilities perilloses al moment del run (al docker-compose i K8s).
