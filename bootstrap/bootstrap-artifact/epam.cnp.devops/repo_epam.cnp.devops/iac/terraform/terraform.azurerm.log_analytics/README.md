# terraform.azurerm.loganalytics

This module creates an Azure Log Analytics Workspace and Log Analytics solution(optional)

## Prerequisites

| Resource name | Required | Description |
|---------------|----------|-------------|
| Resource Group    | yes   |                                                                                    |
| Storage Account   | no    | In case of using Storage Account where logs for diagnostic settings will be sent   |

:warning: Note: When we change the retention\_policy argument (change the value of "enabled" or change the value of "days") and run "plan" we get a message that no changes were made and "apply" does not work.
On GitHub there is an open [issue](https://github.com/hashicorp/terraform-provider-azurerm/issues/17172#issuecomment-1367762758).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.7 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.35.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.35.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_solution.lasolution](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.laworkspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.laworkspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group_template_deployment.deployment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |



## Usage example

```go
module "log_analytics" {
  source             = "git::https://ORGANIZATION_NAME@dev.azure.com/ORGANIZATION_NAME/PROJECT_NAME/_git/terraform.azurerm.log_analytics?ref=v2.6.0"
  name               = "example-loganalytic"
  rg_name            = "example-rg"
  location           = "westeurope"
  pricing_tier       = "PerGB2018"
  retention_in_days  = 30
  deployment_mode    = "Incremental"
  storage_account_id = "/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/example-storage-rg/providers/Microsoft.Storage/storageAccounts/example-storage"

  la_solutions = [
    {
      la_sln_name      = "example-las-name"
      la_sln_publisher = "Microsoft"
      la_sln_product   = "Gallery/ContainerInsights"
    }
  ]

  activity_log_subs = [
    "a03def49-00000-1111-2222-3a2dcfcf84a1",
    "a03def49-33333-5555-6666-3a2dcfcf84a1"
  ]

  diagnostic_setting = {
    diagnostic_setting_name = "example-loganalytic-dgs"

    log = [
      {
        category_group = "audit"
        enabled        = true
        retention_policy = {
          enabled = true
          days    = 7
        }
      },
      {
        category_group = "allLogs"
        enabled        = true
        retention_policy = {
          enabled = true
          days    = 7
        }
      }
    ]
    metric = [
      {
        category = "AllMetrics"
        enabled  = true
        retention_policy = {
          enabled = true
          days    = 7
        }
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
| <a name="input_activity_log_subs"></a> [activity\_log\_subs](#input\_activity\_log\_subs) | List of subscriptions ID for which you need to spice up the Activity log to this workspace, the user <br>  running terraform needs at least Monitoring Contributor permissions on the target subscription | `list(string)` | `[]` | no |
| <a name="input_deployment_mode"></a> [deployment\_mode](#input\_deployment\_mode) | The resource group template deployment mode | `string` | `"Incremental"` | no |
| <a name="input_diagnostic_setting"></a> [diagnostic\_setting](#input\_diagnostic\_setting) | The description of parameters for Diagnistic Setting:<br>  `diagnostic_setting_name` - specifies the name of the Diagnostic Setting;<br>  `log` - describes logs for Diagnistic Setting:<br>    `category_group` -  the name of a Diagnostic Log Category Group for this Resource;<br>    `enabled` -  is this Diagnostic Log enabled?;<br>    `retention_policy` - describes logs retention policy:<br>      `enabled` - is this Retention Policy enabled?<br>      `days` - the number of days for which this Retention Policy should apply.<br>  `metric` - describes metric for Diagnistic Setting:<br>    `category` -  the name of a Diagnostic Metric Category for this Resource;<br>    `enabled` -  is this Diagnostic Metric enabled?<br>    `retention_policy` - describes Metric retention policy:<br>      `enabled` - is this Retention Policy enabled?<br>      `days` - the number of days for which this Retention Policy should apply. | `any` | `null` | no |
| <a name="input_la_solutions"></a> [la\_solutions](#input\_la\_solutions) | The description of parameters for resource Log Analytics Solution.<br>  `la_sln_name`- Specifies the name of the solution to be deployed<br>  `la_sln_publisher` - The publisher of the solution. For example Microsoft. <br>   Changing this forces a new resource to be created.<br>  `la_sln_product` - The product name of the solution. For example "OMSGallery/Containers".<br>   Changing this forces a new resource to be created. | `list(map(string))` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists.<br>  If the parameter is not specified in the configuration file, the location of the resource group is used. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of the Log Analytics Workspace. Workspace name should include<br>  4-63 letters, digits or '-'. | `string` | n/a | yes |
| <a name="input_pricing_tier"></a> [pricing\_tier](#input\_pricing\_tier) | Specifies the Sku of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard,<br>  Standalone, Unlimited, CapacityReservation, and PerGB2018 (new Sku as of 2018-04-03). Defaults to PerGB2018. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between <br>  30 and 730 | `number` | `null` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group in which the Log Analytics workspace is created. | `string` | n/a | yes |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | The ID of the Storage Account where logs should be sent | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The id of the Log Analytics Workspace |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The Workspace (or Customer) ID for the Log Analytics Workspace |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | The name of the Log Analytics Workspace |