output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "static_web_url" {
  value = "https://${azurerm_static_web_app.site.default_host_name}"
}

output "swa_api_token" {
  value     = azurerm_static_web_app.site.api_key
  sensitive = true
}
