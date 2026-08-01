variable "resource_prefix" {
  type        = string
  description = "Short prefix for resource names"
  default     = "resume"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "centralus"
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

variable "swa_location" {
  type        = string
  description = "Region for Static web app"
  default     = "eastus2"
}
