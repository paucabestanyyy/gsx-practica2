# Configuracio per a l'entorn de STAGING
environment        = "staging"
app_namespace      = "greendev-staging"
welcome_message    = "[STAGING] Hello from GreenDevCorp staging"
backend_replicas   = 2
nginx_replicas     = 2
nginx_node_port    = 30081
redis_storage_size = "1Gi"
image_tag          = "v2"
