# Get resource group data
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}
data "azurerm_application_insights" "appinsights" {
  name                = var.appinsights_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Create application insights standard web test
resource "azurerm_application_insights_standard_web_test" "appinsights" {
  for_each                = { for web_test in var.standard_web_tests : web_test.name => web_test }
  name                    = each.value.name
  resource_group_name     = data.azurerm_resource_group.rg.name
  location                = data.azurerm_application_insights.appinsights.location
  application_insights_id = data.azurerm_application_insights.appinsights.id
  geo_locations           = each.value.geo_locations
  description             = try(each.value.description, null)
  enabled                 = try(each.value.enabled, true)
  frequency               = try(each.value.frequency, null)
  timeout                 = try(each.value.timeout, null)
  retry_enabled           = try(each.value.retry_enabled, false)
  tags                    = data.azurerm_application_insights.appinsights.tags

  dynamic "validation_rules" {
    for_each = try(each.value.validation_rules, null) != null ? [each.value.validation_rules] : []
    content {
      expected_status_code        = validation_rules.value.expected_status_code
      ssl_cert_remaining_lifetime = validation_rules.value.ssl_cert_remaining_lifetime
      ssl_check_enabled           = validation_rules.value.ssl_check_enabled

      dynamic "content" {
        for_each = try(validation_rules.value.content, null) != null ? [validation_rules.value.content] : []
        content {
          content_match      = content.value.content_match
          ignore_case        = content.value.ignore_case
          pass_if_text_found = content.value.pass_if_text_found
        }
      }
    }
  }
  request {
    url                              = each.value.request.url
    body                             = try(each.value.request.body, null)
    follow_redirects_enabled         = try(each.value.request.follow_redirects_enabled, null)
    http_verb                        = try(each.value.request.http_verb, null)
    parse_dependent_requests_enabled = try(each.value.request.parse_dependent_requests_enabled, null)

    dynamic "header" {
      for_each = try(each.value.header, null) != null ? { for header in each.value.header : header.name => header } : {}

      content {
        name  = header.value.name
        value = header.value.value
      }
    }
  }
}

# Create application insights web test
resource "azurerm_application_insights_web_test" "appinsights" {
  for_each                = { for web_test in var.web_tests : web_test.name => web_test }
  name                    = each.value.name
  resource_group_name     = data.azurerm_resource_group.rg.name
  application_insights_id = data.azurerm_application_insights.appinsights.id
  location                = data.azurerm_application_insights.appinsights.location
  kind                    = each.value.kind
  configuration           = each.value.configuration
  geo_locations           = each.value.geo_locations
  frequency               = try(each.value.frequency, null)
  timeout                 = try(each.value.timeout, null)
  enabled                 = try(each.value.enabled, true)
  description             = try(each.value.description, null)
  tags                    = data.azurerm_application_insights.appinsights.tags
}

# Create an application insights analytics items
resource "azurerm_application_insights_analytics_item" "appinsights" {
  for_each                = { for analytics_item in var.analytics_items : analytics_item.name => analytics_item }
  name                    = each.value.name
  application_insights_id = data.azurerm_application_insights.appinsights.id
  type                    = each.value.type
  scope                   = each.value.scope
  content                 = each.value.content
  function_alias          = each.value.function_alias
}

# Create an application insights smart detection rules
resource "azurerm_application_insights_smart_detection_rule" "appinsights" {
  for_each                           = { for smart_detection_rule in var.smart_detection_rules : smart_detection_rule.name => smart_detection_rule }
  name                               = each.value.name
  application_insights_id            = data.azurerm_application_insights.appinsights.id
  enabled                            = each.value.enabled
  send_emails_to_subscription_owners = each.value.send_emails_to_subscription_owners
  additional_email_recipients        = each.value.additional_email_recipients
}