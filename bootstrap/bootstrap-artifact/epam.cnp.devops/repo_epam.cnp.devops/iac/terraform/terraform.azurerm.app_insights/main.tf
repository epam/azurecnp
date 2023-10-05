# Get resource group data
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

# Create application insights
resource "azurerm_application_insights" "appinsights" {
  name                       = var.appinsights_name
  location                   = var.location == null ? data.azurerm_resource_group.rg.location : var.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  workspace_id               = var.workspace_id
  application_type           = var.application_type
  retention_in_days          = var.retention_in_days
  sampling_percentage        = var.sampling_percentage
  disable_ip_masking         = var.disable_ip_masking
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled
  tags                       = var.tags
}