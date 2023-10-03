data "azurerm_resource_group" "db" {
  name = var.rg_name
}

data "azurerm_subnet" "subnet" {
  for_each             = { for v in var.allowed_subnets : "${v.vnet_name}/${v.subnet_name}" => v }
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.vnet_rg_name
}

resource "azurerm_cosmosdb_account" "cosmodb_account" {
  name                              = var.cosmosdb_account_name
  location                          = var.rg_location == null ? data.azurerm_resource_group.db.location : var.rg_location
  resource_group_name               = var.rg_name
  offer_type                        = var.offer_type
  kind                              = var.kind
  enable_automatic_failover         = var.enable_automatic_failover
  ip_range_filter                   = var.ip_range_filter
  is_virtual_network_filter_enabled = var.is_virtual_network_filter_enabled
  tags                              = var.tags

  dynamic "virtual_network_rule" {
    for_each = var.allowed_subnets
    content {
      id                                   = data.azurerm_subnet.subnet["${virtual_network_rule.value.vnet_name}/${virtual_network_rule.value.subnet_name}"].id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
    }
  }

  dynamic "capabilities" {
    for_each = var.capabilities
    content {
      name = capabilities.value
    }
  }

  consistency_policy {
    consistency_level = var.consistency_level
  }

  dynamic "geo_location" {
    for_each = var.geo_location
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = geo_location.value.zone_redundant == null ? false : geo_location.value.zone_redundant
    }
  }
}

# Manages a diagnostic setting for created cosmosdb account
resource "azurerm_monitor_diagnostic_setting" "main" {
  count                      = var.diagnostic_setting == null ? 0 : 1
  name                       = var.diagnostic_setting.diagnostic_setting_name
  target_resource_id         = azurerm_cosmosdb_account.cosmodb_account.id
  storage_account_id         = try(var.diagnostic_setting.storage_account_id, null) == null ? null : var.diagnostic_setting.storage_account_id
  log_analytics_workspace_id = try(var.diagnostic_setting.log_analytics_workspace_id, null) == null ? null : var.diagnostic_setting.log_analytics_workspace_id

  dynamic "log" {
    for_each = try(var.diagnostic_setting.log, [])
    content {
      category = log.value.category
      enabled  = try(log.value.enabled, true)
      retention_policy {
        enabled = try(log.value.retention_policy.enabled, false)
        days    = try(log.value.retention_policy.enabled, false) == true ? try(log.value.retention_policy.days, null) : null
      }
    }
  }

  dynamic "metric" {
    for_each = try(var.diagnostic_setting.metric, [])
    content {
      category = metric.value.category
      enabled  = try(metric.value.enabled, true)
      retention_policy {
        enabled = try(metric.value.retention_policy.enabled, false)
        days    = try(metric.value.retention_policy.enabled, false) == true ? try(metric.value.retention_policy.days, null) : null
      }
    }
  }
}