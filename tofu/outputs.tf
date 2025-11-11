output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "storage_account" {
  value = azurerm_storage_account.sa.name
}

output "static_web_url" {
  value = azurerm_storage_account.sa.primary_web_endpoint
}