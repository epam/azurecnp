output "appinsights_id" {
  description = "The ID of the Application Insights component."
  value       = azurerm_application_insights.appinsights.id
}

output "instrumentation_key" {
  description = "The Instrumentation Key for this Application Insights component."
  value       = azurerm_application_insights.appinsights.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "The Connection String for this Application Insights component."
  value       = azurerm_application_insights.appinsights.connection_string
  sensitive   = true
}

output "app_id" {
  description = "The App ID associated with this Application Insights component."
  value       = azurerm_application_insights.appinsights.app_id
}