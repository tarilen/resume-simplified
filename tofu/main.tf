resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix}-OpenTofu"
  location = var.location
}

resource "azurerm_static_web_app" "site" {
  name                = "${var.resource_prefix}-site"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.swa_location
  sku_tier            = "Free"
  sku_size            = "Free"
}
