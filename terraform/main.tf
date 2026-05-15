###############################################################################
# GreenDevCorp - Infrastructure as Code (Terraform)
# Week 11 - GSX Practica 2
#
# Aquest fitxer defineix tota la infraestructura de Kubernetes de manera
# declarativa, substituint la majoria de manifests YAML escrits a ma.
#
# Comandes principals:
#   terraform init     -> Inicialitza els providers
#   terraform plan     -> Mostra els canvis que es faran
#   terraform apply    -> Aplica els canvis
#   terraform destroy  -> Elimina tota la infraestructura
###############################################################################

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# Provider: connecta amb el cluster Minikube usant el context per defecte (~/.kube/config)
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

###############################################################################
# 1. NAMESPACE PRINCIPAL DE L'APLICACIO
###############################################################################
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_namespace
    labels = {
      name        = var.app_namespace
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

###############################################################################
# 2. CONFIGMAP - Variables d'entorn per al backend
###############################################################################
resource "kubernetes_config_map" "greendev_config" {
  metadata {
    name      = "greendev-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    WELCOME_MESSAGE = var.welcome_message
    BACKEND_PORT    = tostring(var.backend_port)
    ENVIRONMENT     = var.environment
  }
}

###############################################################################
# 3. REDIS - StatefulSet + PVC + Service
###############################################################################
resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = { app = "redis" }
    port {
      port        = 6379
      target_port = 6379
    }
    cluster_ip = "None" # Headless service per StatefulSet
  }
}

resource "kubernetes_stateful_set" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    service_name = "redis"
    replicas     = 1

    selector {
      match_labels = { app = "redis" }
    }

    template {
      metadata {
        labels = { app = "redis" }
      }

      spec {
        container {
          name  = "redis"
          image = "redis:alpine"

          port {
            container_port = 6379
          }

          resources {
            requests = { memory = "64Mi", cpu = "100m" }
            limits   = { memory = "128Mi", cpu = "250m" }
          }

          liveness_probe {
            tcp_socket { port = 6379 }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          volume_mount {
            name       = "redis-data"
            mount_path = "/data"
          }
        }
      }
    }

    volume_claim_template {
      metadata { name = "redis-data" }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = { storage = var.redis_storage_size }
        }
      }
    }
  }
}

###############################################################################
# 4. BACKEND - Deployment + Service
###############################################################################
resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = { app = "backend" }
    port {
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = var.backend_replicas

    selector {
      match_labels = { app = "backend" }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    template {
      metadata {
        labels = { app = "backend" }
      }

      spec {
        container {
          name  = "backend"
          # La imatge ve del CI/CD - es passa com a variable (commit SHA tag)
          image = "${var.backend_image}:${var.image_tag}"

          port {
            container_port = 8080
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.greendev_config.metadata[0].name
            }
          }

          resources {
            requests = { memory = "128Mi", cpu = "250m" }
            limits   = { memory = "256Mi", cpu = "500m" }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

###############################################################################
# 5. NGINX - ConfigMap + Deployment + Service (NodePort)
###############################################################################
resource "kubernetes_config_map" "nginx_proxy" {
  metadata {
    name      = "nginx-proxy-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    "default.conf" = <<-EOT
      server {
          listen 80;
          location / {
              proxy_pass http://backend:8080;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
          }
          location /health {
              access_log off;
              return 200 "healthy\n";
          }
      }
    EOT
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    type     = "NodePort"
    selector = { app = "nginx" }
    port {
      port        = 80
      target_port = 80
      node_port   = var.nginx_node_port
    }
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = var.nginx_replicas

    selector {
      match_labels = { app = "nginx" }
    }

    template {
      metadata {
        labels = { app = "nginx" }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:alpine"

          port {
            container_port = 80
          }

          resources {
            requests = { memory = "64Mi", cpu = "100m" }
            limits   = { memory = "128Mi", cpu = "250m" }
          }

          liveness_probe {
            tcp_socket { port = 80 }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }

          volume_mount {
            name       = "nginx-conf"
            mount_path = "/etc/nginx/conf.d/default.conf"
            sub_path   = "default.conf"
          }
        }

        volume {
          name = "nginx-conf"
          config_map {
            name = kubernetes_config_map.nginx_proxy.metadata[0].name
          }
        }
      }
    }
  }
}
