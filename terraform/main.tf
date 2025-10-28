# terraform/main.tf

# -----------------------------------------------------
# 1. Terraform Backend and Provider Setup
# -----------------------------------------------------

# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# The provider block authenticates using the environment variables
# (AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, etc.) set by the GitHub Runner.
provider "azurerm" {
  features {}
}

# -----------------------------------------------------
# 2. Resource Group and Variables
# -----------------------------------------------------

# Define variables for location and naming conventions
locals {
  prefix   = "devops-aks-proj"
  location = "East US" // Choose a region close to you if desired
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = local.location
}

# -----------------------------------------------------
# 3. Azure Container Registry (ACR)
# -----------------------------------------------------

resource "azurerm_container_registry" "acr" {
  name                = "${replace(local.prefix, "-", "")}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true # Required for CI/CD simplicity
}

# -----------------------------------------------------
# 4. Azure Kubernetes Service (AKS)
# -----------------------------------------------------

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.prefix}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${local.prefix}-dns"
  
  default_node_pool {
    name       = "default"
    node_count = 1  # Keep cost low with a single node
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# -----------------------------------------------------
# 5. ACR Integration with AKS
# -----------------------------------------------------

# Grant the AKS cluster (via its managed identity) Pull access to the ACR
resource "azurerm_role_assignment" "acr_pull_permission" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}


# -----------------------------------------------------
# 6. Outputs (Crucial for CI/CD Pipeline)
# -----------------------------------------------------

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_resource_group" {
  value = azurerm_resource_group.rg.name
}