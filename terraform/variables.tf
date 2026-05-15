###############################################################################
# Variables del modul Terraform
# Cada variable te un valor per defecte i descripcio.
# Es poden sobreescriure amb fitxers .tfvars (veure envs/)
###############################################################################

variable "kubeconfig_path" {
  description = "Ruta al fitxer kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Context de kubectl a usar (minikube per defecte)"
  type        = string
  default     = "minikube"
}

variable "environment" {
  description = "Nom de l'entorn (dev/staging/prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "L'entorn ha de ser un de: dev, staging, prod."
  }
}

variable "app_namespace" {
  description = "Namespace de Kubernetes per a l'aplicacio"
  type        = string
  default     = "greendev"
}

variable "welcome_message" {
  description = "Missatge de benvinguda mostrat pel backend"
  type        = string
  default     = "Hello from GreenDevCorp (managed by Terraform)"
}

variable "backend_port" {
  description = "Port intern del servei backend"
  type        = number
  default     = 8080
}

variable "backend_image" {
  description = "Imatge Docker del backend (sense tag)"
  type        = string
  default     = "paucabestany/python-app-gsx"
}

variable "image_tag" {
  description = "Tag de la imatge del backend (commit SHA del CI)"
  type        = string
  default     = "v2"
}

variable "backend_replicas" {
  description = "Nombre de replicas del backend"
  type        = number
  default     = 2
}

variable "nginx_replicas" {
  description = "Nombre de replicas de nginx"
  type        = number
  default     = 2
}

variable "nginx_node_port" {
  description = "NodePort per exposar nginx"
  type        = number
  default     = 30080
}

variable "redis_storage_size" {
  description = "Mida del PVC de Redis"
  type        = string
  default     = "1Gi"
}
