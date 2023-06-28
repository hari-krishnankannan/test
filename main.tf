provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
features {}
}
terraform {
backend "azurerm" {
resource_group_name = "Azurevms"
storage_account_name = "mystatefiles"
container_name = "statefile"
key = "ei5+DK57QOuIYBJCXra1Q7Q0ZIgBPvkKi53ODWckTE5+3E+a4aYQNjFQPGUz5CFooKGXmhGG8mZl+AStL8xSww=="
}
}
resource "azurerm_resource_group" "k8s" {
  name     = var.resourcename
  location = var.location
}
resource "azurerm_virtual_network" "k8s" {
  name                = "k8s-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
}
resource "azurerm_subnet" "k8s" {
  name                 = "k8s-subnet"
  resource_group_name  = azurerm_resource_group.k8s.name
  virtual_network_name = azurerm_virtual_network.k8s.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.clustername
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = var.dnspreffix
default_node_pool {
    name       = "default"
    node_count = var.agentnode
    vm_size    = var.size
    vnet_subnet_id  = azurerm_subnet.k8s.id
  }
network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr = "10.0.2.0/24"
    dns_service_ip = "10.0.2.10"
  }
service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
}
