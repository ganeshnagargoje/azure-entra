variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant (Entra ID) ID"
}

variable "client_id" {
  type        = string
  description = "Azure AD application (service principal) client ID"
}

variable "client_secret" {
  type        = string
  description = "Azure AD application (service principal) client secret"
  sensitive   = true
}
