#############################################################################################
# Deploy AKS resource groups
#############################################################################################
module "rg_aks" {
  source   = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.rg?ref=develop"
  for_each = { for aks in var.aks : aks.cluster_name => aks }
  name     = each.value.rg_name
  location = var.location
  tags     = lookup(each.value, "tags", {})
}

#############################################################################################
# Deploy Log Analytics resource groups
#############################################################################################
module "rg_la" {
  source = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.rg?ref=develop"
  providers = {
    azurerm = azurerm.aliasDestroyAll
  }
  name     = var.log_analytics.rg_name
  location = var.location
  tags     = lookup(var.log_analytics, "tags", {})
}

#############################################################################################
# Deploy Storage (ACR and CosmosDB) resource group
#############################################################################################
module "rg_st" {
  source   = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.rg?ref=develop"
  name     = var.acr.rg_name
  location = var.location
  tags     = lookup(var.acr, "tags", {})
}

#############################################################################################
# Deploy VNET resource group
#############################################################################################
module "rg_vnet" {
  source   = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.rg?ref=develop"
  name     = var.vnet.rg_name
  location = var.location
  tags     = lookup(var.vnet, "tags", {})
}

#############################################################################################
# Deploy Log Analytics
#############################################################################################
module "log_analytics" {
  source = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.log_analytics?ref=develop"
  count  = var.log_analytics != null ? 1 : 0
  depends_on = [
    module.rg_la
  ]
  name               = var.log_analytics.name
  rg_name            = var.log_analytics.rg_name
  pricing_tier       = try(var.log_analytics.pricing_tier, "PerGB2018")
  retention_in_days  = try(var.log_analytics.retention_in_days, null)
  location           = var.location
  la_solutions       = try(var.log_analytics.lasolutions, [])
  activity_log_subs  = lookup(var.log_analytics, "activity_log_subs", [])
  diagnostic_setting = try(var.log_analytics.diagnostic_setting, null)
  tags               = lookup(var.log_analytics, "tags", {})
}

#############################################################################################
# Creating a Virtual Network
#############################################################################################
module "vnet" {
  source = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.vnet?ref=develop"
  depends_on = [
    module.rg_vnet
  ]
  vnet_name                 = var.vnet.vnet_name
  rg_name                   = var.vnet.rg_name
  address_space             = var.vnet.address_space
  ddos_protection_plan_name = lookup(var.vnet, "ddos_protection_plan_name", null)
  dns_servers               = lookup(var.vnet, "dns_servers", [])
  subnets                   = var.vnet.subnets
  tags                      = lookup(var.vnet, "tags", {})
  diagnostic_setting        = try(var.vnet.diagnostic_setting, null)
}

#############################################################################################
# Deploy ACR
#############################################################################################
module "azurecontainerregistry" {
  source = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.azure_container_registry?ref=develop"
  depends_on = [
    module.rg_st
  ]
  name                          = var.acr.name
  rg_name                       = var.acr.rg_name
  sku                           = var.acr.sku
  location                      = var.location
  admin_enabled                 = try(var.acr.admin_enabled, false)
  public_network_access_enabled = try(var.acr.public_network_access_enabled, true)
  georeplications               = try(var.acr.georeplications, [])
  tags                          = lookup(var.acr, "tags", {})
}

#############################################################################################
# Deploy AKS cluster
#############################################################################################
module "aks" {
  source = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.aks?ref=develop"
  depends_on = [
    module.rg_aks,
    module.rg_vnet,
    module.vnet
  ]
  for_each                = { for aks in var.aks : aks.cluster_name => aks }
  location                = var.location
  rg_name                 = each.value.rg_name
  cluster_name            = each.value.cluster_name
  dns_prefix              = try(each.value.resource_name_prefix, null)
  private_cluster_enabled = try(each.value.aks_private_cluster_enabled, false)

  # Enable The Azure Monitor for Containers (also known as Container Insights)
  la_workspace_id = var.log_analytics != null ? module.log_analytics[0].id : null

  # Identity
  client_id     = try(each.value.client_id, null)
  client_secret = try(each.value.client_secret, null)
  identity_type = try(each.value.identity_type, "SystemAssigned")
  identity_ids  = try(each.value.identity_ids, null)

  # Authorized ip ranges for AKS
  api_server_access_profile = try(each.value.api_server_access_profile, null)

  # Default node pool with default configuration subnet, vnet configuration must be provided
  default_node_pool = (try(each.value.default_node_pool, null) == null ? null :
    try(each.value.default_node_pool.vnet_subnet_id, null) != null ? 
      # workaround for avoid type inconsistency error
      merge(
        each.value.default_node_pool,
        {vnet_subnet_id = each.value.default_node_pool.vnet_subnet_id}
      ) : 
      merge(
        each.value.default_node_pool,
        {vnet_subnet_id = "${module.vnet.vnet_id}/subnets/${var.vnet.subnets[0].name}"}
      )
  )

  # Additional node pools
  node_pools = try(each.value.node_pools, [])

  # Role base access control
  aad_rbac = try(each.value.aad_rbac, null)

  # Auto scaler profile
  balance_similar_node_groups      = try(each.value.balance_similar_node_groups, false)
  max_graceful_termination_sec     = try(each.value.max_graceful_termination_sec, "600")
  scale_down_delay_after_add       = try(each.value.scale_down_delay_after_add, "10m")
  scale_down_delay_after_failure   = try(each.value.scale_down_delay_after_failure, "3m")
  scan_interval                    = try(each.value.scan_interval, "10s")
  scale_down_unneeded              = try(each.value.scale_down_unneeded, "10m")
  scale_down_unready               = try(each.value.scale_down_unready, "20m")
  scale_down_utilization_threshold = try(each.value.scale_down_utilization_threshold, "0.5")

