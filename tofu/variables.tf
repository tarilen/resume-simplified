variable "resource_prefix" {
  type        = string
  description = "Short prefix for resource names"
  default     = "resume"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant (directory) ID"
}

variable "client_id" {
  type        = string
  description = "App registration (service principal) client ID"
}

variable "use_oidc" {
  type        = bool
  description = "Use OIDC authentication"
  default     = false
}
