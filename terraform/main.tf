terraform {
  backend "azurerm" {}
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

################################
# VARIABLES
################################
variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
}

################################
# RESOURCE GROUP
################################
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

################################
# AZURE CONTAINER REGISTRY (ACR)
################################
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

################################
# LOG ANALYTICS WORKSPACE
################################
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.resource_group_name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

################################
# CONTAINER APPS ENVIRONMENT
################################
resource "azurerm_container_app_environment" "env" {
  name                       = "${var.resource_group_name}-env"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

################################
# FRONTEND CONTAINER APP
################################
resource "azurerm_container_app" "frontend" {
  name                         = "frontend-app"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  template {
    container {
      name   = "frontend"
      image  = "${azurerm_container_registry.acr.login_server}/frontend-app:latest"
      cpu    = 0.5
      memory = "1Gi"
    }

    # Replica limits
    min_replicas = 1
    max_replicas = 5

    # HTTP autoscale rule
    http_scale_rule {
      name                = "http"
      concurrent_requests = 50
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80

    # Required even with Single revision mode
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

################################
# BACKEND CONTAINER APP
################################
resource "azurerm_container_app" "backend" {
  name                         = "backend-app"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  template {
    container {
      name   = "backend"
      image  = "${azurerm_container_registry.acr.login_server}/backend-app:latest"
      cpu    = 0.5
      memory = "1Gi"
    }

    min_replicas = 1
    max_replicas = 5

    http_scale_rule {
      name                = "http"
      concurrent_requests = 30
    }
  }

  ingress {
    external_enabled = true
    target_port      = 5000

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

################################
# ACR PULL ROLE ASSIGNMENTS
################################
resource "azurerm_role_assignment" "frontend_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.frontend.identity[0].principal_id
}

resource "azurerm_role_assignment" "backend_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.backend.identity[0].principal_id
}

################################
# OUTPUTS
################################
output "frontend_url" {
  value = azurerm_container_app.frontend.ingress[0].fqdn
}

output "backend_url" {
  value = azurerm_container_app.backend.ingress[0].fqdn
}
