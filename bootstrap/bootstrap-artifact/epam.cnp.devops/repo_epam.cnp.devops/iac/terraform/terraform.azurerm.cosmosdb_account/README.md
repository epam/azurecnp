# terraform.azurerm.cosmosdb

This module creates an CosmosDB Account with Virtual Network Rule, Consistency Policy and Geo Location.

## Prerequisites

| Resource name | Required | Description |
|---------------|----------|-------------|
| Resource group        | yes   |       |
| Vnet with subnets     | yes   |       |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.7 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.42.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_cosmosdb_account.cosmodb_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_monitor_diagnostic_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |



## Usage example

```go
module "cosmosdb_account" {
  source                    = "git::https://ORGANIZATION_NAME@dev.azure.com/ORGANIZATION_NAME/PROJECT_NAME/_git/terraform.azurerm.cosmosdb_account?ref=v2.2.0"
  cosmosdb_account_name     = "example-webapp-cosmosdb"
  rg_name                   = "example-rg-noeu-s-shared-01"
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = false
  geo_location = [
    {
      location          = "eastus"
      failover_priority = 0
      zone_redundant    = false
    },
    {
      location          = "westus"
      failover_priority = 1
      zone_redundant    = false
    }
  ]
  rg_location                       = "northeurope"
  ip_range_filter                   = "10.0.0.0/24,10.0.1.0/24"
  is_virtual_network_filter_enabled = true
  allowed_subnets = [
    {
      vnet_name                            = "example-vnet-noeu-s-shared-01"
      vnet_rg_name                         = "example-rg-noeu-s-network-01"
      subnet_name                          = "sn-db-01"
      ignore_missing_vnet_service_endpoint = true
    },
    {
      vnet_name                            = "example-vnet-noeu-s-shared-02"
      vnet_rg_name                         = "example-rg-noeu-s-network-02"
      subnet_name                          = "sn-db-02"
      ignore_missing_vnet_service_endpoint = false
    }
  ]
  capabilities      = ["mongoEnableDocLevelTTL", "MongoDBv3.4", "EnableMongo"]
  consistency_level = "Session"

  diagnostic_setting = {
    diagnostic_setting_name    = "example-cosmosdb-diag"
    log_analytics_workspace_id = "/subscriptions/11111111-aaaa-ssss-ffff-222222222222/resourceGroups/example-rg/providers/Microsoft.OperationalInsights/workspaces/example-la"
    storage_account_id         = "/subscriptions/11111111-aaaa-ssss-ffff-222222222222/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/examplesa"

    log = [
      {
        category = "MongoRequests"
        enabled  = true
        retention_policy = {
          enabled = true
        }
      },
      {
        category = "QueryRuntimeStatistics"
        enabled  = true
        retention_policy = {
          enabled = true
          days    = 1
        }
      }
    ]

    metric = [
      {
        category = "Requests"
        enabled  = true
        retention_policy = {
          enabled = true
          days    = 1
        }
      }
    ]
  }

  tags = {
    Foo  = "Bar"
    Test = "Example"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_subnets"></a> [allowed\_subnets](#input\_allowed\_subnets) | This parameter is a list of objects which set allowed subnets for cosmosdb account. Require parameters below:<br>  - `vnet_name`                                  The name of the vnet where server takes place<br>  - `vnet_rg_name`                               The name of vnet's rg<br>  - `subnet_name`                                The name of the subnet where server takes place.<br>  - `ignore_missing_vnet_service_endpoint`       If set to true, the specified subnet will be added as <br>                                                   a virtual network rule even if its CosmosDB service endpoint is not active. | <pre>list(object({<br>    vnet_name                            = string<br>    vnet_rg_name                         = string<br>    subnet_name                          = string<br>    ignore_missing_vnet_service_endpoint = bool<br>  }))</pre> | `[]` | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | List of capabilities for Cosmos DB API. - Possible values are `AllowSelfServeUpgradeToMongo36`, `DisableRateLimitingResponses`, <br>  `EnableAggregationPipeline`, `EnableCassandra`, `EnableGremlin`, `EnableMongo`, `EnableMongo16MBDocumentSupport`, <br>  `EnableMongoRetryableWrites`, `EnableMongoRoleBasedAccessControl`, `EnableServerless`, `EnableTable`, <br>  `EnableUniqueCompoundNestedDocs`, `MongoDBv3.4` and `mongoEnableDocLevelTTL`. | `list(string)` | `[]` | no |
| <a name="input_consistency_level"></a> [consistency\_level](#input\_consistency\_level) | The Consistency Level to use for this CosmosDB Account - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix. | `string` | `"Session"` | no |
| <a name="input_cosmosdb_account_name"></a> [cosmosdb\_account\_name](#input\_cosmosdb\_account\_name) | Specifies the name of the CosmosDB Account. | `string` | n/a | yes |
| <a name="input_diagnostic_setting"></a> [diagnostic\_setting](#input\_diagnostic\_setting) | The description of parameters for Diagnistic Setting:<br>    `diagnostic_setting_name` - specifies the name of the Diagnostic Setting;<br>    `log_analytics_workspace_id` - ID of the Log Analytics Workspace;<br>    `storage_account_id` - the ID of the Storage Account where logs should be sent;<br>    `log` - describes logs for Diagnistic Setting:<br>      `category` -  the name of a Diagnostic Log Category for this Resource. list of <br>        available logs: `DataPlaneRequests`, `MongoRequests`, `MongoRequests`, `MongoRequests`, `MongoRequests`, <br>        `MongoRequests`, `MongoRequests`, `MongoRequests`, `MongoRequests`;<br>      `enabled` -  is this Diagnostic Log enabled?;<br>      `retention_policy` - describes logs retention policy (needed to store data in the Storage Account):<br>        `enabled` - is this Retention Policy enabled?<br>        `days` - the number of days for which this Retention Policy should apply.<br>    `metric` - describes metric for Diagnistic Setting:<br>      `category` -  the name of a Diagnostic Metric Category for this Resource. List of<br>        available Metrics: `Requests`;<br>      `enabled` -  is this Diagnostic Metric enabled?<br>      `retention_policy` - describes Metric retention policy (needed to store data in the Storage Account):<br>        `enabled` - is this Retention Policy enabled?<br>        `days` - the number of days for which this Retention Policy should apply. | `any` | `null` | no |
| <a name="input_enable_automatic_failover"></a> [enable\_automatic\_failover](#input\_enable\_automatic\_failover) | Enable automatic fail over for this Cosmos DB account. | `bool` | `false` | no |
| <a name="input_geo_location"></a> [geo\_location](#input\_geo\_location) | The `geo_location` block Configures the geographic locations the data is replicated to and supports the following:<br>  - `location`            (Required) The name of the Azure region to host replicated data.<br>  - `failover_priority`   (Required) The failover priority of the region. A failover priority of `0` indicates a write region. <br>                            The maximum value for a failover priority = (total number of regions - `1`). <br>                            Failover priority values must be unique for each of the regions in which the database account exists. <br>                            Changing this causes the location to be re-provisioned and cannot be changed for the location with failover priority `0`.<br>  - `zone_redundant`      (Optional) Should zone redundancy be enabled for this region? Defaults to `false`. | <pre>list(object({<br>    location          = string<br>    failover_priority = number<br>    zone_redundant    = optional(bool)<br>  }))</pre> | n/a | yes |
| <a name="input_ip_range_filter"></a> [ip\_range\_filter](#input\_ip\_range\_filter) | This value specifies the set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IP's for a given database account. <br>  IP addresses/ranges must be comma separated and must not contain any spaces. | `string` | `""` | no |
| <a name="input_is_virtual_network_filter_enabled"></a> [is\_virtual\_network\_filter\_enabled](#input\_is\_virtual\_network\_filter\_enabled) | Enables virtual network filtering for this Cosmos DB account. | `bool` | `true` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB and MongoDB. Defaults to GlobalDocumentDB | `string` | `"GlobalDocumentDB"` | no |
| <a name="input_offer_type"></a> [offer\_type](#input\_offer\_type) | Specifies the Offer Type to use for this CosmosDB Account - currently this can only be set to Standard | `string` | `"Standard"` | no |
| <a name="input_rg_location"></a> [rg\_location](#input\_rg\_location) | Specifies the supported Azure location where the resource exists. | `string` | `null` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group in which the CosmosDB Account is created. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_strings"></a> [connection\_strings](#output\_connection\_strings) | A list of connection strings available for this CosmosDB account. |
| <a name="output_id"></a> [id](#output\_id) | The CosmosDB Account ID |
| <a name="output_name"></a> [name](#output\_name) | Specifies the name of the CosmosDB Account |
| <a name="output_primary_key"></a> [primary\_key](#output\_primary\_key) | The Primary key for the CosmosDB Account |