  # Network configuration
  network_plugin     = try(each.value.network_plugin, "kubenet")
  network_policy     = try(each.value.network_policy, null)
  pod_cidr           = try(each.value.pod_cidr, null)
  service_cidr       = try(each.value.service_cidr, null)
  dns_service_ip     = try(each.value.dns_service_ip, null)
  docker_bridge_cidr = try(each.value.docker_bridge_cidr, null)
  tags               = try(each.value.tags, {})
}

resource "azurerm_role_assignment" "acrpull" {
  for_each                         = { for aks in var.aks : aks.cluster_name => aks }
  principal_id                     = module.aks[each.value.cluster_name].kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = module.azurecontainerregistry.id
  skip_service_principal_aad_check = true
}

#############################################################################################
# Deploy CosmosDB
#############################################################################################
module "cosmosdb_account" {
  source = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.cosmosdb_account?ref=develop"
  depends_on = [
    module.rg_st,
    module.vnet
  ]
  cosmosdb_account_name             = var.cosmosdb_account.cosmosdb_account_name
  rg_name                           = var.cosmosdb_account.rg_name
  rg_location                       = var.location
  offer_type                        = lookup(var.cosmosdb_account, "offer_type", "Standard")
  kind                              = lookup(var.cosmosdb_account, "kind", "GlobalDocumentDB")
  enable_automatic_failover         = lookup(var.cosmosdb_account, "enable_automatic_failover", false)
  ip_range_filter                   = lookup(var.cosmosdb_account, "ip_range_filter", "")
  is_virtual_network_filter_enabled = lookup(var.cosmosdb_account, "is_virtual_network_filter_enabled", true)
  consistency_level                 = lookup(var.cosmosdb_account, "consistency_level", "Session")
  allowed_subnets                   = lookup(var.cosmosdb_account, "allowed_subnets", [])
  capabilities                      = lookup(var.cosmosdb_account, "capabilities", [])
  diagnostic_setting                = lookup(var.cosmosdb_account, "diagnostic_setting", null)
  tags                              = try(var.cosmosdb_account.tags, {})
  geo_location = lookup(var.cosmosdb_account, "geo_location", [{
    location          = var.location
    failover_priority = 0
  }])
}

# Get subnet data for the private endpoint
data "azurerm_subnet" "prend_subnet" {
  depends_on = [
    module.vnet
  ]
  name                 = var.cosmosdb_account.prend_subnet_name
  virtual_network_name = module.vnet.vnet_name
  resource_group_name  = var.vnet.rg_name
}

#############################################################################################
# Create endpoint for CosmosDB
#############################################################################################
module "private_endpoint" {
  source = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.private_endpoint?ref=develop"
  depends_on = [
    module.vnet,
    module.cosmosdb_account
  ]
  name                = "${module.cosmosdb_account.name}-prend"
  resource_group_name = var.vnet.rg_name
  location            = var.location
  subnet_id           = data.azurerm_subnet.prend_subnet.id
  private_service_connection = {
    is_manual_connection           = false
    private_connection_resource_id = module.cosmosdb_account.id
    subresource_names              = ["sql"]
    request_message                = null
  }
}

#############################################################################################
# Configure Alerts for AKS
#############################################################################################
# Create monitor action group
module "monitor_action_group" {
  source                      = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.monitor_action_group?ref=develop"
  for_each                    = { for action_group in var.monitor_action_groups : action_group.action_group_name => action_group }
  depends_on                  = [
    module.app_insights,
    module.aks
  ]
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

# Create alerts
module "alerts" {
  source                      = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.alerts?ref=develop"
  depends_on                  = [
    module.monitor_action_group,
    module.aks
  ]
  for_each                    = { for alert in var.alerts : alert.action_group_name => alert }
  action_group_rg_name        = each.value.action_group_rg_name
  action_group_name           = each.value.action_group_name
  azuremonitor_rg_name        = try(each.value.azuremonitor_rg_name, null)
  log_analytics_workspace_id  = try(each.value.log_analytics_workspace_id, null)
  metric_alert                = try(each.value.metric_alert, [])
  scheduled_query_rules_alert = try(each.value.scheduled_query_rules_alert, [])
  tags                        = try(each.value.tags, {})
}

#############################################################################################
# Deploy Application Insights
#############################################################################################
module "app_insights" {
  source = "git::https://#{org_name}#@dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#//iac/terraform/terraform.azurerm.app_insights?ref=develop"
  depends_on = [
    module.rg_la,
    module.aks
  ]
  appinsights_name           = var.app_insights.appinsights_name
  location                   = var.location
  rg_name                    = var.app_insights.rg_name
  application_type           = var.app_insights.application_type
  workspace_id               = try(var.app_insights.workspace_id, null)
  retention_in_days          = try(var.app_insights.retention_in_days, 90)
  sampling_percentage        = try(var.app_insights.sampling_percentage, null)
  disable_ip_masking         = try(var.app_insights.disable_ip_masking, false)
  internet_ingestion_enabled = try(var.app_insights.internet_ingestion_enabled, true)
  internet_query_enabled     = try(var.app_insights.internet_query_enabled, true)
  tags                       = lookup(var.app_insights, "tags", {})
}
