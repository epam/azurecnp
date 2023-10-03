# Get resource group data in case location not provided
data "azurerm_resource_group" "rg" {
  count = var.location == null ? 1 : 0
  name  = var.rg_name
}

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                          = var.name
  resource_group_name           = var.rg_name
  location                      = var.location == null ? data.azurerm_resource_group.rg[0].location : var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  export_policy_enabled         = var.export_policy_enabled
  data_endpoint_enabled         = var.data_endpoint_enabled
  network_rule_bypass_option    = var.network_rule_bypass_option

  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? ["identity"] : []
    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }

  dynamic "encryption" {
    for_each = var.encryption != null ? ["encryption"] : []
    content {
      enabled            = var.encryption.enabled
      key_vault_key_id   = var.encryption.key_vault_key_id
      identity_client_id = var.encryption.identity_client_id
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy_days != null ? ["retention_policy_days"] : []
    content {
      days    = var.retention_policy_days
      enabled = true
    }
  }

  tags = var.tags
}