# data "azurerm_client_config" "current" {}

# data "azurerm_private_dns_zone" "azmk8s" {
#   name = "privatelink.${var.location}.azmk8s.io"
# }

# data "azurerm_subnet" "cluster" {
#   name                 = "ClusterSubnet"
#   virtual_network_name = "usingsystem-vnet"
#   resource_group_name  = "usingsystem-vnet-rg"
# }

# data "azurerm_subnet" "app_gtw" {
#   name                 = "AppGtwSubnet"
#   virtual_network_name = "usingsystem-vnet"
#   resource_group_name  = "usingsystem-vnet-rg"
# }

