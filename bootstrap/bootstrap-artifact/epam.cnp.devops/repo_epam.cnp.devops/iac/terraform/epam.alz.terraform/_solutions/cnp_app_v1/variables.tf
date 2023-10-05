variable "aks" {
  description = "Azure AKS configuration"
  type        = any
}
variable "vnet" {
  description = "Azure VNET configuration"
  type        = any
}
variable "acr" {
  description = "Azure ACR configuration"
  type        = any
}
variable "location" {
  description = "Azure resource location"
  type        = any
}
variable "log_analytics" {
  description = "Azure Log Analytics configuration"
  type        = any
  default     = null
}
variable "cosmosdb_account" {
  description = "Azure Cosmos DB configuration"
  type        = any
}
variable "app_insights" {
  description = "Azure Application Insights configuration"
  type        = any
}
variable "monitor_action_groups" {
  description = "Monitor action groups configuration for AKS."
  type        = any
}
variable "alerts" {
  description = "AKS alerts configuration"
  type        = any
}
