resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix}-OpenTofu-AKS"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "resume" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "resume-aks"
  location            = var.location
  dns_prefix          = "resume-aks"
  sku_tier            = "Free"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}