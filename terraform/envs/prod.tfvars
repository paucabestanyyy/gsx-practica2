# Configuracio per a l'entorn de PRODUCCIO
environment        = "prod"
app_namespace      = "greendev-prod"
welcome_message    = "Welcome to GreenDevCorp Production"
backend_replicas   = 3
nginx_replicas     = 2
nginx_node_port    = 30082
redis_storage_size = "2Gi"
image_tag          = "v2"
