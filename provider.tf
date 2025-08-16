terraform {
    required_providers {
        # Azure AD provider
        azuread = {
        source  = "hashicorp/azuread"
        version =  "2.41.0"
        }  
    }
    required_version = ">= 1.9.0"
}

provider "azurerm" {
  features {
    
  }
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

provider "azuread" {
  tenant_id     = var.tenant_id
  client_id     = var.client_id
  client_secret = var.client_secret
 
}

data "azurerm_client_config" "current" {}