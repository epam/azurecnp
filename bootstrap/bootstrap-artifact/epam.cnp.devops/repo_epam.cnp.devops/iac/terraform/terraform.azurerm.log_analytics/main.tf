# Get resource group data
data "azurerm_resource_group" "rg" {
  count = var.location == null ? 1 : 0
  name  = var.rg_name
}

# Create an Azure Log Analytics (formally Operational Insights) workspace
resource "azurerm_log_analytics_workspace" "laworkspace" {
  name                = var.name
  location            = var.location != null ? var.location : data.azurerm_resource_group.rg[0].location
  resource_group_name = var.rg_name
  sku                 = var.pricing_tier
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

# Manages a diagnostic setting for Azure Log Analytics workspace
resource "azurerm_monitor_diagnostic_setting" "laworkspace" {
  count                      = var.diagnostic_setting == null ? 0 : 1
  name                       = var.diagnostic_setting.diagnostic_setting_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.laworkspace.id
  target_resource_id         = azurerm_log_analytics_workspace.laworkspace.id
  storage_account_id         = try(var.storage_account_id, null) == null ? null : var.storage_account_id

  dynamic "log" {
    for_each = { for logs in var.diagnostic_setting.log : logs.category_group => logs }
    content {
      category_group = log.value.category_group
      enabled        = log.value.enabled
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

# Create an Azure Log Analytics solution
resource "azurerm_log_analytics_solution" "lasolution" {
  for_each              = { for la_solution in var.la_solutions : la_solution.la_sln_name => la_solution }
  solution_name         = each.value.la_sln_name
  location              = var.location != null ? var.location : data.azurerm_resource_group.rg[0].location
  resource_group_name   = var.rg_name
  workspace_resource_id = azurerm_log_analytics_workspace.laworkspace.id
  workspace_name        = azurerm_log_analytics_workspace.laworkspace.name

  plan {
    publisher = each.value.la_sln_publisher
    product   = each.value.la_sln_product
  }
}

# Enable the Activity Log for on subscriptions level
resource "azurerm_resource_group_template_deployment" "deployment" {
  for_each            = toset(var.activity_log_subs)
  name                = "${each.key}-tf-arm-activitylog"
  resource_group_name = var.rg_name
  deployment_mode     = var.deployment_mode

  parameters_content = jsonencode(
    {
      "omsWorkspaceName" : {
        "value" : azurerm_log_analytics_workspace.laworkspace.name
      },
      "subscription_id" : {
        "value" : each.key
      }
    }
  )

  template_content = file("${path.module}/arm_ws_datasource.json")
}