variable "resource_prefix" {
  type        = string
  description = "Short prefix for resource names"
  default     = "resume-app"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
  default     = ""
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant (directory) ID"
  default     = ""
}

variable "client_id" {
  type        = string
  description = "App registration (service principal) client ID"
  default     = ""
}

variable "use_oidc" {
  type        = bool
  description = "Use OIDC authentication"
  default     = false
}

variable "node_count" {
  type        = number
  description = "Pod node count"
  default     = "1"
}

variable "vm_size" {
  type        = string
  description = "Default VM size"
  default     = "Standard_D2als_v7"
}