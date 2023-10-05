output "scheduled_query_rules_alert_id" {
  description = "The ID of the scheduled query rule"
  value       = [for scheduled_query_rules_alert in var.scheduled_query_rules_alert : azurerm_monitor_scheduled_query_rules_alert.query_rules_alert[scheduled_query_rules_alert.name].id]
}
output "monitor_metric_alert_id" {
  description = "The ID of the metric alert"
  value       = [for metric_alert in var.metric_alert : azurerm_monitor_metric_alert.metric_alert[metric_alert.name].id]
}
