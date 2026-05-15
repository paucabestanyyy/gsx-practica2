###############################################################################
# Outputs - informacio util mostrada despres del 'terraform apply'
###############################################################################

output "namespace" {
  description = "Namespace on s'ha desplegat l'aplicacio"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "environment" {
  description = "Entorn actiu"
  value       = var.environment
}

output "backend_image_used" {
  description = "Imatge del backend actualment desplegada"
  value       = "${var.backend_image}:${var.image_tag}"
}

output "nginx_access_command" {
  description = "Comanda per obrir el frontend al navegador"
  value       = "minikube service nginx-service -n ${var.app_namespace}"
}

output "next_steps" {
  description = "Que fer despres del desplegament"
  value       = <<-EOT

    ==========================================================
    DESPLEGAMENT COMPLETAT
    ==========================================================
    Entorn: ${var.environment}
    Namespace: ${var.app_namespace}
    Imatge backend: ${var.backend_image}:${var.image_tag}

    Comandes utils:
      kubectl get pods -n ${var.app_namespace}
      kubectl get svc  -n ${var.app_namespace}
      minikube service nginx-service -n ${var.app_namespace}

    Per fer rollback a una versio anterior:
      terraform apply -var="image_tag=<sha-anterior>"
    ==========================================================

  EOT
}
