output "id" {
  description = "The ID of the AKS cluster"
  value       = try([for aks in var.aks : module.aks[aks.cluster_name].id], null)
}
output "name" {
  description = "The AKS cluster name"
  value       = try([for aks in var.aks : module.aks[aks.cluster_name].name], null)
}
output "username" {
  description = "The AKS cluster username"
  value       = try([for aks in var.aks : module.aks[aks.cluster_name].username], null)
  sensitive   = true
}
output "password" {
  description = "The AKS cluster password"
  value       = try([for aks in var.aks : module.aks[aks.cluster_name].password], null)
  sensitive   = true
}
output "host" {
  description = "The AKS cluster host"
  value       = try([for aks in var.aks : module.aks[aks.cluster_name].host], null)
  sensitive   = true
}
output "client_certificate" {
  description = "The AKS cluster client certificate"
  value       = try([for aks in var.aks : module.aks[aks.cluster_name].client_certificate], null)
  sensitive   = true
}
output "client_key" {
  description = "The AKS cluster client key"
  value       = try([for aks in var.aks : module.aks[aks.cluster_name].client_key], null)
  sensitive   = true
}
output "cluster_ca_certificate" {
  description = "The AKS cluster CA certificate"
  value       = try([for aks in var.aks : module.aks[aks.cluster_name].cluster_ca_certificate], null)
  sensitive   = true
}
output "kube_config_raw" {
  description = "The AKS cluster kubernetes configuration"
  value       = try([for aks in var.aks : module.aks[aks.cluster_name].kube_config_raw], null)
  sensitive   = true
}

output "cosmosdb_connection_strings" {
  value       = module.cosmosdb_account.connection_strings
  description = "A list of connection strings available for this CosmosDB account."
  sensitive   = true
}
output "cosmosdb_id" {
  value       = module.cosmosdb_account.id
  description = "The CosmosDB Account ID"
}
output "cosmosdb_primary_key" {
  value       = module.cosmosdb_account.primary_key
  description = "The Primary key for the CosmosDB Account"
  sensitive   = true
}
output "cosmosdb_name" {
  value       = module.cosmosdb_account.name
  description = "Specifies the name of the CosmosDB Account"
}
