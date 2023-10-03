output "log_analytics_workspace_id" {
  description = "The Workspace (or Customer) ID for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.laworkspace.workspace_id
}

output "id" {
  description = "The id of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.laworkspace.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.laworkspace.name
}