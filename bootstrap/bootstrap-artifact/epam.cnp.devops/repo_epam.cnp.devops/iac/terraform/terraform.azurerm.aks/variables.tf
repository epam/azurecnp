### General variables
variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists. If not specified - RG location will be used."
  default     = null
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group in which to create the AKS."
}
variable "cluster_name" {
  type        = string
  description = "Specifies the name of the AKS."
}
variable "la_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace which the OMS Agent should send data to."
  default     = null
}
variable "dns_prefix" {
  type        = string
  description = <<EOF
    DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created.
    The dns_prefix must contain between 3 and 45 characters, and can contain only letters, numbers, and hyphens.
    It must start with a letter and must end with a letter or a number. If not specified - `dns_prefix` will be
    formated as `cluster_name` + `location`.
    EOF
  default     = null
}
variable "kubernetes_version" {
  type        = string
  description = <<EOF
    Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest
    recommended version will be used at provisioning time (but won't auto-upgrade). AKS does not require an exact 
    patch version to be specified, minor version aliases such as 1.22 are also supported. - The minor version's latest
    GA patch is automatically chosen in that case.
    EOF
  default     = null
}
variable "oidc_issuer_enabled" {
  type        = bool
  description = "Enable or Disable the OIDC issuer URL to enable Azure AD Workload Identity."
  default     = false
}
variable "workload_identity_enabled" {
  type        = bool
  description = "Enable or Disable Workload Identity. Defaults to false."
  default     = false
}
variable "client_id" {
  type        = string
  description = <<EOF
    The Client ID for the Service Principal. One of either identity or service_principal
    parameters must be specified.
    EOF
  default     = null
}
variable "client_secret" {
  type        = string
  description = <<EOF
    The Client Secret for the Service Principal. One of either identity or service_principal
    parameters must be specified
    EOF
  default     = null
  sensitive   = true
}
variable "identity_type" {
  type        = string
  description = <<EOF
    Specifies the type of Managed Service Identity that should be configured on this Kubernetes Cluster. Possible values are
    SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both). One of either identity or service_principal
    parameters must be specified.
    EOF
  default     = "SystemAssigned"
  validation {
    condition     = var.identity_type == "SystemAssigned" || var.identity_type == "UserAssigned"
    error_message = "`identity_type`'s possible values are `SystemAssigned` and `UserAssigned`"
  }
}
variable "identity_ids" {
  type        = list(any)
  description = <<EOF
    Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster. One of either 
    identity or service principal parameters must be specified.
    EOF
  default     = null
}
variable "api_server_access_profile" {
  type = object({
    authorized_ip_ranges     = optional(list(string))
    subnet_id                = optional(string)
    vnet_integration_enabled = optional(bool, false)
  })
  description = <<EOF
    An `api_server_access_profile` block supports the following:
    object({
      `authorized_ip_ranges` - (Optional) Set of authorized IP ranges to allow access to API server, e.g. ["198.51.100.0/24"].
      `subnet_id` - (Optional) The ID of the Subnet where the API server endpoint is delegated to.
      `vnet_integration_enabled` - (Optional) Should API Server VNet Integration be enabled? For more details please 
      visit Use API Server VNet Integration.
    })
    EOF
  default     = null
}
variable "private_cluster_enabled" {
  type        = bool
  description = <<EOF
    Should this Kubernetes Cluster have its API server only exposed on internal IP addresses?
    This provides a Private IP Address for the Kubernetes API on the Virtual Network where
    the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource
    to be created.
    EOF
  default     = false
}
variable "default_node_pool" {
  type = object({
    name                        = optional(string, "default")
    node_count                  = optional(number, 1)
    vm_size                     = optional(string, "Standard_DS2_v2")
    os_disk_size_gb             = optional(string)
    os_disk_type                = optional(string, "Managed")
    os_sku                      = optional(string)
    temporary_name_for_rotation = optional(string)
    type                        = optional(string, "VirtualMachineScaleSets")
    zones                       = optional(list(string), [])
    enable_node_public_ip       = optional(bool, false)
    enable_auto_scaling         = optional(bool, false)
    enable_host_encryption      = optional(bool, false)
    max_count                   = optional(number)
    min_count                   = optional(number)
    max_pods                    = optional(number)
    vnet_subnet_id              = optional(string)
  })
  description = <<EOF
    Map that describes AKS default node pool
    Keys and value explanation:
    `name`: The name which should be used for the default Kubernetes Node Pool. Changing this forces
    a new resource to be created. By default pool named "default".
    `node_count`: The initial number of nodes which should exist in this Node Pool. If specified this
    must be between 1 and 1000 and between `max_count` and `min_count`. Default value - 1. Will be 
    ignored if `enable_auto_scaling` enabled.
    `vm_size`: The size of the Virtual Machine, such as Standard_DS2_v2. Changing this forces a new
    resource to be created. Default value - Standard_DS2_v2.
    `os_disk_size_gb`: The size of the OS Disk which should be used for each agent in the Node Pool.
    Changing this forces a new resource to be created. Default value - `null`.
    `os_disk_type`: The type of disk which should be used for the Operating System. Possible values
    are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created.
    `os_sku`: Specifies the OS SKU used by the agent pool. Possible values include: `Ubuntu`, `CBLMariner`,
    `Mariner`, `Windows2019`, `Windows2022`. If not specified, the default is `Ubuntu` if `OSType=Linux` or
    `Windows2019` if `OSType=Windows`. And the default `Windows OSSKU` will be changed to Windows2022 after
    `Windows2019` is deprecated. Changing this forces a new resource to be created.
    `temporary_name_for_rotation`: Specifies the name of the temporary node pool used to cycle the
    default node pool for VM resizing.
    `type`: The type of Node Pool which should be created. Possible values are `AvailabilitySet` and
    `VirtualMachineScaleSets`. Defaults to `VirtualMachineScaleSets`. Changing this forces a new resource
    to be created.
    `zones`: Specifies a list of Availability Zones in which this Kubernetes Cluster
    should be located. Changing this forces a new Kubernetes Cluster to be created. Default value - `null`.
    `enable_node_public_ip`: Should nodes in this Node Pool have a Public IP Address? Defaults value - false.
    `enable_auto_scaling`: Should the Kubernetes Auto Scaler be enabled for this Node Pool? Defaults to false.
    `enable_host_encryption`: Should encryption on host have enabled? Defaults to false.
    `max_count`: The maximum number of nodes which should exist in this Node Pool. If specified this must be
    between 1 and 1000. Default value - `null`.
    `min_count`: he minimum number of nodes which should exist in this Node Pool. If specified this must be
    between 1 and 1000. Default value - `null`.
    `max_pods`: The maximum number of pods that can run on each node. Changing this forces a new resource
    to be created. Default value - `null`.
    `vnet_subnet_id` - The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces 
    a new resource to be created.
    EOF
  default     = null
}
### Additional node pool variables
variable "node_pools" {
  type = list(object({
    name                   = optional(string, "default")
    node_count             = optional(number, 1)
    vm_size                = optional(string, "Standard_DS2_v2")
    os_disk_size_gb        = optional(string)
    os_disk_type           = optional(string, "Managed")
    os_sku                 = optional(string)
    zones                  = optional(list(string), [])
    enable_node_public_ip  = optional(bool, false)
    enable_auto_scaling    = optional(bool, false)
    enable_host_encryption = optional(bool, false)
    max_count              = optional(number)
    min_count              = optional(number)
    max_pods               = optional(number)
    vnet_subnet_id         = optional(string)
  }))
  description = <<EOF
    Map that describes AKS additional node pool(s). You may add one or more additional node pools to 
    the Kubernetes cluster. Keys and value explanation:
    `name`: The Node Pool name.
    `node_count`: The initial number of nodes which should exist in this Node Pool. If specified this
    must be between 1 and 1000 and between `max_count` and `min_count`. Default value - 1. Will be 
    ignored if `enable_auto_scaling` enabled.
    `vm_size`: The size of the Virtual Machine, such as Standard_DS2_v2. Changing this forces a new
    resource to be created. Default value - Standard_DS2_v2.
    `os_disk_size_gb`: The size of the OS Disk which should be used for each agent in the Node Pool.
    Changing this forces a new resource to be created. Default value - `null`.
    `os_disk_type`: The type of disk which should be used for the Operating System. Possible values
    are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created.
    `os_sku`: Specifies the OS SKU used by the agent pool. Possible values include: `Ubuntu`, `CBLMariner`,
    `Mariner`, `Windows2019`, `Windows2022`. If not specified, the default is `Ubuntu` if `OSType=Linux` or
    `Windows2019` if `OSType=Windows`. And the default `Windows OSSKU` will be changed to Windows2022 after
    `Windows2019` is deprecated. Changing this forces a new resource to be created.
    `zones`: Specifies a list of Availability Zones in which this Kubernetes Cluster
    should be located. Changing this forces a new Kubernetes Cluster to be created. Default value - `null`.
    `enable_node_public_ip`: Should nodes in this Node Pool have a Public IP Address? Defaults value - false.
    `enable_auto_scaling`: Should the Kubernetes Auto Scaler be enabled for this Node Pool? Defaults to false.
    `enable_host_encryption`: Should encryption on host have enabled? Defaults to false.
    `max_count`: The maximum number of nodes which should exist in this Node Pool. If specified this must be
    between 1 and 1000. Default value - `null`.
    `min_count`: he minimum number of nodes which should exist in this Node Pool. If specified this must be
    between 1 and 1000. Default value - `null`.
    `max_pods`: The maximum number of pods that can run on each node. Changing this forces a new resource
    to be created. Default value - `null`.
    `vnet_subnet_id` - The ID of the Subnet where this Node Pool should exist. Changing this forces a new 
    resource to be created.
    EOF
  default     = []
}
### Auto_scaler_profile variables
variable "balance_similar_node_groups" {
  type        = bool
  description = "Detect similar node groups and balance the number of nodes between them. Defaults to false."
  default     = false
}
variable "max_graceful_termination_sec" {
  type        = number
  description = <<EOF
    Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node.
    Defaults to 600.
    EOF
  default     = "600"
}
variable "scale_down_delay_after_add" {
  type        = string
  description = "How long after the scale up of AKS nodes the scale down evaluation resumes. Defaults to 10m."
  default     = "10m"
}
variable "scale_down_delay_after_failure" {
  type        = string
  description = "How long after scale down failure that scale down evaluation resumes. Defaults to 3m."
  default     = "3m"
}
variable "scan_interval" {
  type        = string
  description = "How often the AKS Cluster should be re-evaluated for scale up/down. Defaults to 10s."
  default     = "10s"
}
variable "scale_down_unneeded" {
  type        = string
  description = "How long a node should be unneeded before it is eligible for scale down. Defaults to 10m."
  default     = "10m"
}
variable "scale_down_unready" {
  type        = string
  description = "How long an unready node should be unneeded before it is eligible for scale down. Defaults to 20m."
  default     = "20m"
}
variable "scale_down_utilization_threshold" {
  type        = number
  description = <<EOF
    Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered
    for scale down. Defaults to 0.5.
    EOF
  default     = "0.5"
}
variable "role_based_access_control_enabled" {
  type        = bool
  description = "Enable or not general rbac functionality for kubernetes cluster."
  default     = true
}
variable "aad_rbac" {
  type = object({
    managed                = optional(bool, true)
    tenant_id              = optional(string)
    admin_group_object_ids = optional(list(string))
    azure_rbac_enabled     = optional(bool, true)
    server_app_secret      = optional(string)
    server_app_id          = optional(string)
    client_app_id          = optional(string)
  })
  description = <<EOF
    Variable configure Role Based Access Control based on Azure Active Directory. Keys and value explanation:
    `managed`: Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the
    Service Principal used for integration. Valid values are: `true, false`.
    `tenant_id`: The Tenant ID used for Azure Active Directory Application.
    When `managed` is set to true the following properties can be specified:
      `admin_group_object_ids`: A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster.
      `azure_rbac_enabled`: Is Role Based Access Control based on Azure AD enabled? Valid values are: `true, false`.
    When managed is set to false the following properties can be specified:
      `server_app_secret`: The Server Secret of an Azure Active Directory Application.
      `server_app_id`: The Server ID of an Azure Active Directory Application.
      `client_app_id`: The Client ID of an Azure Active Directory Application.
    See more:
    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#azure_active_directory_role_based_access_control
    EOF
  default     = null
}
variable "network_plugin" {
  type        = string
  description = "Network plugin to use for networking. Currently supported values are azure, kubenet and none."
  default     = "kubenet"
}
variable "network_policy" {
  type        = string
  description = <<EOF
    Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods.
    Currently supported values are `calico` and `azure`. Changing this forces a new resource to be created.
    When network_policy is set to `azure`, the network_plugin field can only be set to `azure`.
  EOF
  default     = null
}
variable "pod_cidr" {
  type        = string
  description = "The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet."
  default     = null
}
variable "service_cidr" {
  type        = string
  description = "The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  default     = null
}
variable "dns_service_ip" {
  type        = string
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)."
  default     = null
}
variable "docker_bridge_cidr" {
  type        = string
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes."
  default     = null
}
variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "automatic_channel_upgrade" {
  type        = string
  description = <<EOF
    The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. By default
    automatic-upgrades are turned off. Note that you cannot specify the patch version using `kubernetes_version` or 
    `orchestrator_version` when using the `patch` upgrade channel. See [the documentation](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster)
    for more information
    EOF
  default     = null
  validation {
    condition = var.automatic_channel_upgrade == null ? true : contains([
      "patch", "stable", "rapid", "node-image"
    ], var.automatic_channel_upgrade)
    error_message = "`automatic_channel_upgrade`'s possible values are `patch`, `stable`, `rapid` or `node-image`."
  }
}

