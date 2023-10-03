output "action_group_id" {
  description = "The ID of the Action Group"
  value       = azurerm_monitor_action_group.monitor_ag.id
}

output "action_group_rule_id" {
  description = "The ID of the Monitor Action Rule"
  value       = [for rule in var.rule_action_group : azurerm_monitor_alert_processing_rule_action_group.rule_ag[rule.name].id]
}

output "action_group_suppression_rule_id" {
  description = "The ID of the Monitor Action Suppression Rule"
  value       = [for rule_suppression in var.action_rule_suppression : azurerm_monitor_alert_processing_rule_suppression.rule_suppression[rule_suppression.name].id]
}
