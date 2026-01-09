resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name
  sku                 = "Standard"
  admin_enabled       = true

  tags = {
    Environment = "dev"
  }
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  value     = azurerm_container_registry.acr.admin_username
  sensitive = false
}

output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}
