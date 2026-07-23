# Backend storage for terraform state locking
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateresumesimplified"
    container_name       = "tfstate"
    key                  = "resume-site/tofu.tfstate"
    use_oidc             = true
  }
}