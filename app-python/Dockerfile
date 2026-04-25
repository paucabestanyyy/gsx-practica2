# 1. Base ultra-lleugera (Compleix el requisit de l'apartat 4.2)
FROM python:3.9-alpine

# 2. Creem un usuari sense privilegis per seguretat (Compleix apartat 4.3)
RUN adduser -D -u 1000 appuser

# 3. Definim on treballarem dins del contenidor
WORKDIR /app

# 4. Copiem el nostre codi cap a dins del contenidor
COPY app.py .

# 5. Donem permisos només a l'usuari segur perquè ningú més pugui tocar el fitxer
RUN chown -R appuser:appuser /app

# 6. A partir d'aquí, canviem la identitat (ja NO som root)
USER appuser

# 7. Obrim el port 8080 cap a l'exterior
EXPOSE 8080

# 8. Comanda final per engegar el servidor
CMD ["python", "app.py"]
