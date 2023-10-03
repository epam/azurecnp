# Special variables block used for getting Remote State resources for "data.terraform_remote_state.*"
backend_container_name       = "#{ENV_TF_STATE_CONTAINER_NAME}#"
backend_resource_group_name  = "#{ENV_TF_STATE_RESOURCE_GROUP_NAME}#"
backend_storage_account_name = "#{ENV_TF_STATE_STORAGE_ACCOUNT_NAME}#"
backend_subscription_id      = "#{ENV_TF_STATE_SUBSCRIPTION_ID}#"
backend_client_secret        = "#{ENV_AZURE_CLIENT_SECRET}#" #tfsec:ignore:general-secrets-sensitive-in-attribute
backend_client_id            = "#{ENV_AZURE_CLIENT_ID}#"
backend_tenant_id            = "#{ENV_AZURE_TENANT_ID}#"