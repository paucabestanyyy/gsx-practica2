# Base image obligatòria segons l'enunciat
FROM nginx:latest

# Copiem la nostra web personalitzada a la carpeta on Nginx llegeix els arxius
COPY index.html /usr/share/nginx/html/index.html

# Exposem el port 80 (el port web per defecte)
EXPOSE 80
