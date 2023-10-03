# Get resource group data
data "azurerm_resource_group" "rg" {
  count = var.location == null ? 1 : 0
  name  = var.rg_name
}

# Creates AKS
#tfsec:ignore:azure-container-logging
#tfsec:ignore:azure-container-limit-authorized-ips
resource "azurerm_kubernetes_cluster" "k8s" {
  name                                = var.cluster_name
  location                            = var.location == null ? data.azurerm_resource_group.rg[0].location : var.location
  resource_group_name                 = var.rg_name
  dns_prefix                          = var.dns_prefix == null ? format("%s-%s", var.cluster_name, var.location) : var.dns_prefix
  private_cluster_enabled             = var.private_cluster_enabled
  node_resource_group                 = "${var.rg_name}-node"
  oidc_issuer_enabled                 = var.oidc_issuer_enabled
  workload_identity_enabled           = var.workload_identity_enabled
  kubernetes_version                  = var.kubernetes_version == null ? null : var.kubernetes_version
  role_based_access_control_enabled   = var.role_based_access_control_enabled
  automatic_channel_upgrade           = var.automatic_channel_upgrade
  azure_policy_enabled                = var.azure_policy_enabled
  local_account_disabled              = var.local_account_disabled
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  public_network_access_enabled       = var.public_network_access_enabled

  default_node_pool {
    name = try(var.default_node_pool.name, "default")
    # If enable_auto_scaling enabled, we must to ignore changes to the node_count field.
    # Because  we cannot change `node_count` when `enable_auto_scaling` is set to `true`
    node_count                  = try(var.default_node_pool.enable_auto_scaling, false) == true ? null : try(var.default_node_pool.node_count, 1)
    vm_size                     = try(var.default_node_pool.vm_size, "Standard_DS2_v2")
    os_disk_size_gb             = try(var.default_node_pool.os_disk_size_gb, null)
    os_disk_type                = try(var.default_node_pool.os_disk_type, "Managed")
    os_sku                      = try(var.default_node_pool.os_sku, null)
    temporary_name_for_rotation = try(var.default_node_pool.temporary_name_for_rotation, null) != null ? var.default_node_pool.temporary_name_for_rotation : lower(format("%s%s", try(var.default_node_pool.name, "default"), "tmp"))
    type                        = try(var.default_node_pool.type, "VirtualMachineScaleSets")
    zones                       = try(var.default_node_pool.zones, [])
    enable_node_public_ip       = try(var.default_node_pool.enable_node_public_ip, false)
    enable_auto_scaling         = try(var.default_node_pool.enable_auto_scaling, false)
    enable_host_encryption      = try(var.default_node_pool.enable_host_encryption, false)
    max_count                   = try(var.default_node_pool.enable_auto_scaling, false) == true ? try(var.default_node_pool.max_count, null) : null
    min_count                   = try(var.default_node_pool.enable_auto_scaling, false) == true ? try(var.default_node_pool.min_count, null) : null
    max_pods                    = try(var.default_node_pool.max_pods, null)
    vnet_subnet_id              = try(var.default_node_pool.vnet_subnet_id, null)
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.aad_rbac != null ? ["aad_rbac"] : []
    content {
      tenant_id              = try(var.aad_rbac.tenant_id, null)
      managed                = try(var.aad_rbac.managed, true)
      azure_rbac_enabled     = try(var.aad_rbac.azure_rbac_enabled, true)
      client_app_id          = try(var.aad_rbac.managed, null) ? null : var.aad_rbac.client_app_id
      server_app_id          = try(var.aad_rbac.managed, null) ? null : var.aad_rbac.server_app_id
      server_app_secret      = try(var.aad_rbac.managed, null) ? null : var.aad_rbac.server_app_secret
      admin_group_object_ids = try(var.aad_rbac.managed, null) ? var.aad_rbac.admin_group_object_ids : null
    }
  }

  auto_scaler_profile {
    balance_similar_node_groups      = var.balance_similar_node_groups
    max_graceful_termination_sec     = var.max_graceful_termination_sec
    scale_down_delay_after_add       = var.scale_down_delay_after_add
    scale_down_delay_after_failure   = var.scale_down_delay_after_failure
    scan_interval                    = var.scan_interval
    scale_down_unneeded              = var.scale_down_unneeded
    scale_down_unready               = var.scale_down_unready
    scale_down_utilization_threshold = var.scale_down_utilization_threshold
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider != null ? ["key_vault_secrets_provider"] : []
    content {
      secret_rotation_enabled  = var.key_vault_secrets_provider.secret_rotation_enabled
      secret_rotation_interval = var.key_vault_secrets_provider.secret_rotation_interval
    }
  }

  dynamic "http_proxy_config" {
    for_each = var.http_proxy_config != null ? ["http_proxy_config"] : []
    content {
      http_proxy  = var.http_proxy_config.http_proxy
      https_proxy = var.http_proxy_config.https_proxy
      no_proxy    = var.http_proxy_config.no_proxy
      trusted_ca  = var.http_proxy_config.trusted_ca
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    pod_cidr           = var.network_plugin == "azure" ? null : var.pod_cidr
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    load_balancer_sku  = var.load_balancer_sku
    docker_bridge_cidr = var.docker_bridge_cidr
  }
  # one of either identity or service_principal blocks must be specified
  dynamic "service_principal" {
    for_each = var.client_id != null && var.client_secret != null ? [1] : []
    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }
  # one of either identity or service_principal blocks must be specified
  dynamic "identity" {
    for_each = var.client_id == null && var.client_secret == null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile != null ? ["api_server_access_profile"] : []
    content {
      authorized_ip_ranges     = var.public_network_access_enabled == true ? ["0.0.0.0/0"] : try(var.api_server_access_profile.authorized_ip_ranges, [])
      subnet_id                = try(var.api_server_access_profile.subnet_id, null)
      vnet_integration_enabled = try(var.api_server_access_profile.vnet_integration_enabled, false)
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway != null ? ["ingress_application_gateway"] : []
    content {
      gateway_id   = var.ingress_application_gateway.gateway_id
      gateway_name = var.ingress_application_gateway.gateway_name
      subnet_cidr  = var.ingress_application_gateway.subnet_cidr
      subnet_id    = var.ingress_application_gateway.subnet_id
    }
  }
  ### Enable monitoring for AKS
  dynamic "oms_agent" {
    for_each = var.la_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.la_workspace_id
    }
  }

  dynamic "storage_profile" {
    for_each = var.storage_profile != null ? ["storage_profile"] : []
    content {
      blob_driver_enabled         = var.storage_profile.blob_driver_enabled
      disk_driver_enabled         = var.storage_profile.disk_driver_enabled
      disk_driver_version         = var.storage_profile.disk_driver_version
      file_driver_enabled         = var.storage_profile.file_driver_enabled
      snapshot_controller_enabled = var.storage_profile.snapshot_controller_enabled
    }
  }

  tags = var.tags

  dynamic "web_app_routing" {
    for_each = var.dns_zone_id != null ? ["web_app_routing"] : []
    content {
      dns_zone_id = var.dns_zone_id
    }
  }

  lifecycle {
    precondition {
      condition     = (var.client_id != "" && var.client_secret != "") || (var.identity_type != "")
      error_message = "Either `client_id` and `client_secret` or `identity_type` must be set."
    }

    precondition {
      condition     = (var.workload_identity_enabled == false) || (var.workload_identity_enabled == true && var.oidc_issuer_enabled == true)
      error_message = "To enable Azure AD Workload Identity oidc_issuer_enabled must be set to true."
    }
  }
}

# Creates additional node pool(s)
resource "azurerm_kubernetes_cluster_node_pool" "additional_node_pools" {
  for_each              = { for node_pool in var.node_pools : node_pool.name => node_pool }
  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  # If enable_auto_scaling enabled, we must to ignore changes to the node_count field.
  # Because  we cannot change `node_count` when `enable_auto_scaling` is set to `true`
  node_count             = lookup(each.value, "enable_auto_scaling", false) == true ? null : try(each.value.node_count, 1)
  vm_size                = lookup(each.value, "vm_size", null) == null ? "Standard_Ds2_v2" : each.value.vm_size
  os_disk_size_gb        = lookup(each.value, "os_disk_size_gb", null)
  os_disk_type           = lookup(each.value, "os_disk_type", "Managed") == null ? null : each.value.os_disk_type
  os_sku                 = lookup(each.value, "os_sku", null) == null ? null : each.value.os_sku
  zones                  = length(lookup(each.value, "zones", 0)) == 0 ? [] : each.value.zones
  enable_node_public_ip  = lookup(each.value, "enable_node_public_ip", false)
  enable_auto_scaling    = lookup(each.value, "enable_auto_scaling", false)
  enable_host_encryption = lookup(each.value, "enable_host_encryption", false)
  max_count              = lookup(each.value, "enable_auto_scaling", null) == true ? each.value.max_count : null
  min_count              = lookup(each.value, "enable_auto_scaling", null) == true ? each.value.min_count : null
  max_pods               = lookup(each.value, "max_pods", null) == null ? null : each.value.max_pods
  vnet_subnet_id         = lookup(each.value, "vnet_subnet_id", null) == null ? null : each.value.vnet_subnet_id
}

# Manages a diagnostic setting for created AKS
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_setting != null ? 1 : 0

  name                           = var.diagnostic_setting.name
  target_resource_id             = azurerm_kubernetes_cluster.k8s.id
  log_analytics_workspace_id     = var.diagnostic_setting.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_setting.storage_account_id
  eventhub_name                  = var.diagnostic_setting.eventhub_name
  eventhub_authorization_rule_id = var.diagnostic_setting.eventhub_authorization_rule_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_setting.enabled_log != null ? toset(var.diagnostic_setting.enabled_log) : []
    content {
      category = enabled_log.key
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_setting.metric != null ? toset(var.diagnostic_setting.metric) : []
    content {
      category = metric.key
    }
  }
}