variable "azure_policy_enabled" {
  type        = bool
  description = "Enable Azure Policy Addon."
  default     = false
}

variable "local_account_disabled" {
  type        = bool
  description = <<EOF
    If `true` local accounts will be disabled. Defaults to `false`. See [the documentation](https://docs.microsoft.com/azure/aks/managed-aad#disable-local-accounts)
    for more information.
    EOF
  default     = null
}

variable "private_cluster_public_fqdn_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether a Public FQDN for this Private Cluster should be added. Defaults to `false`."
}

variable "private_dns_zone_id" {
  type        = string
  description = <<EOF
    Either the ID of Private DNS Zone which should be delegated to this Cluster, `System` to have AKS manage this or `None`.
    In case of `None` you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after
    provisioning. Changing this forces a new resource to be created.
    EOF
  default     = null
}

variable "public_network_access_enabled" {
  type        = bool
  description = <<EOF
    Whether public network access is allowed for this Kubernetes Cluster. Defaults to `true`. Changing this forces a new resource
    to be created.
    EOF
  default     = true
  nullable    = false
}

variable "ingress_application_gateway" {
  type = object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_cidr  = optional(string)
    subnet_id    = optional(string)
  })
  description = <<EOF
    AKS HTTP/HTTPS proxy configuration, disabled by default. Keys and value explanation:
    `gateway_id`: The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster. See
    this page for further details: https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing
    `gateway_name`: The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be
    integrated with the ingress controller of this Kubernetes Cluster. See this page for further details:
    https://docs.microsoft.com/azure/application-gateway/tutorial-ingress-controller-add-on-new
    `subnet_cidr`: The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller
    of this Kubernetes Cluster. 
    See this page for further details: https://docs.microsoft.com/azure/application-gateway/tutorial-ingress-controller-add-on-new
    `subnet_id`: The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller
    of this Kubernetes Cluster. 
    See this page for further details: https://docs.microsoft.com/azure/application-gateway/tutorial-ingress-controller-add-on-new
    
    To create an Application Gateway automatically with all required permissions for the AKS inside of nodepool resource group -
    `gateway_name` and (`subnet_cidr` or `subnet_id`) must be provided. `subnet_cidr` must be used for dynamic subnet provisioning in the VNET
    that will be created by AKS itself. To integrate AKS with existing Application Gateway you must use `gateway_id` parameter only assuming
    that you have given appropriate permissions.
    EOF
  default     = null
}

