terraform {
  backend "azurerm" {
    container_name       = "#{ENV_TF_STATE_CONTAINER_NAME}#"
    key                  = "#{PIPE_INFRA_SOLUTION_FOLDER}#/#{ENV_TF_STATE_FOLDER}#/terraform.tfstate"
    resource_group_name  = "#{ENV_TF_STATE_RESOURCE_GROUP_NAME}#"
    storage_account_name = "#{ENV_TF_STATE_STORAGE_ACCOUNT_NAME}#"
    subscription_id      = "#{ENV_TF_STATE_SUBSCRIPTION_ID}#"
    client_secret        = "#{ENV_AZURE_CLIENT_SECRET}#" #tfsec:ignore:general-secrets-sensitive-in-attribute
    client_id            = "#{ENV_AZURE_CLIENT_ID}#"
    tenant_id            = "#{ENV_AZURE_TENANT_ID}#"
  }
}
