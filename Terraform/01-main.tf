# We will define 
# 1. Terraform Settings Block
# 1. Required Version Terraform
# 2. Required Terraform Providers
# 3. Terraform Remote State Storage with Azure Storage Account (last step of this section)
# 2. Terraform Provider Block for AzureRM
# 3. Terraform Resource Block: Define a Random Pet Resource

# 1. Terraform Settings Block
terraform {
  # 1. Required Version Terraform
  required_version = ">= 1.0"
  # 2. Required Terraform Providers  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

# Terraform State Storage to Azure Storage Container
  backend "azurerm" {
    resource_group_name   = "RG_mahbub.rahman"
    storage_account_name  = "aksstatefiles01"
    container_name        = "statefiles"
    key                   = "terraform.tfstate"
  }  
}



# # 2. Terraform Provider Block for AzureRM
# provider "azurerm" {
#   subscription_id = "05ca4ebd-62e8-48a0-bd46-2e10f810c811"
#   features {
#     # Updated as part of June2023 to delete "ContainerInsights Resources" when deleting the Resource Group
#     resource_group {
#       prevent_deletion_if_contains_resources = false
#     }
#   }
# }

provider "azurerm" {
  subscription_id = "05ca4ebd-62e8-48a0-bd46-2e10f810c811"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# 3. Terraform Resource Block: Define a Random Pet Resource

locals {
  resource_group = "RG_mahbub.rahman"
  name = "AKS-Application"
  location = "UK West"
  env = "Demo"
}

resource "azurerm_container_registry" "acr" {
  name                = "containerRegistry"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  location            = data.azurerm_resource_group.aks_rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

data "azurerm_resource_group" "aks_rg" {
  name = local.resource_group
}
data "azurerm_kubernetes_service_versions" "current" {
  location        = data.azurerm_resource_group.aks_rg.location
  include_preview = false
}
resource "azuread_group" "aks_administrators" {
  #name        = "${azurerm_resource_group.aks_rg.name}-cluster-administrators"
  # Below two lines added as part of update June2023
  display_name     = "${data.azurerm_resource_group.aks_rg.name}-cluster-administrators"
  security_enabled = true
  description      = "Azure AKS Kubernetes administrators for the ${data.azurerm_resource_group.aks_rg.name}-cluster."
}
resource "azurerm_log_analytics_workspace" "insights" {
  name                = "${local.env}-logs"
  location            = data.azurerm_resource_group.aks_rg.location
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  retention_in_days   = 30
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  dns_prefix          = local.name
  location            = local.location
  name                = "${local.name}-cluster"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${data.azurerm_resource_group.aks_rg.name}-nrg"


  default_node_pool {
    name       = "systempool"
    vm_size    = "Standard_DS2_v2"
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    #availability_zones   = [1, 2, 3]
    # Added June2023
    zones = [1, 2, 3]
    #enable_auto_scaling  = true # COMMENTED OCT2024
    auto_scaling_enabled = true  # ADDED OCT2024
    max_count            = 3
    min_count            = 1
    os_disk_size_gb      = 30
    type           = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = local.env
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = local.env
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }    
  }

# Identity (System Assigned or Service Principal)
  identity { type = "SystemAssigned" }

# Added June 2023
oms_agent {
  log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
}
# Add On Profiles
#  addon_profile {
#    azure_policy { enabled = true }
#    oms_agent {
#      enabled                    = true
#      log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
#    }
#  }

# RBAC and Azure AD Integration Block
#role_based_access_control {
#  enabled = true
#  azure_active_directory {
#    managed                = true
#    admin_group_object_ids = [azuread_group.aks_administrators.id]
#  }
#}  

# Added June 2023
azure_active_directory_role_based_access_control {
  #managed = true # COMMENTED OCT2024
  #admin_group_object_ids = [azuread_group.aks_administrators.id] # COMMENTED OCT2024
  admin_group_object_ids = [azuread_group.aks_administrators.object_id] # ADDED OCT2024
}

# Windows Admin Profile
windows_profile {
  admin_username            = var.windows_admin_username
  admin_password            = var.windows_admin_password
}

# Linux Profile
# linux_profile {
#   admin_username = "ubuntu"
#   ssh_key {
#       key_data = file(var.ssh_public_key)
#   }
# }

# Network Profile
network_profile {
  load_balancer_sku = "standard"
  network_plugin = "azure"
}

# AKS Cluster Tags 
tags = {
  Environment = local.env
}


}

resource "azurerm_kubernetes_cluster_node_pool" "linux101" {
  #availability_zones    = [1, 2, 3]
  # Added June 2023
  zones = [ 1, 2, 3 ]
  #enable_auto_scaling  = true # COMMENTED OCT2024
  auto_scaling_enabled = true  # ADDED OCT2024
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  max_count             = 3
  min_count             = 1
  mode                  = "User"
  name                  = "linux101"
  orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  os_disk_size_gb       = 30
  os_type               = "Linux" # Default is Linux, we can change to Windows
  vm_size               = "Standard_DS2_v2"
  priority              = "Regular"  # Default is Regular, we can change to Spot with additional settings like eviction_policy, spot_max_price, node_labels and node_taints
  node_labels = {
    "nodepool-type" = "user"
    "environment"   = local.env
    "nodepoolos"    = "linux"
    "app"           = "java-apps"
  }
  tags = {
    "nodepool-type" = "user"
    "environment"   = local.env
    "nodepoolos"    = "linux"
    "app"           = "java-apps"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "win101" {
  #availability_zones    = [1, 2, 3]
  # Added June 2023
  zones = [ 1, 2, 3 ]
  #enable_auto_scaling  = true # COMMENTED OCT2024
  auto_scaling_enabled = true  # ADDED OCT2024
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  max_count             = 3
  min_count             = 1
  mode                  = "User"
  name                  = "win101"
  orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  os_disk_size_gb       = 30
  os_type               = "Windows" # Default is Linux, we can change to Windows
  vm_size               = "Standard_DS2_v2"
  priority              = "Regular"  # Default is Regular, we can change to Spot with additional settings like eviction_policy, spot_max_price, node_labels and node_taints
  node_labels = {
    "nodepool-type" = "user"
    "environment"   = local.env
    "nodepoolos"    = "windows"
    "app"           = "dotnet-apps"
  }
  tags = {
    "nodepool-type" = "user"
    "environment"   = local.env
    "nodepoolos"    = "windows"
    "app"           = "dotnet-apps"
  }
}