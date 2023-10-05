variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "rg_name" {
  description = " The name of the resource group in which to create the virtual network"
  type        = string
}

variable "location" {
  description = <<EOT
      Specifies the supported Azure location where the resource exists."
      If the parameter is not specified in the configuration file, the location of the resource group is used.
    EOT
  type        = string
  default     = null
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used the virtual network."
  default     = ["10.0.0.0/16"]
}

# If no values specified, this defaults to Azure DNS 
variable "ddos_protection_plan_name" {
  description = "Specifies the name of the Network DDoS Protection Plan"
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "The DNS servers to be used with vNet"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = <<EOF
    Map of the networks to be created in VNET.
    Parameters that each subnet can have (some optional):
      `name` - The name of the subnet.
      `address_prefixes` - The address prefixes to use for the subnet

      `service_endpoints` - The list of Service endpoints to associate with the subnet. 
        Possible values include: 
          - Microsoft.AzureActiveDirectory
          - Microsoft.AzureCosmosDB
          - Microsoft.ContainerRegistry
          - Microsoft.EventHub
          - Microsoft.KeyVault
          - Microsoft.ServiceBus
          - Microsoft.Sql
          - Microsoft.Storage
          - Microsoft.Web

      `private_endpoint_network_policies_enabled` - Enable or Disable network policies for the private endpoint on the subnet.
      Setting this to `true` will Enable the policy and setting this to `false` will Disable the policy. 
      Defaults to `true`.
      `private_link_service_network_policies_enabled` - Enable or Disable network policies for the private link service on
      the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true.

      `service_endpoint_policy_ids` - The list of IDs of Service Endpoint Policies to associate with the subnet

      `delegation` - Map of delegations (only one delegation to service allowed by Azure):
        *name* -  A name for this delegation.
        *service_delegation* -  A map of Actions which should be delegated:
          **name** - The name of service to delegate to. 
            Possible values include:

          - Microsoft.ApiManagement/service, 
          - Microsoft.AzureCosmosDB/clusters,
          - Microsoft.BareMetal/AzureVMware,
          - Microsoft.BareMetal/CrayServers, 
          - Microsoft.Batch/batchAccounts, 
          - Microsoft.ContainerInstance/containerGroups, 
          - Microsoft.ContainerService/managedClusters, 
          - Microsoft.Databricks/workspaces, 
          - Microsoft.DBforMySQL/flexibleServers, 
          - Microsoft.DBforMySQL/serversv2, 
          - Microsoft.DBforPostgreSQL/flexibleServers, 
          - Microsoft.DBforPostgreSQL/serversv2, 
          - Microsoft.DBforPostgreSQL/singleServers, 
          - Microsoft.HardwareSecurityModules/dedicatedHSMs, 
          - Microsoft.Kusto/clusters, 
          - Microsoft.Logic/integrationServiceEnvironments, 
          - Microsoft.LabServices/labplans,
          - Microsoft.MachineLearningServices/workspaces, 
          - Microsoft.Netapp/volumes, 
          - Microsoft.Network/managedResolvers, 
          - Microsoft.Orbital/orbitalGateways, 
          - Microsoft.PowerPlatform/vnetaccesslinks, 
          - Microsoft.ServiceFabricMesh/networks, 
          - Microsoft.Sql/managedInstances, 
          - Microsoft.Sql/servers, 
          - Microsoft.StoragePool/diskPools, 
          - Microsoft.StreamAnalytics/streamingJobs, 
          - Microsoft.Synapse/workspaces, 
          - Microsoft.Web/hostingEnvironments, 
          - Microsoft.Web/serverFarms, 
          - NGINX.NGINXPLUS/nginxDeployments 
          - PaloAltoNetworks.Cloudngfw/firewalls.

          **actions** - A list of Actions which should be delegated. This list is specific to the service to delegate to.
            Possible values include:
            
            - Microsoft.Network/publicIPAddresses/read,
            - Microsoft.Network/virtualNetworks/read,
            - Microsoft.Network/networkinterfaces/*, 
            - Microsoft.Network/virtualNetworks/subnets/action, 
            - Microsoft.Network/virtualNetworks/subnets/join/action, 
            - Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action  
            - Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action
    EOF
  type        = any
  default     = []
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
  default     = {}
}

variable "diagnostic_setting" {
  description = <<EOF
    The description of parameters for Diagnistic Setting:
      `diagnostic_setting_name` - specifies the name of the Diagnostic Setting;
      `log_analytics_workspace_id` - ID of the Log Analytics Workspace;
      `storage_account_id` - the ID of the Storage Account where logs should be sent;
      `log` - describes logs for Diagnistic Setting:
        `category` -  the name of a Diagnostic Log Category for this Resource. list of available logs: `VMProtectionAlerts`;
        `enabled` -  is this Diagnostic Log enabled?;
        `retention_policy` - describes logs retention policy (needed to store data in the Storage Account):
          `enabled` - is this Retention Policy enabled?
          `days` - the number of days for which this Retention Policy should apply.
      `metric` - describes metric for Diagnistic Setting:
        `category` -  the name of a Diagnostic Metric Category for this Resource. List of available Metrics: `AllMetrics`;
        `enabled` -  is this Diagnostic Metric enabled?
        `retention_policy` - describes Metric retention policy (needed to store data in the Storage Account):
          `enabled` - is this Retention Policy enabled?
          `days` - the number of days for which this Retention Policy should apply.
EOF
  type        = any
  default     = null
}
