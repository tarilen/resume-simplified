terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateresumesimplified"
    container_name       = "tfstate"
    key                  = "resume-aks/tofu.tfstate" # isolate site from ask
    use_oidc             = true
  }
}