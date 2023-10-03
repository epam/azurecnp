# terraform.azurerm.alerts

This module creates AlertingAction Scheduled Query Rules, and Metric Alert resources within Azure Monitor.

## Prerequisites

| Resource name | Required | Description |
|---------------|----------|-------------|
| resource group        | yes   |        |
| monitor action group  | yes   |        |
| loganalytics workspace| yes   |        |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.8 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.6.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_metric_alert.metric_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_scheduled_query_rules_alert.query_rules_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert) | resource |
| [azurerm_monitor_action_group.action_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |



## Usage example

```go
module "alerts" {
  source = "git::https://ORGANIZATION_NAME@dev.azure.com/ORGANIZATION_NAME/PROJECT_NAME/_git/terraform.azurerm.alerts?ref=v1.0.0"

  action_group_name          = "example-action-group-name"
  action_group_rg_name       = "example-resource-group"
  azuremonitor_rg_name       = "azuremonitor-resource-group"
  log_analytics_workspace_id = "1234321-example-id-1344512"

  tags = {
    environment = "production"
    deployedBy  = "Terraform"
    foo         = "bar"
  }

  metric_alert = [
    {
      name                     = "example-metric-alert-01"
      metric_alert_scopes      = ["/subscriptions/12345678-0000-0000-0000-000987654321/resourceGroups/example-rg-log-d-analitic-00/providers/Microsoft.Storage/storageAccounts/examplestorageaccount"]
      description              = "Example metric alert description"
      enabled                  = true
      auto_mitigate            = true
      frequency                = "PT1M"
      severity                 = "2"
      target_resource_type     = "Microsoft.Compute/virtualMachines"
      target_resource_location = "westeurope"
      window_size              = "PT5M"
      criteria = [
        {
          metric_namespace       = "Microsoft.Storage/storageAccounts"
          metric_name            = "Transactions"
          aggregation            = "Total"
          operator               = "GreaterThan"
          threshold              = "50"
          skip_metric_validation = false
          dimension = [
            {
              name     = "ApiName"
              operator = "Include"
              values   = ["*"]
            }
          ]
        }
      ]
      dynamic_criteria = [
        {
          metric_namespace         = "Microsoft.Storage/storageAccounts"
          metric_name              = "Availability"
          aggregation              = "Total"
          operator                 = "GreaterThan"
          alert_sensitivity        = "10"
          evaluation_total_count   = "2"
          evaluation_failure_count = "1"
          ignore_data_before       = "2022-09-16T09:44:04+00:00"
          skip_metric_validation   = false
          dimension = [
            {
              name     = "ApiName"
              operator = "Include"
              values   = ["*"]
            }
          ]
        }
      ]
      application_insights_web_test_location_availability_criteria = [
        {
          web_test_id           = "/subscriptions/subid/resourceGroups/my-test-resources/providers/Microsoft.Insights/webtests/my-webtest-01-mywebservice"
          component_id          = "/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/mygroup1/providers/microsoft.insights/components/instance1"
          failed_location_count = "1"
        }
      ]
      action = {
        webhook_properties = {}
      }
    }
  ]

  scheduled_query_rules_alert = [
    {
      name                    = "example-scheduled_query_rules_alert-01"
      location                = "westeurope"
      description             = "Example schedule query rules alert description"
      enabled                 = true
      frequency               = "1440"
      time_window             = "2880"
      severity                = "3"
      throttling              = "10000"
      authorized_resource_ids = ["example"]
      auto_mitigation_enabled = null
      query                   = <<-QUERY
                                    requests
                                        | where tolong(resultCode) >= 500
                                        | summarize count() by bin(timestamp, 5m)
                                    QUERY
      action = {
        email_subject          = "Email Header"
        custom_webhook_payload = "{}"
      }
      trigger = {
        operator  = "GreaterThan"
        threshold = "3"
        metric_trigger = [
          {
            metric_column       = "Example"
            metric_trigger_type = "Consecutive"
            operator            = "Equal"
            threshold           = "5"
          }
        ]
      }
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_name"></a> [action\_group\_name](#input\_action\_group\_name) | The name of the Action Group | `string` | n/a | yes |
| <a name="input_action_group_rg_name"></a> [action\_group\_rg\_name](#input\_action\_group\_rg\_name) | The Action Group resource group name | `string` | n/a | yes |
| <a name="input_azuremonitor_rg_name"></a> [azuremonitor\_rg\_name](#input\_azuremonitor\_rg\_name) | The Azuremonitor Resource Group name. If not defined the Azuremonitor whould be placed at the related Action Group Resource Group | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The id of the loganalytics workspace | `string` | `null` | no |
| <a name="input_metric_alert"></a> [metric\_alert](#input\_metric\_alert) | An object which contains various parameters for monitor metric alert:<br>    `name`                     - The name of the Metric Alert. Changing this forces a new resource to be created.<br>    `metric_alert_scopes`      - A set of strings of resource IDs at which the metric criteria should be applied.<br>    `description`              - The description of this Metric Alert.<br>    `enabled`                  - Should this Metric Alert be enabled? Defaults to `true`.<br>    `auto_mitigate`            - Should the alerts in this Metric Alert be auto resolved? Defaults to `true`.<br>    `frequency`                - The evaluation frequency of this Metric Alert, represented in ISO 8601 duration <br>    format. Possible values are `PT1M`, `PT5M`, `PT15M`, `PT30M` and `PT1H`. Defaults to `PT1M`.<br>    `severity`                 - The severity of this Metric Alert. Possible values are `0`, `1`, `2`, `3` and `4`.<br>     Defaults to `3`.<br>    `target_resource_type`     - The resource type (e.g. `Microsoft.Compute/virtualMachines`) of the target resource.<br>    `target_resource_location` - The location of the target resource.<br>    `window_size`              - The period of time that is used to monitor alert activity, represented in ISO 8601<br>     duration format. This value must be greater than frequency. Possible values are `PT1M`, `PT5M`, `PT15M`, `PT30M`, `PT1H`, `PT6H`, `PT12H` and `P1D`. Defaults to `PT5M`.<br>    `criteria`                 - Criteria parameters.<br>            `metric_namespace`        - One of the metric namespaces to be monitored.<br>            `metric_name`             - One of the metric names to be monitored.<br>            `aggregation`             - The statistic that runs over the metric values. Possible values are `Average`,<br>             `Count`, `Minimum`, `Maximum` and `Total`.<br>            `operator`                - The criteria operator. Possible values are `Equals`, `NotEquals`,<br>            `GreaterThan`, `GreaterThanOrEqual`, `LessThan` and `LessThanOrEqual`.<br>            `threshold`               - The criteria threshold value that activates the alert.<br>            `skip_metric_validation`  - Skip the metric validation to allow creating an alert rule on a custom metric<br>             that isn't yet emitted? Defaults to `false`.<br>            `dimension`               - Dimension parameters.<br>                 `name`     - One of the dimension names.<br>                 `operator` - The dimension operator. Possible values are `Include`, `Exclude` and `StartsWith`.<br>                 `values`   - The list of dimension values.<br>    `dynamic_criteria`         - Dynamic criteria parameters.<br>            `metric_namespace`         - One of the metric namespaces to be monitored.<br>            `metric_name`              - One of the metric names to be monitored.<br>            `aggregation`              - The statistic that runs over the metric values. Possible values are `Average`,<br>             `Count`, `Minimum`, `Maximum` and `Total`.<br>            `operator`                 - The criteria operator. Possible values are `LessThan`, `GreaterThan` and <br>            `GreaterOrLessThan`.<br>            `alert_sensitivity`        - The extent of deviation required to trigger an alert. Possible values are <br>            `Low`, `Medium` and `High`.<br>            `evaluation_total_count`   - The number of aggregated lookback points. The lookback time window is <br>            calculated based on the aggregation granularity (window\_size) and the selected number of aggregated points.<br>            `evaluation_failure_count` - The number of violations to trigger an alert. Should be smaller or equal to <br>            `evaluation_total_count`.<br>            `ignore_data_before`       - The `ISO8601` date from which to start learning the metric historical data <br>            and calculate the dynamic thresholds.<br>            `skip_metric_validation`   - Skip the metric validation to allow creating an alert rule on a custom metric<br>             that isn't yet emitted? Defaults to `false`.<br>            `dimension`                - Dimension parameters.<br>                 `name`     - One of the dimension names.<br>                 `operator` - The dimension operator. Possible values are `Include`, `Exclude` and `StartsWith`.<br>                 `values`   - The list of dimension values.<br>    `application_insights_web_test_location_availability_criteria`  - Application insights web test location<br>     availability criteria parameters.<br>            `web_test_id`              - The ID of the Application Insights Web Test.<br>            `component_id`             - The ID of the Application Insights Resource.<br>            `failed_location_count`    - The number of failed locations.<br>    `action` - Action parameters.<br>            `webhook_properties`       - The map of custom string properties to include with the post operation.<br>             These data are appended to the webhook payload. | `any` | `[]` | no |
| <a name="input_scheduled_query_rules_alert"></a> [scheduled\_query\_rules\_alert](#input\_scheduled\_query\_rules\_alert) | An object which contains various parameters for scheduled query rules alert:<br><br>      `name`                    - The name of the scheduled query rule. Changing this forces a new resource to be created.<br>      `location`                - The location of the scheduled query rule.<br>      `description`             - The description of the scheduled query rule.<br>      `enabled`                 - Whether this scheduled query rule is enabled. Default is `true`.<br>      `frequency`               - Frequency (in minutes) at which rule condition should be evaluated. Values must be <br>      between `5` and `1440` (inclusive).<br>      `time_window`             - Time window for which data needs to be fetched for query (must be greater than or <br>      equal to `frequency`). Values must be between `5` and `2880` (inclusive).<br>      `severity`                - Severity of the alert. Possible values include: `0`, `1`, `2`, `3`, or `4`.<br>      `throttling`              - Time (in minutes) for which Alerts should be throttled or suppressed. Values must <br>      be between `0` and `10000` (inclusive).<br>      `authorized_resource_ids` - List of Resource IDs referred into query.<br>      `auto_mitigation_enabled` - Should the alerts in this Metric Alert be auto resolved? Defaults to `false`. <br>      `NOTE` `auto_mitigation_enabled` and `throttling` are mutually exclusive and cannot both be set.<br>      `query`                   - Log search query.<br>      `action`                  - Action parameters.<br>        `email_subject`              - Custom subject override for all email ids in Azure action group.<br>        `custom_webhook_payload`     - Custom payload to be sent for all webhook payloads in alerting action.<br>      `trigger`                 - Trigger parameters.<br>        `operator`       - Evaluation operation for rule - `GreaterThan`, `GreaterThanOrEqual`, `LessThan`, or <br>        `LessThanOrEqual`.<br>        `threshold`      - Result or count threshold based on which rule should be triggered. Values must be between<br>         `0` and `10000` (inclusive).<br>        `metric_trigger` - Metric trigger parameters.<br>            `metric_column`       - Evaluation of metric on a particular column.<br>            `metric_trigger_type` - Metric Trigger Type - `Consecutive` or `Total`.<br>            `operator`            - Evaluation operation for rule - `Equal`, `GreaterThan`, `GreaterThanOrEqual`,<br>             `LessThan`, or `LessThanOrEqual`.<br>            `threshold`           - The threshold of the metric trigger. Values must be between `0` and `10000` (inclusive). | `any` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_monitor_metric_alert_id"></a> [monitor\_metric\_alert\_id](#output\_monitor\_metric\_alert\_id) | The ID of the metric alert |
| <a name="output_scheduled_query_rules_alert_id"></a> [scheduled\_query\_rules\_alert\_id](#output\_scheduled\_query\_rules\_alert\_id) | The ID of the scheduled query rule |