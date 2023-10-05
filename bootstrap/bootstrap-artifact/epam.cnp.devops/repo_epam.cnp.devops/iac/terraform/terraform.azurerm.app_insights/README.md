# terraform.azurerm.appinsights

This module deploys an application insights instance.

## Prerequisites

| Resource name | Required | Description |
|---------------|----------|-------------|
| resource group        | yes   |        |
| loganalytics workspace| no   |        |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.7 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.0.2 |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.appinsights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |



## Usage example

```go
module "appinsights" {
  source = "git::https://ORGANIZATION_NAME@dev.azure.com/ORGANIZATION_NAME/PROJECT_NAME/_git/terraform.azurerm.app_insights?ref=v3.1.0"

  rg_name                    = "example-rg"
  appinsights_name           = "example-appinsight"
  workspace_id               = "/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/log-analytics-workspace-rg/providers/Microsoft.OperationalInsights/workspaces/log-analytics-workspace-name"
  application_type           = "web"
  retention_in_days          = 90
  sampling_percentage        = 50
  disable_ip_masking         = false
  internet_ingestion_enabled = true
  internet_query_enabled     = true
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
| <a name="input_appinsights_name"></a> [appinsights\_name](#input\_appinsights\_name) | Specifies the name of the Application Insights component. Changing this forces a new resource<br>  to be created. | `string` | n/a | yes |
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | Specifies the type of Application Insights to create. Possible values `ios`, `java`, `MobileCenter`,<br>  `Node.JS`, `phone`, `store`, `web`, `other` | `string` | n/a | yes |
| <a name="input_disable_ip_masking"></a> [disable\_ip\_masking](#input\_disable\_ip\_masking) | By default the real client ip is masked as `0.0.0.0` in the logs. Use this argument to disable masking<br>  and log the real client ip. | `bool` | `false` | no |
| <a name="input_internet_ingestion_enabled"></a> [internet\_ingestion\_enabled](#input\_internet\_ingestion\_enabled) | Should the Application Insights component support ingestion over the Public Internet? | `bool` | `true` | no |
| <a name="input_internet_query_enabled"></a> [internet\_query\_enabled](#input\_internet\_query\_enabled) | Should the Application Insights component support querying over the Public Internet? | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists.<br>  If the parameter is not specified in the configuration file, the location of the resource group is used. | `string` | `null` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Specifies the retention period in days. Possible values are `30`, `60`, `90`, `120`, `180`, `270`, <br>  `365`, `550` or `730`. | `number` | `90` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group in which to create the appinsight. Changing this forces a new <br>  resource to be created. | `string` | n/a | yes |
| <a name="input_sampling_percentage"></a> [sampling\_percentage](#input\_sampling\_percentage) | Specifies the percentage of the data produced by the monitored application that is sampled for<br>  Application Insights telemetry. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | Specifies the id of a log analytics workspace resource. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | The App ID associated with this Application Insights component. |
| <a name="output_appinsights_id"></a> [appinsights\_id](#output\_appinsights\_id) | The ID of the Application Insights component. |
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | The Connection String for this Application Insights component. |
| <a name="output_instrumentation_key"></a> [instrumentation\_key](#output\_instrumentation\_key) | The Instrumentation Key for this Application Insights component. |