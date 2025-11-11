resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  sa_name = "${var.resource_prefix}${random_string.suffix.result}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix}-OpenTofu"
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_account_static_website" "site" {
  storage_account_id = azurerm_storage_account.sa.id
  index_document      = "index.html"
  error_404_document  = "index.html"
}
