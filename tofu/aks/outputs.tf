output "kube_config" {
  value = azurerm_kubernetes_cluster.resume.kube_config_raw

  sensitive = true
}

output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.resume.name
}