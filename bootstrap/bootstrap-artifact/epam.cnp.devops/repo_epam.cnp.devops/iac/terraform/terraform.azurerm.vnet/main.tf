#############################################################################################
#Azure Generic VNET Module
#############################################################################################

#############################################################################################
# Getting data of existing Resource Group for creation VNET
#############################################################################################
data "azurerm_resource_group" "vnet" {
  name  = var.rg_name
  count = var.location == null ? 1 : 0
}

#############################################################################################
# Getting existing DDoS plan 
#############################################################################################
data "azurerm_network_ddos_protection_plan" "ddosPlan" {
  count               = var.ddos_protection_plan_name != null ? 1 : 0
  name                = var.ddos_protection_plan_name
  resource_group_name = var.rg_name
}

#############################################################################################
# Creating a VNET
#############################################################################################
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.rg_name
  location            = var.location == null ? data.azurerm_resource_group.vnet[0].location : var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_name != null ? [1] : []
    content {
      id     = data.azurerm_network_ddos_protection_plan.ddosPlan[0].id
      enable = true
    }
  }

  lifecycle {
    ignore_changes = [
      ddos_protection_plan,
    ]
  }
}

#############################################################################################
# Creating subnets within VNET
#############################################################################################
resource "azurerm_subnet" "subnet" {
  for_each                                      = { for subnet in var.subnets : subnet.name => subnet }
  name                                          = each.value.name
  resource_group_name                           = var.rg_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.address_prefixes
  private_link_service_network_policies_enabled = lookup(each.value, "private_link_service_network_policies_enabled", true)
  private_endpoint_network_policies_enabled     = lookup(each.value, "private_endpoint_network_policies_enabled", true)
  service_endpoints                             = lookup(each.value, "service_endpoints", null)
  service_endpoint_policy_ids                   = lookup(each.value, "service_endpoint_policy_ids", null)

  dynamic "delegation" {
    for_each = try(each.value.delegation, null) != null ? { (each.value.delegation.name) = each.value.delegation } : {}
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

#############################################################################################
# Manages a diagnostic setting for created VNET
#############################################################################################
resource "azurerm_monitor_diagnostic_setting" "vnet" {
  count                      = var.diagnostic_setting == null ? 0 : 1
  name                       = var.diagnostic_setting.diagnostic_setting_name
  target_resource_id         = azurerm_virtual_network.vnet.id
  storage_account_id         = try(var.diagnostic_setting.storage_account_id, null) == null ? null : var.diagnostic_setting.storage_account_id
  log_analytics_workspace_id = var.diagnostic_setting.log_analytics_workspace_id

  dynamic "log" {
    for_each = { for logs in var.diagnostic_setting.log : logs.category => logs }
    content {
      category = log.value.category
      enabled  = log.value.enabled
      retention_policy {
        enabled = log.value.retention_policy.enabled
        days    = log.value.retention_policy.enabled == true ? try(log.value.retention_policy.days, null) : null
      }
    }
  }

  dynamic "metric" {
    for_each = { for metrics in var.diagnostic_setting.metric : metrics.category => metrics }
    content {
      category = metric.value.category
      enabled  = metric.value.enabled
      retention_policy {
        enabled = metric.value.retention_policy.enabled
        days    = metric.value.retention_policy.enabled == true ? try(metric.value.retention_policy.days, null) : null
      }
    }
  }
}