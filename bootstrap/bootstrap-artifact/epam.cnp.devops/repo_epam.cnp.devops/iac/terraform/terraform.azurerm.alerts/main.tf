# Get resource group data
data "azurerm_resource_group" "rg" {
  name = coalesce(var.azuremonitor_rg_name, var.action_group_rg_name)
}

# Get monitor action group data
data "azurerm_monitor_action_group" "action_group" {
  resource_group_name = var.action_group_rg_name
  name                = var.action_group_name
}

# Create monitor metric alert
resource "azurerm_monitor_metric_alert" "metric_alert" {
  for_each                 = { for metric_alert in var.metric_alert : metric_alert.name => metric_alert }
  name                     = each.value.name
  resource_group_name      = data.azurerm_resource_group.rg.name
  scopes                   = each.value.metric_alert_scopes
  description              = try(each.value.description, null)
  enabled                  = try(each.value.enabled, true)
  auto_mitigate            = try(each.value.auto_mitigate, true)
  frequency                = try(each.value.frequency, "PT1M")
  severity                 = try(each.value.severity, "3")
  target_resource_type     = try(each.value.target_resource_type, null)
  target_resource_location = try(each.value.target_resource_location, null)
  window_size              = try(each.value.window_size, "PT5M")
  tags                     = var.tags

  dynamic "criteria" {
    for_each = { for c in lookup(each.value, "criteria", null) : c.metric_name => c }
    content {
      metric_namespace       = lookup(criteria.value, "metric_namespace")
      metric_name            = lookup(criteria.value, "metric_name")
      aggregation            = lookup(criteria.value, "aggregation")
      operator               = lookup(criteria.value, "operator")
      threshold              = lookup(criteria.value, "threshold")
      skip_metric_validation = try(criteria.value.skip_metric_validation, false)

      dynamic "dimension" {
        for_each = { for dimension in lookup(criteria.value, "dimension") : dimension.name => dimension }
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

  dynamic "dynamic_criteria" {
    for_each = try(each.value.dynamic_criteria, null) != null ? [each.value.dynamic_criteria] : []
    content {
      metric_namespace         = dynamic_criteria.value.metric_namespace
      metric_name              = dynamic_criteria.value.metric_name
      aggregation              = dynamic_criteria.value.aggregation
      operator                 = dynamic_criteria.value.operator
      alert_sensitivity        = dynamic_criteria.value.alert_sensitivity
      evaluation_total_count   = try(dynamic_criteria.value.evaluation_total_count, null)
      evaluation_failure_count = try(dynamic_criteria.value.evaluation_failure_count, null)
      ignore_data_before       = try(dynamic_criteria.value.ignore_data_before, null)
      skip_metric_validation   = try(dynamic_criteria.value.skip_metric_validation, false)

      dynamic "dimension" {
        for_each = { for dimension in each.value.dynamic_criteria.dimension : dimension.name => dimension }
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

  dynamic "application_insights_web_test_location_availability_criteria" {
    for_each = try(each.value.application_insights_web_test_location_availability_criteria, null) != null ? [each.value.application_insights_web_test_location_availability_criteria] : []
    content {
      web_test_id           = application_insights_web_test_location_availability_criteria.value.web_test_id
      component_id          = application_insights_web_test_location_availability_criteria.value.component_id
      failed_location_count = application_insights_web_test_location_availability_criteria.value.failed_location_count
    }
  }

  action {
    action_group_id    = data.azurerm_monitor_action_group.action_group.id
    webhook_properties = try(each.value.action.webhook_properties, null)
  }
}

# Create scheduled query rules alert
resource "azurerm_monitor_scheduled_query_rules_alert" "query_rules_alert" {
  for_each                = { for scheduled_query_rules_alert in var.scheduled_query_rules_alert : scheduled_query_rules_alert.name => scheduled_query_rules_alert }
  name                    = each.value.name
  location                = try(each.value.location, data.azurerm_resource_group.rg.location)
  resource_group_name     = data.azurerm_resource_group.rg.name
  data_source_id          = var.log_analytics_workspace_id
  description             = try(each.value.description, null)
  enabled                 = try(each.value.enabled, true)
  frequency               = each.value.frequency
  time_window             = each.value.time_window
  severity                = try(each.value.severity, null)
  throttling              = try(each.value.throttling, null)
  authorized_resource_ids = try(each.value.authorized_resource_ids, null)
  auto_mitigation_enabled = try(each.value.auto_mitigation_enabled, false)
  query                   = each.value.query
  tags                    = var.tags

  action {
    action_group           = [data.azurerm_monitor_action_group.action_group.id]
    email_subject          = try(each.value.action.email_subject, null)
    custom_webhook_payload = try(each.value.action.custom_webhook_payload, null)
  }

  trigger {
    operator  = each.value.trigger.operator
    threshold = each.value.trigger.threshold

    dynamic "metric_trigger" {
      for_each = { for metric in each.value.trigger.metric_trigger : metric.metric_column => metric }
      content {
        metric_column       = metric_trigger.value.metric_column
        metric_trigger_type = metric_trigger.value.metric_trigger_type
        operator            = metric_trigger.value.operator
        threshold           = metric_trigger.value.threshold
      }
    }
  }
}
