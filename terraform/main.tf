resource "azurerm_log_analytics_workspace" "law" {
name = "ca-law"
location = var.location
resource_group_name = var.resource_group_name
sku = "PerGB2018"
retention_in_days = 30
}


resource "azurerm_container_app_environment" "env" {
name = "ca-env"
location = var.location
resource_group_name = var.resource_group_name
log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}



resource "azurerm_container_app" "frontend" {
name = "frontend-app"
container_app_environment_id = azurerm_container_app_environment.env.id
resource_group_name = var.resource_group_name
revision_mode = "Single"

template {
container {
name = "frontend"
image = "${var.acr_login_server}/${var.frontend_image}"
cpu = 0.5
memory = "1Gi"

ports {
port = 80
}
}

scale {
min_replicas = 1
max_replicas = 5

rule {
name = "http-scale"
http {
concurrent_requests = 50
}
}
}
}

ingress {
external_enabled = true
target_port = 80
}
}

resource "azurerm_container_app" "backend" {
name = "backend-app"
container_app_environment_id = azurerm_container_app_environment.env.id
resource_group_name = var.resource_group_name
revision_mode = "Single"

template {
container {
name = "backend"
image = "${var.acr_login_server}/${var.backend_image}"
cpu = 0.5
memory = "1Gi"

ports {
port = 5000
}
}

scale {
min_replicas = 1
max_replicas = 10

rule {
name = "http-scale"
http {
concurrent_requests = 30
}
}
}
}

ingress {
external_enabled = true
target_port = 5000
}
}
