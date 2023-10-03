# terraform.azurerm.aks

This module creates an Azure Kubernetes Service (AKS)

## Prerequisites

| Resource name | Required | Description |
|---------------|----------|-------------|
| resource group        | yes   |       |
| VNET with subnets     | no   | Required in case connection to the existing subnet      |
| Application gateway     | no   |  In case using integration with Application Gateway    |
| Key Vault     | no   |  In case using integration with Key Vault   |
| Azure Private DNS     | no   |  In case using Azure Private DNS integration   |
| Azure Active Directory Application     | no   |  In case using AAD RBAC integration     |
| Azure Active Directory Groups     | no   |   In case using AAD RBAC integration    |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.56.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.56.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.k8s](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.additional_node_pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |



## Usage example

```go
module "aks" {
  source                              = "git::https://ORGANIZATION_NAME@dev.azure.com/ORGANIZATION_NAME/PROJECT_NAME/_git/terraform.azurerm.aks?ref=v4.1.0"
  location                            = "eastus"
  rg_name                             = "epam-rg-noeu-h-aks-03"
  cluster_name                        = "epam-rg-noeu-s-aks-cluster"
  dns_prefix                          = "epam-rg-noeu-s-aks"
  oidc_issuer_enabled                 = false
  workload_identity_enabled           = false
  private_cluster_enabled             = false
  kubernetes_version                  = "1.23.8"
  automatic_channel_upgrade           = "stable"
  azure_policy_enabled                = false
  local_account_disabled              = false
  private_cluster_public_fqdn_enabled = false
  private_dns_zone_id                 = "System"
  public_network_access_enabled       = true
  load_balancer_sku                   = "standard"

  ingress_application_gateway = {
    gateway_id   = "/subscriptions/subid/resourceGroups/rg1/providers/Microsoft.Network/applicationGateways/appgw"
    gateway_name = "myApplicationGateway"
    subnet_cidr  = "10.225.0.0/16"
    subnet_id    = "/subscriptions/{Subscription ID}/resourceGroups/MyResourceGroup/providers/Microsoft.Network/virtualNetworks/MyNet/subnets/MySubnet"
  }

  key_vault_secrets_provider = {
    secret_rotation_enabled  = false
    secret_rotation_interval = "2m"
  }

  http_proxy_config = {
    http_proxy  = "http://example.com:8080/"
    https_proxy = "http://example.com:8080/"
    no_proxy    = ["localhost", "127.0.0.1"]
    trusted_ca  = "The base64 encoded alternative CA certificate content in PEM format."
  }

  storage_profile = {
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    disk_driver_version         = "v2"
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }

  # client_id and client_secret or identity_type parameters must be specified.
  # identity_ids used in case UserAssigned identity_type
  client_id     = "1234example4321"
  client_secret = "examplepassword"
  identity_type = ["SystemAssigned"]
  identity_ids  = []

  # Enable Kubernetes native RBAC. Kubernetes RBAC or Azure RBAC must be used.
  role_based_access_control_enabled = true

  # Enable Azure RBAC. Kubernetes RBAC or Azure RBAC must be used.
  aad_rbac = {
    azure_rbac_enabled     = true
    managed                = false
    admin_group_object_ids = null
    client_app_id          = "000-my-client-app-id-000"
    server_app_id          = "000-my-server-app-id-000"
    server_app_secret      = "000-my-server-app-sec-000"
    tenant_id              = "88888888-0000-1111-cccc-121212121212"
  }

  # Authorized ip ranges and subnets for the AKS API server
  api_server_access_profile = {
    authorized_ip_ranges     = ["198.51.100.0/24"]
    subnet_id                = null
    vnet_integration_enabled = false
  }

  # OMS agents with Log Analytics workspace
  la_workspace_id = null

  # Default node pool
  default_node_pool = {
    name                        = "default"
    node_count                  = 1
    vm_size                     = "Standard_DS2_v2"
    os_disk_size_gb             = 100
    os_disk_type                = "Managed"
    os_sku                      = "Ubuntu"
    temporary_name_for_rotation = "tmp"
    type                        = "VirtualMachineScaleSets"
    zones                       = []
    enable_node_public_ip       = true
    enable_auto_scaling         = false
    enable_host_encryption      = true
    max_count                   = 3
    min_count                   = 1
    max_pods                    = 60
    vnet_subnet_id              = "/subscriptions/8d0c064d-0000-1111-2222-665e94f4954d/resourceGroups/com-acm/providers/Microsoft.Network/virtualNetworks/com-acm-weeu-vnet/subnets/com-acm-weeu-subnet"
  }

  # Additional node pools
  node_pools = [
    {
      name                   = "pool1"
      node_count             = 3
      vm_size                = "Standard_DS2_v2"
      os_disk_size_gb        = 100
      os_disk_type           = "Managed"
      os_sku                 = "Ubuntu"
      zones                  = []
      enable_node_public_ip  = true
      enable_auto_scaling    = false
      enable_host_encryption = false
      max_count              = 3
      min_count              = 1
      max_pods               = 60
      vnet_subnet_id         = "/subscriptions/8d0c064d-0000-1111-2222-665e94f4954d/resourceGroups/com-acm/providers/Microsoft.Network/virtualNetworks/com-acm-weeu-vnet/subnets/com-acm-weeu-subnet"
    },
    {
      name            = "pool2"
      node_count      = 2
      vm_size         = "Standard_DS2_v2"
      os_disk_size_gb = 128
      zones           = ["1", "2", "3"]
      max_pods        = 120
    }
  ]

  # Auto scaler profile
  balance_similar_node_groups      = false
  max_graceful_termination_sec     = "600"
  scale_down_delay_after_add       = "10m"
  scale_down_delay_after_failure   = "3m"
  scan_interval                    = "10s"
  scale_down_unneeded              = "10m"
  scale_down_unready               = "20m"
  scale_down_utilization_threshold = "0.5"

  # Diagnostic settings configuration
  diagnostic_setting = {
    name               = "kube-api-audit-log-allmetrics"
    storage_account_id = "/subscriptions/12345678-0123-3210-5467-3a2dcfcf84a1/resourceGroups/rg-example/providers/Microsoft.Storage/storageAccounts/stexample"
    enabled_log        = ["kube-apiserver", "kube-audit"]
    metric             = ["AllMetrics"]
  }

  # Network configuration
  network_plugin     = "kubenet"
  network_policy     = null
  pod_cidr           = null
  service_cidr       = null
  dns_service_ip     = null
  docker_bridge_cidr = null

  tags = {
    environment = "production"
    deployedBy  = "Terraform"
    foo         = "bar"
  }

  dns_zone_id = null
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_rbac"></a> [aad\_rbac](#input\_aad\_rbac) | Variable configure Role Based Access Control based on Azure Active Directory. Keys and value explanation:<br>    `managed`: Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the<br>    Service Principal used for integration. Valid values are: `true, false`.<br>    `tenant_id`: The Tenant ID used for Azure Active Directory Application.<br>    When `managed` is set to true the following properties can be specified:<br>      `admin_group_object_ids`: A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster.<br>      `azure_rbac_enabled`: Is Role Based Access Control based on Azure AD enabled? Valid values are: `true, false`.<br>    When managed is set to false the following properties can be specified:<br>      `server_app_secret`: The Server Secret of an Azure Active Directory Application.<br>      `server_app_id`: The Server ID of an Azure Active Directory Application.<br>      `client_app_id`: The Client ID of an Azure Active Directory Application.<br>    See more:<br>    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#azure_active_directory_role_based_access_control | <pre>object({<br>    managed                = optional(bool, true)<br>    tenant_id              = optional(string)<br>    admin_group_object_ids = optional(list(string))<br>    azure_rbac_enabled     = optional(bool, true)<br>    server_app_secret      = optional(string)<br>    server_app_id          = optional(string)<br>    client_app_id          = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_api_server_access_profile"></a> [api\_server\_access\_profile](#input\_api\_server\_access\_profile) | An `api_server_access_profile` block supports the following:<br>    object({<br>      `authorized_ip_ranges` - (Optional) Set of authorized IP ranges to allow access to API server, e.g. ["198.51.100.0/24"].<br>      `subnet_id` - (Optional) The ID of the Subnet where the API server endpoint is delegated to.<br>      `vnet_integration_enabled` - (Optional) Should API Server VNet Integration be enabled? For more details please <br>      visit Use API Server VNet Integration.<br>    }) | <pre>object({<br>    authorized_ip_ranges     = optional(list(string))<br>    subnet_id                = optional(string)<br>    vnet_integration_enabled = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_automatic_channel_upgrade"></a> [automatic\_channel\_upgrade](#input\_automatic\_channel\_upgrade) | The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. By default<br>    automatic-upgrades are turned off. Note that you cannot specify the patch version using `kubernetes_version` or <br>    `orchestrator_version` when using the `patch` upgrade channel. See [the documentation](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster)<br>    for more information | `string` | `null` | no |
| <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled) | Enable Azure Policy Addon. | `bool` | `false` | no |
| <a name="input_balance_similar_node_groups"></a> [balance\_similar\_node\_groups](#input\_balance\_similar\_node\_groups) | Detect similar node groups and balance the number of nodes between them. Defaults to false. | `bool` | `false` | no |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | The Client ID for the Service Principal. One of either identity or service\_principal<br>    parameters must be specified. | `string` | `null` | no |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | The Client Secret for the Service Principal. One of either identity or service\_principal<br>    parameters must be specified | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Specifies the name of the AKS. | `string` | n/a | yes |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Map that describes AKS default node pool<br>    Keys and value explanation:<br>    `name`: The name which should be used for the default Kubernetes Node Pool. Changing this forces<br>    a new resource to be created. By default pool named "default".<br>    `node_count`: The initial number of nodes which should exist in this Node Pool. If specified this<br>    must be between 1 and 1000 and between `max_count` and `min_count`. Default value - 1. Will be <br>    ignored if `enable_auto_scaling` enabled.<br>    `vm_size`: The size of the Virtual Machine, such as Standard\_DS2\_v2. Changing this forces a new<br>    resource to be created. Default value - Standard\_DS2\_v2.<br>    `os_disk_size_gb`: The size of the OS Disk which should be used for each agent in the Node Pool.<br>    Changing this forces a new resource to be created. Default value - `null`.<br>    `os_disk_type`: The type of disk which should be used for the Operating System. Possible values<br>    are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created.<br>    `os_sku`: Specifies the OS SKU used by the agent pool. Possible values include: `Ubuntu`, `CBLMariner`,<br>    `Mariner`, `Windows2019`, `Windows2022`. If not specified, the default is `Ubuntu` if `OSType=Linux` or<br>    `Windows2019` if `OSType=Windows`. And the default `Windows OSSKU` will be changed to Windows2022 after<br>    `Windows2019` is deprecated. Changing this forces a new resource to be created.<br>    `temporary_name_for_rotation`: Specifies the name of the temporary node pool used to cycle the<br>    default node pool for VM resizing.<br>    `type`: The type of Node Pool which should be created. Possible values are `AvailabilitySet` and<br>    `VirtualMachineScaleSets`. Defaults to `VirtualMachineScaleSets`. Changing this forces a new resource<br>    to be created.<br>    `zones`: Specifies a list of Availability Zones in which this Kubernetes Cluster<br>    should be located. Changing this forces a new Kubernetes Cluster to be created. Default value - `null`.<br>    `enable_node_public_ip`: Should nodes in this Node Pool have a Public IP Address? Defaults value - false.<br>    `enable_auto_scaling`: Should the Kubernetes Auto Scaler be enabled for this Node Pool? Defaults to false.<br>    `enable_host_encryption`: Should encryption on host have enabled? Defaults to false.<br>    `max_count`: The maximum number of nodes which should exist in this Node Pool. If specified this must be<br>    between 1 and 1000. Default value - `null`.<br>    `min_count`: he minimum number of nodes which should exist in this Node Pool. If specified this must be<br>    between 1 and 1000. Default value - `null`.<br>    `max_pods`: The maximum number of pods that can run on each node. Changing this forces a new resource<br>    to be created. Default value - `null`.<br>    `vnet_subnet_id` - The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces <br>    a new resource to be created. | <pre>object({<br>    name                        = optional(string, "default")<br>    node_count                  = optional(number, 1)<br>    vm_size                     = optional(string, "Standard_DS2_v2")<br>    os_disk_size_gb             = optional(string)<br>    os_disk_type                = optional(string, "Managed")<br>    os_sku                      = optional(string)<br>    temporary_name_for_rotation = optional(string)<br>    type                        = optional(string, "VirtualMachineScaleSets")<br>    zones                       = optional(list(string), [])<br>    enable_node_public_ip       = optional(bool, false)<br>    enable_auto_scaling         = optional(bool, false)<br>    enable_host_encryption      = optional(bool, false)<br>    max_count                   = optional(number)<br>    min_count                   = optional(number)<br>    max_pods                    = optional(number)<br>    vnet_subnet_id              = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_diagnostic_setting"></a> [diagnostic\_setting](#input\_diagnostic\_setting) | The description of parameters for Diagnostic Setting:<br>    `diagnostic_setting_name`    - specifies the name of the Diagnostic Setting;<br>    `log_analytics_workspace_id` - ID of the Log Analytics Workspace;<br>    `eventhub_name` - Specifies the name of the Event Hub where Diagnostics Data should be sent;<br>    `eventhub_authorization_rule_id` - Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data;<br>    `storage_account_id`         - the ID of the Storage Account where logs should be sent;<br>    `enabled_log`                        - describes logs for Diagnistic Setting: <br>      `category`         - the name of a Diagnostic Log Category for this Resource. list of available logs: kube-apiserver, kube-audit, kube-audit-admin, kube-controller-manager, kube-scheduler, cluster-autoscaler, cloud-controller-manager, guard, csi-azuredisk-controller, csi-azurefile-controller, csi-snapshot-controller;<br>      `retention_policy` - describes logs retention policy (needed to store data in the Storage Account):<br>        `enabled` - is this Retention Policy enabled?<br>        `days`    - the number of days for which this Retention Policy should apply.<br>    `metric`             - describes metric for Diagnistic Setting:<br>      `category`  -  the name of a Diagnostic Metric Category for this Resource. List of available Metrics: AllMetrics ;<br>      `retention_policy` - describes Metric retention policy (needed to store data in the Storage Account):<br>        `enabled` - is this Retention Policy enabled?;<br>        `days`    - the number of days for which this Retention Policy should apply. | <pre>object({<br>    name                           = string<br>    log_analytics_workspace_id     = optional(string)<br>    storage_account_id             = optional(string)<br>    eventhub_name                  = optional(string)<br>    eventhub_authorization_rule_id = optional(string)<br>    enabled_log                    = optional(list(string))<br>    metric                         = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_dns_prefix"></a> [dns\_prefix](#input\_dns\_prefix) | DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created.<br>    The dns\_prefix must contain between 3 and 45 characters, and can contain only letters, numbers, and hyphens.<br>    It must start with a letter and must end with a letter or a number. If not specified - `dns_prefix` will be<br>    formated as `cluster_name` + `location`. | `string` | `null` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). | `string` | `null` | no |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | Specifies the ID of the DNS Zone in which DNS entries are created for applications deployed to the cluster when<br>    Web App Routing is enabled. For Bring-Your-Own DNS zones this property should be set to an empty string `""`.<br>    Used by web\_app\_routing block. | `string` | `null` | no |
| <a name="input_docker_bridge_cidr"></a> [docker\_bridge\_cidr](#input\_docker\_bridge\_cidr) | IP address (in CIDR notation) used as the Docker bridge IP address on nodes. | `string` | `null` | no |
| <a name="input_http_proxy_config"></a> [http\_proxy\_config](#input\_http\_proxy\_config) | AKS HTTP/HTTPS proxy configuration, disabled by default. Keys and value explanation:<br>    `http_proxy`: The proxy address to be used when communicating over HTTP. Changing this forces a new resource to be created.<br>    `https_proxy`: The proxy address to be used when communicating over HTTPS. Changing this forces a new resource to be created.<br>    `no_proxy`: The list of domains that will not use the proxy for communication.<br>    `trusted_ca`: The base64 encoded alternative CA certificate content in PEM format. | <pre>object({<br>    http_proxy  = optional(string)<br>    https_proxy = optional(string)<br>    no_proxy    = optional(list(string))<br>    trusted_ca  = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster. One of either <br>    identity or service principal parameters must be specified. | `list(any)` | `null` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Specifies the type of Managed Service Identity that should be configured on this Kubernetes Cluster. Possible values are<br>    SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both). One of either identity or service\_principal<br>    parameters must be specified. | `string` | `"SystemAssigned"` | no |
| <a name="input_ingress_application_gateway"></a> [ingress\_application\_gateway](#input\_ingress\_application\_gateway) | AKS HTTP/HTTPS proxy configuration, disabled by default. Keys and value explanation:<br>    `gateway_id`: The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster. See<br>    this page for further details: https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing<br>    `gateway_name`: The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be<br>    integrated with the ingress controller of this Kubernetes Cluster. See this page for further details:<br>    https://docs.microsoft.com/azure/application-gateway/tutorial-ingress-controller-add-on-new<br>    `subnet_cidr`: The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller<br>    of this Kubernetes Cluster. <br>    See this page for further details: https://docs.microsoft.com/azure/application-gateway/tutorial-ingress-controller-add-on-new<br>    `subnet_id`: The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller<br>    of this Kubernetes Cluster. <br>    See this page for further details: https://docs.microsoft.com/azure/application-gateway/tutorial-ingress-controller-add-on-new<br><br>    To create an Application Gateway automatically with all required permissions for the AKS inside of nodepool resource group -<br>    `gateway_name` and (`subnet_cidr` or `subnet_id`) must be provided. `subnet_cidr` must be used for dynamic subnet provisioning in the VNET<br>    that will be created by AKS itself. To integrate AKS with existing Application Gateway you must use `gateway_id` parameter only assuming<br>    that you have given appropriate permissions. | <pre>object({<br>    gateway_id   = optional(string)<br>    gateway_name = optional(string)<br>    subnet_cidr  = optional(string)<br>    subnet_id    = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_key_vault_secrets_provider"></a> [key\_vault\_secrets\_provider](#input\_key\_vault\_secrets\_provider) | To enable `key_vault_secrets_provider` either `secret_rotation_enabled` or `secret_rotation_interval` must be specified.<br>    Keys and value explanation:<br>    `secret_rotation_enabled`: (Optional) Should the secret store CSI driver on the AKS cluster be enabled?<br>    `secret_rotation_interval`: (Optional) The interval to poll for secret rotation. This attribute is only set when `secret_rotation`<br>    is `true` and defaults to `2m` | <pre>object({<br>    secret_rotation_enabled  = optional(bool, false)<br>    secret_rotation_interval = optional(string, "2m")<br>  })</pre> | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest<br>    recommended version will be used at provisioning time (but won't auto-upgrade). AKS does not require an exact <br>    patch version to be specified, minor version aliases such as 1.22 are also supported. - The minor version's latest<br>    GA patch is automatically chosen in that case. | `string` | `null` | no |
| <a name="input_la_workspace_id"></a> [la\_workspace\_id](#input\_la\_workspace\_id) | The ID of the Log Analytics Workspace which the OMS Agent should send data to. | `string` | `null` | no |
| <a name="input_load_balancer_sku"></a> [load\_balancer\_sku](#input\_load\_balancer\_sku) | Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`.<br>    Defaults to `standard`. Changing this forces a new kubernetes cluster to be created. | `string` | `"standard"` | no |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | If `true` local accounts will be disabled. Defaults to `false`. See [the documentation](https://docs.microsoft.com/azure/aks/managed-aad#disable-local-accounts)<br>    for more information. | `bool` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists. If not specified - RG location will be used. | `string` | `null` | no |
| <a name="input_max_graceful_termination_sec"></a> [max\_graceful\_termination\_sec](#input\_max\_graceful\_termination\_sec) | Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node.<br>    Defaults to 600. | `number` | `"600"` | no |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | Network plugin to use for networking. Currently supported values are azure, kubenet and none. | `string` | `"kubenet"` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods.<br>    Currently supported values are `calico` and `azure`. Changing this forces a new resource to be created.<br>    When network\_policy is set to `azure`, the network\_plugin field can only be set to `azure`. | `string` | `null` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Map that describes AKS additional node pool(s). You may add one or more additional node pools to <br>    the Kubernetes cluster. Keys and value explanation:<br>    `name`: The Node Pool name.<br>    `node_count`: The initial number of nodes which should exist in this Node Pool. If specified this<br>    must be between 1 and 1000 and between `max_count` and `min_count`. Default value - 1. Will be <br>    ignored if `enable_auto_scaling` enabled.<br>    `vm_size`: The size of the Virtual Machine, such as Standard\_DS2\_v2. Changing this forces a new<br>    resource to be created. Default value - Standard\_DS2\_v2.<br>    `os_disk_size_gb`: The size of the OS Disk which should be used for each agent in the Node Pool.<br>    Changing this forces a new resource to be created. Default value - `null`.<br>    `os_disk_type`: The type of disk which should be used for the Operating System. Possible values<br>    are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created.<br>    `os_sku`: Specifies the OS SKU used by the agent pool. Possible values include: `Ubuntu`, `CBLMariner`,<br>    `Mariner`, `Windows2019`, `Windows2022`. If not specified, the default is `Ubuntu` if `OSType=Linux` or<br>    `Windows2019` if `OSType=Windows`. And the default `Windows OSSKU` will be changed to Windows2022 after<br>    `Windows2019` is deprecated. Changing this forces a new resource to be created.<br>    `zones`: Specifies a list of Availability Zones in which this Kubernetes Cluster<br>    should be located. Changing this forces a new Kubernetes Cluster to be created. Default value - `null`.<br>    `enable_node_public_ip`: Should nodes in this Node Pool have a Public IP Address? Defaults value - false.<br>    `enable_auto_scaling`: Should the Kubernetes Auto Scaler be enabled for this Node Pool? Defaults to false.<br>    `enable_host_encryption`: Should encryption on host have enabled? Defaults to false.<br>    `max_count`: The maximum number of nodes which should exist in this Node Pool. If specified this must be<br>    between 1 and 1000. Default value - `null`.<br>    `min_count`: he minimum number of nodes which should exist in this Node Pool. If specified this must be<br>    between 1 and 1000. Default value - `null`.<br>    `max_pods`: The maximum number of pods that can run on each node. Changing this forces a new resource<br>    to be created. Default value - `null`.<br>    `vnet_subnet_id` - The ID of the Subnet where this Node Pool should exist. Changing this forces a new <br>    resource to be created. | <pre>list(object({<br>    name                   = optional(string, "default")<br>    node_count             = optional(number, 1)<br>    vm_size                = optional(string, "Standard_DS2_v2")<br>    os_disk_size_gb        = optional(string)<br>    os_disk_type           = optional(string, "Managed")<br>    os_sku                 = optional(string)<br>    zones                  = optional(list(string), [])<br>    enable_node_public_ip  = optional(bool, false)<br>    enable_auto_scaling    = optional(bool, false)<br>    enable_host_encryption = optional(bool, false)<br>    max_count              = optional(number)<br>    min_count              = optional(number)<br>    max_pods               = optional(number)<br>    vnet_subnet_id         = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Enable or Disable the OIDC issuer URL to enable Azure AD Workload Identity. | `bool` | `false` | no |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | The CIDR to use for pod IP addresses. This field can only be set when network\_plugin is set to kubenet. | `string` | `null` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Should this Kubernetes Cluster have its API server only exposed on internal IP addresses?<br>    This provides a Private IP Address for the Kubernetes API on the Virtual Network where<br>    the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource<br>    to be created. | `bool` | `false` | no |
| <a name="input_private_cluster_public_fqdn_enabled"></a> [private\_cluster\_public\_fqdn\_enabled](#input\_private\_cluster\_public\_fqdn\_enabled) | Specifies whether a Public FQDN for this Private Cluster should be added. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Either the ID of Private DNS Zone which should be delegated to this Cluster, `System` to have AKS manage this or `None`.<br>    In case of `None` you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after<br>    provisioning. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is allowed for this Kubernetes Cluster. Defaults to `true`. Changing this forces a new resource<br>    to be created. | `bool` | `true` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group in which to create the AKS. | `string` | n/a | yes |
| <a name="input_role_based_access_control_enabled"></a> [role\_based\_access\_control\_enabled](#input\_role\_based\_access\_control\_enabled) | Enable or not general rbac functionality for kubernetes cluster. | `bool` | `true` | no |
| <a name="input_scale_down_delay_after_add"></a> [scale\_down\_delay\_after\_add](#input\_scale\_down\_delay\_after\_add) | How long after the scale up of AKS nodes the scale down evaluation resumes. Defaults to 10m. | `string` | `"10m"` | no |
| <a name="input_scale_down_delay_after_failure"></a> [scale\_down\_delay\_after\_failure](#input\_scale\_down\_delay\_after\_failure) | How long after scale down failure that scale down evaluation resumes. Defaults to 3m. | `string` | `"3m"` | no |
| <a name="input_scale_down_unneeded"></a> [scale\_down\_unneeded](#input\_scale\_down\_unneeded) | How long a node should be unneeded before it is eligible for scale down. Defaults to 10m. | `string` | `"10m"` | no |
| <a name="input_scale_down_unready"></a> [scale\_down\_unready](#input\_scale\_down\_unready) | How long an unready node should be unneeded before it is eligible for scale down. Defaults to 20m. | `string` | `"20m"` | no |
| <a name="input_scale_down_utilization_threshold"></a> [scale\_down\_utilization\_threshold](#input\_scale\_down\_utilization\_threshold) | Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered<br>    for scale down. Defaults to 0.5. | `number` | `"0.5"` | no |
| <a name="input_scan_interval"></a> [scan\_interval](#input\_scan\_interval) | How often the AKS Cluster should be re-evaluated for scale up/down. Defaults to 10s. | `string` | `"10s"` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | The Network Range used by the Kubernetes service. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_storage_profile"></a> [storage\_profile](#input\_storage\_profile) | Enable or not the Blob CSI driver. Defaults to `false`. Keys and value explanation:<br>    `blob_driver_enabled`: Is the Blob CSI driver enabled? Defaults to `false`.<br>    `disk_driver_enabled`: Is the Disk CSI driver enabled? Defaults to `true`<br>    `disk_driver_version`: Disk CSI Driver version to be used. Possible values are `v1` and `v2`. Defaults to `v1`.<br>    `file_driver_enabled`: Is the File CSI driver enabled? Defaults to `true`<br>    `snapshot_controller_enabled`: Is the Snapshot Controller enabled? Defaults to `true` | <pre>object({<br>    blob_driver_enabled         = optional(bool, false)<br>    disk_driver_enabled         = optional(bool, true)<br>    disk_driver_version         = optional(string, "v1")<br>    file_driver_enabled         = optional(bool, true)<br>    snapshot_controller_enabled = optional(bool, true)<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Enable or Disable Workload Identity. Defaults to false. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster. |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | Base64 encoded private key used by clients to authenticate to the Kubernetes cluster. |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster. |
| <a name="output_cluster_portal_fqdn"></a> [cluster\_portal\_fqdn](#output\_cluster\_portal\_fqdn) | The FQDN for the Azure Portal resources when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster. |
| <a name="output_host"></a> [host](#output\_host) | The Kubernetes cluster server host. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Kubernetes Managed Cluster. |
| <a name="output_identity"></a> [identity](#output\_identity) | An identity block exports the following:<br>    principal\_id - The Principal ID associated with this Managed Service Identity.<br>    tenant\_id - The Tenant ID associated with this Managed Service Identity. |
| <a name="output_ingress_application_gateway"></a> [ingress\_application\_gateway](#output\_ingress\_application\_gateway) | The `azurerm_kubernetes_cluster`'s `ingress_application_gateway` block. |
| <a name="output_key_vault_secrets_provider"></a> [key\_vault\_secrets\_provider](#output\_key\_vault\_secrets\_provider) | The `azurerm_kubernetes_cluster`'s `key_vault_secrets_provider` block. |
| <a name="output_kube_config_raw"></a> [kube\_config\_raw](#output\_kube\_config\_raw) | Base64 encoded Kubernetes configuration. |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | The Managed Identity to be assigned to the Kubelets. |
| <a name="output_name"></a> [name](#output\_name) | The name of the managed Kubernetes Cluster. |
| <a name="output_network_profile"></a> [network\_profile](#output\_network\_profile) | A network\_profile block as defined below. |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster. |
| <a name="output_node_resource_group_id"></a> [node\_resource\_group\_id](#output\_node\_resource\_group\_id) | The ID of the Resource Group containing the resources for this Managed Kubernetes Cluster. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | The OIDC issuer URL that is associated with the cluster. |
| <a name="output_password"></a> [password](#output\_password) | A password or token used to authenticate to the Kubernetes cluster. |
| <a name="output_username"></a> [username](#output\_username) | A username used to authenticate to the Kubernetes cluster. |