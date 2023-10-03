# terraform.azurerm.vnet

This module creates virtual networks with specified subnets

## Prerequisites

| Resource name | Required | Description |
|---------------|----------|-------------|
| Resource Group          | yes |                                             |
| Log Analytics Workspace | no  | Necessary when creating a Diagnosic setting |
| Storage Account         | no  | to store Diagnostic Settings data           |

:warning: Note: if you make changes to the "enabled" and "days" parameters of the retention\_policy argument, terraform will not recognize the changes correctly and will not change the Diagnostic Setting resource when you plan/apply repeatedly. For more information, see the GitHub [ticket](https://github.com/hashicorp/terraform-provider-azurerm/issues/17172#issuecomment-1367762758).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.8 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.35.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.35.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_network_ddos_protection_plan.ddosPlan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_ddos_protection_plan) | data source |
| [azurerm_resource_group.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |



## Usage example

```go
module "vnet" {
  source = "git::https://ORGANIZATION_NAME@dev.azure.com/ORGANIZATION_NAME/PROJECT_NAME/_git/terraform.azurerm.vnet?ref=v2.2.0"

  vnet_name                 = "example-vnet"
  rg_name                   = "example-vnet-rg"
  location                  = "westeurope"
  address_space             = ["10.0.0.0/16"]
  ddos_protection_plan_name = "exampleddosprotectionplan"
  dns_servers               = ["exampledns"]

  subnets = [
    {
      name = "example-subnet"
      address_prefixes = [
        "10.0.1.0/24"
      ]
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies_enabled     = true
      service_endpoints                             = null
      service_endpoint_policy_ids                   = null
      delegation = {
        name = "delegation"
        service_delegation = {
          name    = "Microsoft.ContainerInstance/containerGroups"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }
      }
    }
  ]

  diagnostic_setting = {
    diagnostic_setting_name    = "example-diag"
    log_analytics_workspace_id = "/subscriptions/11111111-aaaa-ssss-ffff-222222222222/resourceGroups/example-rg/providers/Microsoft.OperationalInsights/workspaces/example-la"
    storage_account_id         = "/subscriptions/11111111-aaaa-ssss-ffff-222222222222/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplesa"

    log = [
      {
        category                 = "VMProtectionAlerts"
        enabled                  = true
        retention_policy_enabled = false
        retention_policy_days    = 0
      }
    ]
    metric = [
      {
        category                 = "AllMetrics"
        enabled                  = true
        retention_policy_enabled = false
        retention_policy_days    = 0
      }
    ]
  }

  tags = {
    environment = "production"
    deployedBy  = "Terraform"
    foo         = "bar"
  }
} 
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used the virtual network. | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_ddos_protection_plan_name"></a> [ddos\_protection\_plan\_name](#input\_ddos\_protection\_plan\_name) | Specifies the name of the Network DDoS Protection Plan | `string` | `null` | no |
| <a name="input_diagnostic_setting"></a> [diagnostic\_setting](#input\_diagnostic\_setting) | The description of parameters for Diagnistic Setting:<br>      `diagnostic_setting_name` - specifies the name of the Diagnostic Setting;<br>      `log_analytics_workspace_id` - ID of the Log Analytics Workspace;<br>      `storage_account_id` - the ID of the Storage Account where logs should be sent;<br>      `log` - describes logs for Diagnistic Setting:<br>        `category` -  the name of a Diagnostic Log Category for this Resource. list of available logs: `VMProtectionAlerts`;<br>        `enabled` -  is this Diagnostic Log enabled?;<br>        `retention_policy` - describes logs retention policy (needed to store data in the Storage Account):<br>          `enabled` - is this Retention Policy enabled?<br>          `days` - the number of days for which this Retention Policy should apply.<br>      `metric` - describes metric for Diagnistic Setting:<br>        `category` -  the name of a Diagnostic Metric Category for this Resource. List of available Metrics: `AllMetrics`;<br>        `enabled` -  is this Diagnostic Metric enabled?<br>        `retention_policy` - describes Metric retention policy (needed to store data in the Storage Account):<br>          `enabled` - is this Retention Policy enabled?<br>          `days` - the number of days for which this Retention Policy should apply. | `any` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to be used with vNet | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists."<br>      If the parameter is not specified in the configuration file, the location of the resource group is used. | `string` | `null` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group in which to create the virtual network | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of the networks to be created in VNET.<br>    Parameters that each subnet can have (some optional):<br>      `name` - The name of the subnet.<br>      `address_prefixes` - The address prefixes to use for the subnet<br><br>      `service_endpoints` - The list of Service endpoints to associate with the subnet. <br>        Possible values include: <br>          - Microsoft.AzureActiveDirectory<br>          - Microsoft.AzureCosmosDB<br>          - Microsoft.ContainerRegistry<br>          - Microsoft.EventHub<br>          - Microsoft.KeyVault<br>          - Microsoft.ServiceBus<br>          - Microsoft.Sql<br>          - Microsoft.Storage<br>          - Microsoft.Web<br><br>      `private_endpoint_network_policies_enabled` - Enable or Disable network policies for the private endpoint on the subnet.<br>      Setting this to `true` will Enable the policy and setting this to `false` will Disable the policy. <br>      Defaults to `true`.<br>      `private_link_service_network_policies_enabled` - Enable or Disable network policies for the private link service on<br>      the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true.<br><br>      `service_endpoint_policy_ids` - The list of IDs of Service Endpoint Policies to associate with the subnet<br><br>      `delegation` - Map of delegations (only one delegation to service allowed by Azure):<br>        *name* -  A name for this delegation.<br>        *service\_delegation* -  A map of Actions which should be delegated:<br>          **name** - The name of service to delegate to. <br>            Possible values include:<br><br>          - Microsoft.ApiManagement/service, <br>          - Microsoft.AzureCosmosDB/clusters,<br>          - Microsoft.BareMetal/AzureVMware,<br>          - Microsoft.BareMetal/CrayServers, <br>          - Microsoft.Batch/batchAccounts, <br>          - Microsoft.ContainerInstance/containerGroups, <br>          - Microsoft.ContainerService/managedClusters, <br>          - Microsoft.Databricks/workspaces, <br>          - Microsoft.DBforMySQL/flexibleServers, <br>          - Microsoft.DBforMySQL/serversv2, <br>          - Microsoft.DBforPostgreSQL/flexibleServers, <br>          - Microsoft.DBforPostgreSQL/serversv2, <br>          - Microsoft.DBforPostgreSQL/singleServers, <br>          - Microsoft.HardwareSecurityModules/dedicatedHSMs, <br>          - Microsoft.Kusto/clusters, <br>          - Microsoft.Logic/integrationServiceEnvironments, <br>          - Microsoft.LabServices/labplans,<br>          - Microsoft.MachineLearningServices/workspaces, <br>          - Microsoft.Netapp/volumes, <br>          - Microsoft.Network/managedResolvers, <br>          - Microsoft.Orbital/orbitalGateways, <br>          - Microsoft.PowerPlatform/vnetaccesslinks, <br>          - Microsoft.ServiceFabricMesh/networks, <br>          - Microsoft.Sql/managedInstances, <br>          - Microsoft.Sql/servers, <br>          - Microsoft.StoragePool/diskPools, <br>          - Microsoft.StreamAnalytics/streamingJobs, <br>          - Microsoft.Synapse/workspaces, <br>          - Microsoft.Web/hostingEnvironments, <br>          - Microsoft.Web/serverFarms, <br>          - NGINX.NGINXPLUS/nginxDeployments <br>          - PaloAltoNetworks.Cloudngfw/firewalls.<br><br>          **actions** - A list of Actions which should be delegated. This list is specific to the service to delegate to.<br>            Possible values include:<br>        <br>            - Microsoft.Network/publicIPAddresses/read,<br>            - Microsoft.Network/virtualNetworks/read,<br>            - Microsoft.Network/networkinterfaces/*, <br>            - Microsoft.Network/virtualNetworks/subnets/action, <br>            - Microsoft.Network/virtualNetworks/subnets/join/action, <br>            - Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action<br>            - Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action | `any` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to associate with your network and subnets. | `map(string)` | `{}` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the virtual network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | The address space of the newly created vNet |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The id of the newly created vNet |
| <a name="output_vnet_location"></a> [vnet\_location](#output\_vnet\_location) | The location of the newly created vNet |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The Name of the newly created vNet |
| <a name="output_vnet_subnets"></a> [vnet\_subnets](#output\_vnet\_subnets) | The ids of subnets created inside the newl vNet |