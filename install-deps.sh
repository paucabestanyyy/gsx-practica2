#!/bin/bash
###############################################################################
# Instal.lador de dependencies per a Debian (W11/W13 - GSX Practica 2)
# Ja instal.lats es donen per fets: docker, minikube, kubectl
###############################################################################
set -e

echo "[1/3] Eines basiques..."
sudo apt-get update
sudo apt-get install -y wget unzip gnupg2 curl

echo "[2/3] Terraform (binari oficial)..."
TERRAFORM_VERSION="1.9.8"
cd /tmp
wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo install terraform /usr/local/bin/
rm terraform terraform_${TERRAFORM_VERSION}_linux_amd64.zip

echo "[3/3] Configurar DNS de Docker per a accessibilitat a registry.k8s.io..."
if [ ! -f /etc/docker/daemon.json ] || ! grep -q "8.8.8.8" /etc/docker/daemon.json; then
    sudo bash -c 'cat > /etc/docker/daemon.json << JSON
{
  "dns": ["8.8.8.8", "1.1.1.1"],
  "dns-opts": ["ndots:0"]
}
JSON'
    sudo systemctl restart docker
    echo "    DNS de Docker configurat"
fi

echo ""
echo "==========================================="
echo "Dependencies instal.lades:"
echo "==========================================="
terraform version
docker --version
minikube version | head -1
kubectl version --client 2>/dev/null | head -1
echo "==========================================="
