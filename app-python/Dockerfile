###############################################################################
# Python App Dockerfile - GreenDevCorp W8 (Advanced ***)
# - Multistage: build amb dependencies + runtime minim
# - Base: python:3.12-alpine (lleugera, ~50MB)
# - Non-root user (UID 1000)
# - Read-only filesystem compatible
# - HEALTHCHECK integrat
###############################################################################

# ---------- STAGE 1: Builder (per si calen dependencies amb pip) ----------
FROM python:3.12-alpine AS builder
WORKDIR /build
COPY app.py ./
# Si en algun moment afegim un requirements.txt:
#   COPY requirements.txt ./
#   RUN pip install --user --no-cache-dir -r requirements.txt

# ---------- STAGE 2: Runtime ----------
FROM python:3.12-alpine

LABEL org.opencontainers.image.title="python-app-gsx" \
      org.opencontainers.image.description="GreenDevCorp simple Python HTTP server (W8)" \
      org.opencontainers.image.authors="paucabestany"

# Usuari sense privilegis
RUN adduser -D -u 1000 -h /home/appuser appuser

WORKDIR /app
COPY --from=builder /build/app.py ./
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

# Healthcheck (necessita un endpoint /health a l'app)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["python", "-u", "app.py"]
