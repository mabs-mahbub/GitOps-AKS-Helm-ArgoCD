

# locals {
#   vnet_name                          = "mahbub-vnet"
#   gtw_backend_address_pool_name      = "${local.vnet_name}-beap"
#   gtw_frontend_port_name             = "${local.vnet_name}-feport"
#   gtw_frontend_ip_configuration_name = "${local.vnet_name}-feip"
#   gtw_http_setting_name              = "${local.vnet_name}-be-htst"
#   gtw_listener_name                  = "${local.vnet_name}-httplstn"
#   gtw_request_routing_rule_name      = "${local.vnet_name}-rqrt"
#   gtw_redirect_configuration_name    = "${local.vnet_name}-rdrcfg"
# }

# resource "azurerm_public_ip" "app_gtw" {
#   allocation_method   = "Static"
#   location            = var.location
#   name                = "usinssystem-gtw-pip"
#   resource_group_name = data.azurerm_resource_group.aks.name
#   sku                 = "Standard"
# }

# resource "azurerm_user_assigned_identity" "app_gtw" {
#   location            = var.location
#   name                = "app_gtw-identity"
#   resource_group_name = data.azurerm_resource_group.aks.name

# }

# resource "azurerm_application_gateway" "app_gtw" {
#   name                = "mahbub-appgw"
#   resource_group_name = data.azurerm_resource_group.aks.name
#   location            = var.location

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 1
#   }

#   enable_http2 = true

# #   identity {
# #     type = "UserAssigned"
# #     identity_ids = [
# #       azurerm_user_assigned_identity.app_gtw.id
# #     ]
# #   }

#   gateway_ip_configuration {
#     name      = "mahbub-gtw-ip-config"
#     subnet_id = azurerm_subnet.appgw-subnet.id
#   }

#   frontend_port {
#     name = local.gtw_frontend_port_name
#     port = 443
#   }

#   frontend_ip_configuration {
#     name                 = local.gtw_frontend_ip_configuration_name
#     public_ip_address_id = azurerm_public_ip.app_gtw.id
#   }

#   backend_address_pool {
#     name = local.gtw_backend_address_pool_name
#   }

#   backend_http_settings {
#     name                  = local.gtw_http_setting_name
#     cookie_based_affinity = "Disabled"
#     path                  = "/path1/"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 60
#   }


#   http_listener {
#     name                           = local.gtw_listener_name
#     frontend_ip_configuration_name = local.gtw_frontend_ip_configuration_name
#     frontend_port_name             = local.gtw_frontend_port_name
#     protocol                       = "Https"
#     ssl_certificate_name           = "usingsystem-cert"
#   }

#   request_routing_rule {
#     name                       = local.gtw_request_routing_rule_name
#     priority                   = 9
#     rule_type                  = "Basic"
#     http_listener_name         = local.gtw_listener_name
#     backend_address_pool_name  = local.gtw_backend_address_pool_name
#     backend_http_settings_name = local.gtw_http_setting_name
#   }

#   lifecycle {
#     ignore_changes = [
#       tags,
#       backend_address_pool,
#       backend_http_settings,
#       http_listener,
#       probe,
#       request_routing_rule,
#       url_path_map,
#       frontend_port,
#       redirect_configuration
#     ]
#   }
# }