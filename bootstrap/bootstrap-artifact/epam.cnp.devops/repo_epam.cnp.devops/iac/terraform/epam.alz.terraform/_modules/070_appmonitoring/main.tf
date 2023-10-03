# Define providers list
terraform {
  required_version = ">= 1.4.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "> 3.56.0"
    }
  }
}

# Create entities in the appinsights
module "appinsightsactions" {
  source                = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.app_insights_actions?ref=develop"
  for_each              = try(var.app_monitoring.appinsightactions, null) != null ? { for appinsightsaction in var.app_monitoring.appinsightactions : appinsightsaction.appinsights_name => appinsightsaction } : null
  rg_name               = each.value.rg_name
  appinsights_name      = each.value.appinsights_name
  standard_web_tests    = try(each.value.standard_web_tests, [])
  web_tests             = try(each.value.web_tests, [])
  analytics_items       = try(each.value.analytics_items, [])
  smart_detection_rules = try(each.value.smart_detection_rules, [])
}

# Create monitor action group
module "monitor_action_group" {
  source                      = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.monitor_action_group?ref=develop"
  for_each                    = try(var.app_monitoring.monitor_action_groups, null) != null ? { for action_group in var.app_monitoring.monitor_action_groups : action_group.action_group_name => action_group } : null
  action_group_name           = each.value.action_group_name
  action_group_short_name     = each.value.action_group_short_name
  rg_name                     = each.value.rg_name
  enabled                     = try(each.value.enabled, true)
  arm_role_receiver           = try(each.value.arm_role_receiver, [])
  automation_runbook_receiver = try(each.value.automation_runbook_receiver, [])
  azure_app_push_receiver     = try(each.value.azure_app_push_receiver, [])
  azure_function_receiver     = try(each.value.azure_function_receiver, [])
  email_receiver              = try(each.value.email_receiver, [])
  event_hub_receiver          = try(each.value.event_hub_receiver, [])
  itsm_receiver               = try(each.value.itsm_receiver, [])
  logic_app_receiver          = try(each.value.logic_app_receiver, [])
  sms_receiver                = try(each.value.sms_receiver, [])
  voice_receiver              = try(each.value.voice_receiver, [])
  webhook_receiver            = try(each.value.webhook_receiver, [])
  tags                        = try(each.value.tags, {})
  rule_action_group           = try(each.value.rule_action_group, [])
  action_rule_suppression     = try(each.value.action_rule_suppression, [])
}

# Create alerts rules
module "alerts" {
  source                      = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.alerts?ref=develop"
  depends_on                  = [module.monitor_action_group]
  for_each                    = try(var.app_monitoring.alerts, null) != null ? { for alert in var.app_monitoring.alerts : alert.action_group_name => alert } : null
  action_group_rg_name        = try(each.value.action_group_rg_name, module.monitor_action_group[each.value].resource_group_name)
  action_group_name           = try(each.value.action_group_name, module.monitor_action_group[each.value].name)
  azuremonitor_rg_name        = try(each.value.azuremonitor_rg_name, null)
  log_analytics_workspace_id  = try(each.value.log_analytics_workspace_id, null)
  metric_alert                = try(each.value.metric_alert, [])
  scheduled_query_rules_alert = try(each.value.scheduled_query_rules_alert, [])
  tags                        = try(each.value.tags, {})
}
