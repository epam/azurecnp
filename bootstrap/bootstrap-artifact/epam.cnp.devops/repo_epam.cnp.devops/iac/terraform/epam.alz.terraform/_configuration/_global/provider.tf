# Set provider properties
provider "azurerm" {
  subscription_id = "#{ENV_AZURE_SUBSCRIPTION_ID}#"
  client_secret   = "#{ENV_AZURE_CLIENT_SECRET}#" #tfsec:ignore:general-secrets-sensitive-in-attribute
  client_id       = "#{ENV_AZURE_CLIENT_ID}#"
  tenant_id       = "#{ENV_AZURE_TENANT_ID}#"
  environment     = "#{ENV_AZURE_ENVIRONMENT}#"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    api_management {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azuread" {
  client_secret = "#{ENV_AZURE_CLIENT_SECRET}#" #tfsec:ignore:general-secrets-sensitive-in-attribute
  client_id     = "#{ENV_AZURE_CLIENT_ID}#"
  tenant_id     = "#{ENV_AZURE_TENANT_ID}#"
}