variable "key_vault_secrets_provider" {
  type = object({
    secret_rotation_enabled  = optional(bool, false)
    secret_rotation_interval = optional(string, "2m")
  })
  description = <<EOF
    To enable `key_vault_secrets_provider` either `secret_rotation_enabled` or `secret_rotation_interval` must be specified.
    Keys and value explanation:
    `secret_rotation_enabled`: (Optional) Should the secret store CSI driver on the AKS cluster be enabled?
    `secret_rotation_interval`: (Optional) The interval to poll for secret rotation. This attribute is only set when `secret_rotation`
    is `true` and defaults to `2m`
    EOF
  default     = null
}

variable "http_proxy_config" {
  type = object({
    http_proxy  = optional(string)
    https_proxy = optional(string)
    no_proxy    = optional(list(string))
    trusted_ca  = optional(string)
  })
  description = <<EOF
    AKS HTTP/HTTPS proxy configuration, disabled by default. Keys and value explanation:
    `http_proxy`: The proxy address to be used when communicating over HTTP. Changing this forces a new resource to be created.
    `https_proxy`: The proxy address to be used when communicating over HTTPS. Changing this forces a new resource to be created.
    `no_proxy`: The list of domains that will not use the proxy for communication.
    `trusted_ca`: The base64 encoded alternative CA certificate content in PEM format.
    EOF
  default     = null
}

