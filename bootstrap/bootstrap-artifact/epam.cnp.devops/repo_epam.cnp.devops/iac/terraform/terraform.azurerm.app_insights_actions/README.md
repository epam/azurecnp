# terraform.azurerm.appinsightsactions

This module deploys the application insights' resources such as:

- Application Insights Standard WebTest
- Application Insights WebTest

## Prerequisites

| Resource name | Required | Description |
|---------------|----------|-------------|
| resource group         | yes   |       |
| application insights   | yes   |       |

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
| [azurerm_application_insights_analytics_item.appinsights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_analytics_item) | resource |
| [azurerm_application_insights_smart_detection_rule.appinsights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_smart_detection_rule) | resource |
| [azurerm_application_insights_standard_web_test.appinsights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_standard_web_test) | resource |
| [azurerm_application_insights_web_test.appinsights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_web_test) | resource |
| [azurerm_application_insights.appinsights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |



## Usage example

```go
module "appinsightsactions" {
  source = "git::https://ORGANIZATION_NAME@dev.azure.com/ORGANIZATION_NAME/PROJECT_NAME/_git/terraform.azurerm.app_insights_actions?ref=v2.1.0"

  rg_name          = "example-rg"
  appinsights_name = "example-appinsight"

  standard_web_tests = [
    {
      name          = "example-standard-test-01"
      geo_locations = ["example"]
      description   = "Example standard web test"
      enabled       = true
      frequency     = 300
      timeout       = 30
      retry_enabled = true

      request = {
        url                              = "http://www.example.com"
        body                             = null
        follow_redirects_enabled         = true
        http_verb                        = "GET"
        parse_dependent_requests_enabled = true

        header = [
          {
            name  = "Authorization"
            value = "Bearer"
          },
          {
            name  = "text"
            value = "hello"
          }
        ]
      }

      validation_rules = {
        expected_status_code        = 200
        ssl_cert_remaining_lifetime = 30
        ssl_check_enabled           = true

        content = {
          content_match      = "Example content"
          ignore_case        = true
          pass_if_text_found = true
        }
      }
    }
  ]

  web_tests = [
    {
      name          = "example-test-01"
      kind          = "ping"
      description   = "Example standard web test"
      geo_locations = ["emea-fr-pra-edge"]
      frequency     = "600"
      timeout       = 30
      enabled       = true
      configuration = <<XML
      <WebTest Name="WebTest1" Id="ABD48585-0831-40CB-9069-682EA6BB3583" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="0" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
        <Items>
          <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="http://microsoft.com" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
        </Items>
      </WebTest>
      XML
    }
  ]
  analytics_items = [
    {
      name           = "example-analytics-item-01"
      type           = "query"
      scope          = "shared"
      content        = "requests //simple example query"
      function_alias = null
    }
  ]
  smart_detection_rules = [
    {
      name                               = "Slow server response time"
      enabled                            = false
      send_emails_to_subscription_owners = false
      additional_email_recipients        = ["user@example.com"]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_analytics_items"></a> [analytics\_items](#input\_analytics\_items) | The variable contains arguments for creating resources "azurerm\_application\_insights\_analytics\_item":<br><br>  `name`           - Specifies the name of the Application Insights Analytics Item. <br>                     Changing this forces a new resource to be created.<br>  `type`           - The type of Analytics Item to create. Can be one of `query`, `function`, `folder`, `recent`. <br>                     Changing this forces a new resource to be created.<br>  `scope`          - The scope for the Analytics Item. Can be `shared` or `user`. <br>                     Changing this forces a new resource to be created. Must be shared for functions.<br>  `content`        - The content for the Analytics Item, for example the query text if `type` is `query`.<br>  `function_alias` - The alias to use for the function. Required when `type` is `function`. | <pre>list(object({<br>    name           = string<br>    type           = string<br>    scope          = string<br>    content        = string<br>    function_alias = string<br>  }))</pre> | `[]` | no |
| <a name="input_appinsights_name"></a> [appinsights\_name](#input\_appinsights\_name) | Specifies the name of the Application Insights component. Changing this forces a new resource<br>  to be created. | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group in which to create the appinsight. Changing this forces a new <br>  resource to be created. | `string` | n/a | yes |
| <a name="input_smart_detection_rules"></a> [smart\_detection\_rules](#input\_smart\_detection\_rules) | The variable contains arguments for creating resources "azurerm\_application\_insights\_smart\_detection\_rule":<br><br>  `name` - Specifies the name of the Application Insights Smart Detection Rule. Valid values include <br>           `Slow page load time`, `Slow server response time`, `Long dependency duration`, <br>           `Degradation in server response time`, `Degradation in dependency duration`, <br>           `Degradation in trace severity ratio`, `Abnormal rise in exception volume`, <br>           `Potential memory leak detected`, `Potential security issue detected and Abnormal rise in daily data volume`, <br>           `Long dependency duration`, `Degradation in server response time`, `Degradation in dependency duration`, <br>           `Degradation in trace severity ratio`, `Abnormal rise in exception volume`, `Potential memory leak detected`, <br>           `Potential security issue detected`, `Abnormal rise in daily data volume`.<br>            Changing this forces a new resource to be created.<br>  `enabled`                            - Is the Application Insights Smart Detection Rule enabled? Defaults to `true`.<br>  `send_emails_to_subscription_owners` - Do emails get sent to subscription owners? Defaults to `true`.<br>  `additional_email_recipients`        - Specifies a list of additional recipients that will be sent emails <br>                                         on this Application Insights Smart Detection Rule. | <pre>list(object({<br>    name                               = string<br>    enabled                            = bool<br>    send_emails_to_subscription_owners = bool<br>    additional_email_recipients        = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_standard_web_tests"></a> [standard\_web\_tests](#input\_standard\_web\_tests) | The variable contains arguments for creating resources "azurerm\_application\_insights\_standard\_web\_test"<br>  Required arguments:<br><br>  `name`          - The name which should be used for this Application Insights Standard WebTest.<br>                    Changing this forces a new Application Insights Standard WebTest to be created.<br>  `geo_locations` - A list of where to physically run the tests from to give global coverage for<br>                    accessibility of your application. Valid options for geo locations are described here:<br>                    https://learn.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability#location-population-tags<br><br>  `request`       - This object describes request settings and includes:<br><br>            `url`                              - (Required) The WebTest request URL.<br>            `body`                             - (Optional) The WebTest request body.<br>            `follow_redirects_enabled`         - (Optional) Should the following of redirects be enabled?<br>                                                 Defaults to `true`.<br>            `http_verb`                        - (Optional) Which HTTP verb to use for the call. <br>                                                 Options are 'GET', 'POST', 'PUT', 'PATCH', and 'DELETE'.<br>            `parse_dependent_requests_enabled` - (Optional) Should the parsing of dependend requests be enabled? <br>                                                 Defaults to `true`.<br><br>            `header`                           - (Optional)This is the list of objects. Each object includes:<br><br>                    `name`  - (Required) The name which should be used for a header in the request.<br>                    `value` - (Required) The value which should be used for a header in the request.<br><br><br>  Optional arguments:<br><br>  `description`      - Purpose/user defined descriptive test for this WebTest.<br>  `enabled`          - Should the WebTest be enabled?<br>  `frequency`        - Interval in seconds between test runs for this WebTest.<br>                       Valid options are 300, 600 and 900. Defaults to 300.<br>  `timeout`          - Seconds until this WebTest will timeout and fail. Default is 30.<br>  `retry_enabled`    - Should the retry on WebTest failure be enabled?<br><br>  `validation_rules` - This object describes validation rules settings and includes:<br><br>        `expected_status_code`        - (Optional) The expected status code of the response. Default is '200', <br>                                        '0' means 'response code < 400'<br>        `ssl_cert_remaining_lifetime` - (Optional) The number of days of SSL certificate validity remaining <br>                                        for the checked endpoint. If the certificate has a shorter <br>                                        remaining lifetime left, the test will fail. <br>                                        This number should be between `1 and 365`.<br>        `ssl_check_enabled`           - (Optional) Should the SSL check be enabled?<br><br>        `content`                     - (Optional) This object describes the content settings and includes:<br><br>              `content_match`      - (Required) A string value containing the content to match on.<br>              `ignore_case`        - (Optional) Ignore the casing in the `content_match` value.<br>              `pass_if_text_found` - (Optional) If the content of `content_match` is found, pass the test.<br>                                     If set to `false`, the WebTest is failing if the content of `content_match` <br>                                     is found. | `list(any)` | `[]` | no |
| <a name="input_web_tests"></a> [web\_tests](#input\_web\_tests) | The variable contains arguments for creating resources "azurerm\_application\_insights\_web\_test"<br>  `name`          -  Specifies the name of the Application Insights WebTest<br>  `kind`          - The kind of web test that this web test watches. Choices are "ping" and "multistep"<br>  `description`   - Purpose/user defined descriptive test for this WebTest.<br>  `geo_locations` - A list of where to physically run the tests from to give global coverage for<br>                    accessibility of your application. Valid options for geo locations are described here:<br>                    https://learn.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability#location-population-tags<br>  `configuration` - An XML configuration specification for a WebTest. See here for more information:<br>                    https://learn.microsoft.com/en-us/rest/api/application-insights/web-tests/create-or-update?tabs=HTTP<br>  `frequency`     - Interval in seconds between test runs for this WebTest. Valid options are "300", "600" and "900".<br>  `timeout`       - Seconds until this WebTest will timeout and fail. <br>  `enabled`       - Is the test actively being monitored. | <pre>list(object({<br>    name          = string<br>    kind          = string<br>    description   = string<br>    geo_locations = list(string)<br>    configuration = string<br>    frequency     = string<br>    timeout       = string<br>    enabled       = bool<br>  }))</pre> | `[]` | no |

