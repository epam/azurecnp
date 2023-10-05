variable "action_group_rg_name" {
  description = "The Action Group resource group name"
  type        = string
}

variable "azuremonitor_rg_name" {
  description = "The Azuremonitor Resource Group name. If not defined the Azuremonitor whould be placed at the related Action Group Resource Group"
  type        = string
  default     = null
}

variable "action_group_name" {
  description = "The name of the Action Group"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The id of the loganalytics workspace"
  type        = string
  default     = null
}
variable "metric_alert" {
  description = <<EOF

    An object which contains various parameters for monitor metric alert:
    `name`                     - The name of the Metric Alert. Changing this forces a new resource to be created.
    `metric_alert_scopes`      - A set of strings of resource IDs at which the metric criteria should be applied.
    `description`              - The description of this Metric Alert.
    `enabled`                  - Should this Metric Alert be enabled? Defaults to `true`.
    `auto_mitigate`            - Should the alerts in this Metric Alert be auto resolved? Defaults to `true`.
    `frequency`                - The evaluation frequency of this Metric Alert, represented in ISO 8601 duration 
    format. Possible values are `PT1M`, `PT5M`, `PT15M`, `PT30M` and `PT1H`. Defaults to `PT1M`.
    `severity`                 - The severity of this Metric Alert. Possible values are `0`, `1`, `2`, `3` and `4`.
     Defaults to `3`.
    `target_resource_type`     - The resource type (e.g. `Microsoft.Compute/virtualMachines`) of the target resource.
    `target_resource_location` - The location of the target resource.
    `window_size`              - The period of time that is used to monitor alert activity, represented in ISO 8601
     duration format. This value must be greater than frequency. Possible values are `PT1M`, `PT5M`, `PT15M`, `PT30M`, `PT1H`, `PT6H`, `PT12H` and `P1D`. Defaults to `PT5M`.
    `criteria`                 - Criteria parameters.
            `metric_namespace`        - One of the metric namespaces to be monitored.
            `metric_name`             - One of the metric names to be monitored.
            `aggregation`             - The statistic that runs over the metric values. Possible values are `Average`,
             `Count`, `Minimum`, `Maximum` and `Total`.
            `operator`                - The criteria operator. Possible values are `Equals`, `NotEquals`,
            `GreaterThan`, `GreaterThanOrEqual`, `LessThan` and `LessThanOrEqual`.
            `threshold`               - The criteria threshold value that activates the alert.
            `skip_metric_validation`  - Skip the metric validation to allow creating an alert rule on a custom metric
             that isn't yet emitted? Defaults to `false`.
            `dimension`               - Dimension parameters.
                 `name`     - One of the dimension names.
                 `operator` - The dimension operator. Possible values are `Include`, `Exclude` and `StartsWith`.
                 `values`   - The list of dimension values.
    `dynamic_criteria`         - Dynamic criteria parameters.
            `metric_namespace`         - One of the metric namespaces to be monitored.
            `metric_name`              - One of the metric names to be monitored.
            `aggregation`              - The statistic that runs over the metric values. Possible values are `Average`,
             `Count`, `Minimum`, `Maximum` and `Total`.
            `operator`                 - The criteria operator. Possible values are `LessThan`, `GreaterThan` and 
            `GreaterOrLessThan`.
            `alert_sensitivity`        - The extent of deviation required to trigger an alert. Possible values are 
            `Low`, `Medium` and `High`.
            `evaluation_total_count`   - The number of aggregated lookback points. The lookback time window is 
            calculated based on the aggregation granularity (window_size) and the selected number of aggregated points.
            `evaluation_failure_count` - The number of violations to trigger an alert. Should be smaller or equal to 
            `evaluation_total_count`.
            `ignore_data_before`       - The `ISO8601` date from which to start learning the metric historical data 
            and calculate the dynamic thresholds.
            `skip_metric_validation`   - Skip the metric validation to allow creating an alert rule on a custom metric
             that isn't yet emitted? Defaults to `false`.
            `dimension`                - Dimension parameters.
                 `name`     - One of the dimension names.
                 `operator` - The dimension operator. Possible values are `Include`, `Exclude` and `StartsWith`.
                 `values`   - The list of dimension values.
    `application_insights_web_test_location_availability_criteria`  - Application insights web test location
     availability criteria parameters.
            `web_test_id`              - The ID of the Application Insights Web Test.
            `component_id`             - The ID of the Application Insights Resource.
            `failed_location_count`    - The number of failed locations.
    `action` - Action parameters.
            `webhook_properties`       - The map of custom string properties to include with the post operation.
             These data are appended to the webhook payload.

  EOF
  default     = []
  type        = any
}

variable "scheduled_query_rules_alert" {
  description = <<EOF

  An object which contains various parameters for scheduled query rules alert:

      `name`                    - The name of the scheduled query rule. Changing this forces a new resource to be created.
      `location`                - The location of the scheduled query rule.
      `description`             - The description of the scheduled query rule.
      `enabled`                 - Whether this scheduled query rule is enabled. Default is `true`.
      `frequency`               - Frequency (in minutes) at which rule condition should be evaluated. Values must be 
      between `5` and `1440` (inclusive).
      `time_window`             - Time window for which data needs to be fetched for query (must be greater than or 
      equal to `frequency`). Values must be between `5` and `2880` (inclusive).
      `severity`                - Severity of the alert. Possible values include: `0`, `1`, `2`, `3`, or `4`.
      `throttling`              - Time (in minutes) for which Alerts should be throttled or suppressed. Values must 
      be between `0` and `10000` (inclusive).
      `authorized_resource_ids` - List of Resource IDs referred into query.
      `auto_mitigation_enabled` - Should the alerts in this Metric Alert be auto resolved? Defaults to `false`. 
      `NOTE` `auto_mitigation_enabled` and `throttling` are mutually exclusive and cannot both be set.
      `query`                   - Log search query.
      `action`                  - Action parameters.
        `email_subject`              - Custom subject override for all email ids in Azure action group.
        `custom_webhook_payload`     - Custom payload to be sent for all webhook payloads in alerting action.
      `trigger`                 - Trigger parameters.
        `operator`       - Evaluation operation for rule - `GreaterThan`, `GreaterThanOrEqual`, `LessThan`, or 
        `LessThanOrEqual`.
        `threshold`      - Result or count threshold based on which rule should be triggered. Values must be between
         `0` and `10000` (inclusive).
        `metric_trigger` - Metric trigger parameters.
            `metric_column`       - Evaluation of metric on a particular column.
            `metric_trigger_type` - Metric Trigger Type - `Consecutive` or `Total`.
            `operator`            - Evaluation operation for rule - `Equal`, `GreaterThan`, `GreaterThanOrEqual`,
             `LessThan`, or `LessThanOrEqual`.
            `threshold`           - The threshold of the metric trigger. Values must be between `0` and `10000` (inclusive).             

  EOF
  default     = []
  type        = any
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