variable "load_balancer_sku" {
  type        = string
  description = <<EOF
    Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`.
    Defaults to `standard`. Changing this forces a new kubernetes cluster to be created.
    EOF
  default     = "standard"
  validation {
    condition     = contains(["basic", "standard"], var.load_balancer_sku)
    error_message = "Possible values are `basic` and `standard`"
  }
}

variable "storage_profile" {
  type = object({
    blob_driver_enabled         = optional(bool, false)
    disk_driver_enabled         = optional(bool, true)
    disk_driver_version         = optional(string, "v1")
    file_driver_enabled         = optional(bool, true)
    snapshot_controller_enabled = optional(bool, true)
  })
  description = <<EOF
    Enable or not the Blob CSI driver. Defaults to `false`. Keys and value explanation:
    `blob_driver_enabled`: Is the Blob CSI driver enabled? Defaults to `false`.
    `disk_driver_enabled`: Is the Disk CSI driver enabled? Defaults to `true`
    `disk_driver_version`: Disk CSI Driver version to be used. Possible values are `v1` and `v2`. Defaults to `v1`.
    `file_driver_enabled`: Is the File CSI driver enabled? Defaults to `true`
    `snapshot_controller_enabled`: Is the Snapshot Controller enabled? Defaults to `true`
    EOF
  default     = null
}

variable "dns_zone_id" {
  type        = string
  description = <<EOF
    Specifies the ID of the DNS Zone in which DNS entries are created for applications deployed to the cluster when
    Web App Routing is enabled. For Bring-Your-Own DNS zones this property should be set to an empty string `""`.
    Used by web_app_routing block.
    EOF
  default     = null
}

variable "diagnostic_setting" {
  description = <<EOF
  The description of parameters for Diagnostic Setting:
    `diagnostic_setting_name`    - specifies the name of the Diagnostic Setting;
    `log_analytics_workspace_id` - ID of the Log Analytics Workspace;
    `eventhub_name` - Specifies the name of the Event Hub where Diagnostics Data should be sent;
    `eventhub_authorization_rule_id` - Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data;
    `storage_account_id`         - the ID of the Storage Account where logs should be sent;
    `enabled_log`                        - describes logs for Diagnistic Setting: 
      `category`         - the name of a Diagnostic Log Category for this Resource. list of available logs: kube-apiserver, kube-audit, kube-audit-admin, kube-controller-manager, kube-scheduler, cluster-autoscaler, cloud-controller-manager, guard, csi-azuredisk-controller, csi-azurefile-controller, csi-snapshot-controller;
      `retention_policy` - describes logs retention policy (needed to store data in the Storage Account):
        `enabled` - is this Retention Policy enabled?
        `days`    - the number of days for which this Retention Policy should apply.
    `metric`             - describes metric for Diagnistic Setting:
      `category`  -  the name of a Diagnostic Metric Category for this Resource. List of available Metrics: AllMetrics ;
      `retention_policy` - describes Metric retention policy (needed to store data in the Storage Account):
        `enabled` - is this Retention Policy enabled?;
        `days`    - the number of days for which this Retention Policy should apply.
  EOF
  type = object({
    name                           = string
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    enabled_log                    = optional(list(string))
    metric                         = optional(list(string))
  })
  default = null
}
