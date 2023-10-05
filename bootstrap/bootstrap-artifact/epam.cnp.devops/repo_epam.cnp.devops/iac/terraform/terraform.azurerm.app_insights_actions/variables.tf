variable "rg_name" {
  description = <<EOF
  The name of the resource group in which to create the appinsight. Changing this forces a new 
  resource to be created.
  EOF
  type        = string
}

variable "appinsights_name" {
  description = <<EOF
  Specifies the name of the Application Insights component. Changing this forces a new resource
  to be created.
  EOF
  type        = string
}

variable "standard_web_tests" {
  description = <<EOF
  The variable contains arguments for creating resources "azurerm_application_insights_standard_web_test"
  Required arguments:

  `name`          - The name which should be used for this Application Insights Standard WebTest.
                    Changing this forces a new Application Insights Standard WebTest to be created.
  `geo_locations` - A list of where to physically run the tests from to give global coverage for
                    accessibility of your application. Valid options for geo locations are described here:
                    https://learn.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability#location-population-tags

  `request`       - This object describes request settings and includes:

            `url`                              - (Required) The WebTest request URL.
            `body`                             - (Optional) The WebTest request body.
            `follow_redirects_enabled`         - (Optional) Should the following of redirects be enabled?
                                                 Defaults to `true`.
            `http_verb`                        - (Optional) Which HTTP verb to use for the call. 
                                                 Options are 'GET', 'POST', 'PUT', 'PATCH', and 'DELETE'.
            `parse_dependent_requests_enabled` - (Optional) Should the parsing of dependend requests be enabled? 
                                                 Defaults to `true`.

            `header`                           - (Optional)This is the list of objects. Each object includes:

                    `name`  - (Required) The name which should be used for a header in the request.
                    `value` - (Required) The value which should be used for a header in the request.

  
  Optional arguments:

  `description`      - Purpose/user defined descriptive test for this WebTest.
  `enabled`          - Should the WebTest be enabled?
  `frequency`        - Interval in seconds between test runs for this WebTest.
                       Valid options are 300, 600 and 900. Defaults to 300.
  `timeout`          - Seconds until this WebTest will timeout and fail. Default is 30.
  `retry_enabled`    - Should the retry on WebTest failure be enabled?

  `validation_rules` - This object describes validation rules settings and includes:

        `expected_status_code`        - (Optional) The expected status code of the response. Default is '200', 
                                        '0' means 'response code < 400'
        `ssl_cert_remaining_lifetime` - (Optional) The number of days of SSL certificate validity remaining 
                                        for the checked endpoint. If the certificate has a shorter 
                                        remaining lifetime left, the test will fail. 
                                        This number should be between `1 and 365`.
        `ssl_check_enabled`           - (Optional) Should the SSL check be enabled?

        `content`                     - (Optional) This object describes the content settings and includes:

              `content_match`      - (Required) A string value containing the content to match on.
              `ignore_case`        - (Optional) Ignore the casing in the `content_match` value.
              `pass_if_text_found` - (Optional) If the content of `content_match` is found, pass the test.
                                     If set to `false`, the WebTest is failing if the content of `content_match` 
                                     is found.
  EOF
  type        = list(any)
  default     = []
}

variable "web_tests" {
  description = <<EOF
  The variable contains arguments for creating resources "azurerm_application_insights_web_test"
  `name`          -  Specifies the name of the Application Insights WebTest
  `kind`          - The kind of web test that this web test watches. Choices are "ping" and "multistep"
  `description`   - Purpose/user defined descriptive test for this WebTest.
  `geo_locations` - A list of where to physically run the tests from to give global coverage for
                    accessibility of your application. Valid options for geo locations are described here:
                    https://learn.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability#location-population-tags
  `configuration` - An XML configuration specification for a WebTest. See here for more information:
                    https://learn.microsoft.com/en-us/rest/api/application-insights/web-tests/create-or-update?tabs=HTTP
  `frequency`     - Interval in seconds between test runs for this WebTest. Valid options are "300", "600" and "900".
  `timeout`       - Seconds until this WebTest will timeout and fail. 
  `enabled`       - Is the test actively being monitored.
  EOF
  type = list(object({
    name          = string
    kind          = string
    description   = string
    geo_locations = list(string)
    configuration = string
    frequency     = string
    timeout       = string
    enabled       = bool
  }))
  default = []
}

variable "analytics_items" {
  description = <<EOF
  The variable contains arguments for creating resources "azurerm_application_insights_analytics_item":

  `name`           - Specifies the name of the Application Insights Analytics Item. 
                     Changing this forces a new resource to be created.
  `type`           - The type of Analytics Item to create. Can be one of `query`, `function`, `folder`, `recent`. 
                     Changing this forces a new resource to be created.
  `scope`          - The scope for the Analytics Item. Can be `shared` or `user`. 
                     Changing this forces a new resource to be created. Must be shared for functions.
  `content`        - The content for the Analytics Item, for example the query text if `type` is `query`.
  `function_alias` - The alias to use for the function. Required when `type` is `function`.

  EOF
  type = list(object({
    name           = string
    type           = string
    scope          = string
    content        = string
    function_alias = string
  }))
  default = []
}

variable "smart_detection_rules" {
  description = <<EOF
  The variable contains arguments for creating resources "azurerm_application_insights_smart_detection_rule":

  `name` - Specifies the name of the Application Insights Smart Detection Rule. Valid values include 
           `Slow page load time`, `Slow server response time`, `Long dependency duration`, 
           `Degradation in server response time`, `Degradation in dependency duration`, 
           `Degradation in trace severity ratio`, `Abnormal rise in exception volume`, 
           `Potential memory leak detected`, `Potential security issue detected and Abnormal rise in daily data volume`, 
           `Long dependency duration`, `Degradation in server response time`, `Degradation in dependency duration`, 
           `Degradation in trace severity ratio`, `Abnormal rise in exception volume`, `Potential memory leak detected`, 
           `Potential security issue detected`, `Abnormal rise in daily data volume`.
            Changing this forces a new resource to be created.
  `enabled`                            - Is the Application Insights Smart Detection Rule enabled? Defaults to `true`.
  `send_emails_to_subscription_owners` - Do emails get sent to subscription owners? Defaults to `true`.
  `additional_email_recipients`        - Specifies a list of additional recipients that will be sent emails 
                                         on this Application Insights Smart Detection Rule.

  EOF
  type = list(object({
    name                               = string
    enabled                            = bool
    send_emails_to_subscription_owners = bool
    additional_email_recipients        = list(string)
  }))
  default = []
}