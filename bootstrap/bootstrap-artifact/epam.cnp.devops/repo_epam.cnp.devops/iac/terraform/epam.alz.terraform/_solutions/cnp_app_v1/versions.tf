# Define providers list
terraform {
  required_version = ">= 1.4.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.35.0"
    }
  }
}

# Configure the alternative Microsoft Azure Provider for full destroy all nested resources
provider "azurerm" {
  alias  = "aliasDestroyAll"
  subscription_id = "#{ENV_AZURE_SUBSCRIPTION_ID}#"
  client_secret   = "#{ENV_AZURE_CLIENT_SECRET}#" #tfsec:ignore:general-secrets-sensitive-in-attribute
  client_id       = "#{ENV_AZURE_CLIENT_ID}#"
  tenant_id       = "#{ENV_AZURE_TENANT_ID}#"
  environment     = "#{ENV_AZURE_ENVIRONMENT}#"
  features {
    resource_group {
      # Used to successfully destroy all resources. Otherwise, Container insights creates dynamically and block removal step.
      prevent_deletion_if_contains_resources = false
    }
  }
}