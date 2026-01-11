data "azurerm_resource_group" "aks" {
    name = "RG-Mahbub-Rahman"
}
resource "azurerm_network_security_group" "main" {
  name                = "mahbub-security-group"
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name
}

resource "azurerm_virtual_network" "main" {
  name                = "mahbub-vnet"
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks-system-subnet" {
  name                 = "aks-system-subnet"
  resource_group_name  = data.azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks-node-subnet" {
  name                 = "aks-node-subnet"
  resource_group_name  = data.azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "appgw-subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = data.azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "mahbub-aks-cluster"
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name
  dns_prefix          = "exampleaks1"
  //private_cluster_enabled = true
  
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "systempool"
    node_count = 1
    min_count = 1
    max_count = 5
    vm_size    = "Standard_D2_v2"
    auto_scaling_enabled = true
    temporary_name_for_rotation = "poolrot"
    only_critical_addons_enabled = true
    vnet_subnet_id = azurerm_subnet.aks-system-subnet.id
  }
  
  lifecycle {
    prevent_destroy = true
  }

  network_profile {
    network_plugin = "azure"
    service_cidr = "192.168.0.0/24"
    dns_service_ip = "192.168.0.10"
  } 
}

resource "azurerm_kubernetes_cluster_node_pool" "example" {
  name                  = "internalpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  auto_scaling_enabled  = true
  max_count = 5
  min_count = 1
  vnet_subnet_id = azurerm_subnet.aks-node-subnet.id

  tags = {
    Environment = "Production"
  }
}