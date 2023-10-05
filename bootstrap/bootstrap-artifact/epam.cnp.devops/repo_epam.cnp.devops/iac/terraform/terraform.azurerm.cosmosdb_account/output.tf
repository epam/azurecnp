output "connection_strings" {
  value       = azurerm_cosmosdb_account.cosmodb_account.connection_strings
  description = "A list of connection strings available for this CosmosDB account."
}

output "id" {
  value       = azurerm_cosmosdb_account.cosmodb_account.id
  description = "The CosmosDB Account ID"
}

output "primary_key" {
  value       = azurerm_cosmosdb_account.cosmodb_account.primary_key
  description = "The Primary key for the CosmosDB Account"
  sensitive   = true
}

output "name" {
  value       = azurerm_cosmosdb_account.cosmodb_account.name
  description = "Specifies the name of the CosmosDB Account"
}