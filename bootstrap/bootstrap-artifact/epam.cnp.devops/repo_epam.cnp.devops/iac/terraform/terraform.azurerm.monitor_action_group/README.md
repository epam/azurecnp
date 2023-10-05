# terraform.azurerm.monitoractiongroup

This module creates a monitor actiongroup with a collection of notification preferences defined by the owner of an Azure subscription

## Prerequisites

| Resource name         | Required  | Description                                               |
|-----------------------|-----------|-----------------------------------------------------------|
| Resource Group        | yes       |                                                           |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.67.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_action_group.monitor_ag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_alert_processing_rule_action_group.rule_ag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_processing_rule_action_group) | resource |
| [azurerm_monitor_alert_processing_rule_suppression.rule_suppression](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_alert_processing_rule_suppression) | resource |



## Usage example

```go
module "monitoractiongroup" {
  source = "git::https://ORGANIZATION_NAME@dev.azure.com/ORGANIZATION_NAME/PROJECT_NAME/_git/terraform.azurerm.monitoractiongroup?ref=v1.1.0"

  action_group_name       = "example-action-group-name"
  action_group_short_name = "example-action-group-short-name"
  rg_name                 = "example-resource-group"
  enabled                 = true

  arm_role_receiver = [
    {
      name                    = "armroleaction"
      role_id                 = "00000000-0000-0000-0000-000000000000"
      use_common_alert_schema = true
    }
  ]

  automation_runbook_receiver = [
    {
      name                    = "action_name_1"
      automation_account_id   = "/subscriptions/12345678-12234-5678-9012-123456789012/resourcegroups/rg-runbooks/providers/microsoft.automation/automationaccounts/aaa001"
      runbook_name            = "my runbook"
      webhook_resource_id     = "/subscriptions/12345678-12234-5678-9012-123456789012/resourcegroups/rg-runbooks/providers/microsoft.automation/automationaccounts/aaa001/webhooks/webhook_alert"
      is_global_runbook       = true
      service_uri             = "https://s13events.azure-automation.net/webhooks?token=randomtoken"
      use_common_alert_schema = true
    }
  ]

  azure_app_push_receiver = [
    {
      name          = "pushtoadmin"
      email_address = "admin@contoso.com"
    }
  ]

  azure_function_receiver = [
    {
      name                     = "funcaction"
      function_app_resource_id = "/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/rg-funcapp/providers/Microsoft.Web/sites/funcapp"
      function_name            = "myfunc"
      http_trigger_url         = "https://example.com/trigger"
      use_common_alert_schema  = true
    }
  ]

  email_receiver = [
    {
      name                    = "sendtodevops"
      email_address           = "devops@contoso.com"
      use_common_alert_schema = true
    }
  ]

  event_hub_receiver = [
    {
      name                    = "sendtoeventhub"
      event_hub_id            = "/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/rg-eventhub/providers/Microsoft.EventHub/namespaces/eventhubnamespace/eventhubs/eventhub1"
      use_common_alert_schema = false
    }
  ]

  itsm_receiver = [
    {
      name                 = "createorupdateticket"
      workspace_id         = "00000000-0000-0000-0000-000000000000"
      connection_id        = "00000000-0000-0000-0000-000000000000"
      ticket_configuration = "{}"
      region               = "southcentralus"
    }
  ]

  logic_app_receiver = [
    {
      name                    = "logicappaction"
      resource_id             = "/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/rg-logicapp/providers/Microsoft.Logic/workflows/logicapp"
      callback_url            = "https://logicapptriggerurl/..."
      use_common_alert_schema = true
    }
  ]

  sms_receiver = [
    {
      name         = "oncallmsg"
      country_code = "1"
      phone_number = "1231231234"
    }
  ]

  voice_receiver = [
    {
      name         = "remotesupport"
      country_code = "86"
      phone_number = "13888888888"
    }
  ]

  webhook_receiver = [
    {
      name                    = "callmyapiaswell"
      service_uri             = "http://example.com/alert"
      use_common_alert_schema = true
      aad_auth = {
        object_id      = "00000000-0000-0000-0000-000000000000"
        identifier_uri = "https://identifier_uri/..."
        tenant_id      = "00000000-0000-0000-0000-000000000000"
      }
    }
  ]

  rule_action_group = [
    {
      name        = "alert-processing-rule-01"
      scopes      = ["/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/example-rg"]
      enabled     = true
      description = "Alert processing rule description"
      tags        = {}
      condition = {
        alert_context = {
          operator = "NotEquals"
          values   = ["nsg"]
        }
        alert_rule_id = {
          operator = "Contains"
          values   = ["network"]
        }
        alert_rule_name = {
          operator = "Contains"
          values   = ["Counter"]
        }
        description = {
          operator = "Equals"
          values   = ["Resolved"]
        }
        monitor = {
          operator = "Equals"
          values   = ["Resolved"]
        }
        monitor_service = {
          operator = "Equals"
          values   = ["Resource Health"]
        }
        severity = {
          operator = "Equals"
          values   = ["Sev0", "Sev1"]
        }
        target_resource = {
          operator = "Contains"
          values   = ["/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/example-rg/providers/Microsoft.Compute/virtualMachines/my_vm"]
        }
        target_resource_group = {
          operator = "Equals"
          values   = ["/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/example-rg"]
        }
        target_resource_type = {
          operator = "Equals"
          values   = ["Microsoft.Compute/VirtualMachines"]
        }
      }
      schedule = {
        effective_from  = "2022-01-01T01:02:03"
        effective_until = "2022-02-02T01:02:03"
        time_zone       = "Pacific Standard Time"
        recurrence = {
          daily = {
            start_time = "17:00:00"
            end_time   = "09:00:00"
          }
          weekly = {
            days_of_week = ["Saturday", "Sunday"]
          }
        }
      }
    }
  ]

  action_rule_suppression = [
    {
      name = "suppression-rule1"
      scopes = {
        type         = "ResourceGroup"
        resource_ids = ["/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/example-rg"]
      }
      description = "Alert processing suppression rule description"
      tags        = {}
      enabled     = true
      condition = {
        alert_context = {
          operator = "NotEquals"
          values   = ["nsg"]
        }
        alert_rule_id = {
          operator = "Contains"
          values   = ["network"]
        }
        alert_rule_name = {
          operator = "Contains"
          values   = ["Counter"]
        }
        description = {
          operator = "Equals"
          values   = ["Resolved"]
        }
        monitor = {
          operator = "Equals"
          values   = ["Resolved"]
        }
        monitor_service = {
          operator = "Equals"
          values   = ["Resource Health"]
        }
        severity = {
          operator = "Equals"
          values   = ["Sev0", "Sev1"]
        }
        target_resource = {
          operator = "Contains"
          values   = ["/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/example-rg/providers/Microsoft.Compute/virtualMachines/my_vm"]
        }
        target_resource_group = {
          operator = "Equals"
          values   = ["/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/example-rg"]
        }
        target_resource_type = {
          operator = "Equals"
          values   = ["Microsoft.Compute/VirtualMachines"]
        }
      }
      schedule = {
        effective_from  = "2023-01-01T01:02:03"
        effective_until = "2023-02-02T01:02:03"
        time_zone       = "Pacific Standard Time"
        recurrence = {
          daily = {
            start_time = "10:00:00"
            end_time   = "15:00:00"
          }
          weekly = {
            days_of_week = ["Friday", "Saturday", "Sunday"]
          }
        }
      }
    }
  ]

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
| <a name="input_action_group_name"></a> [action\_group\_name](#input\_action\_group\_name) | The name of the Action Group | `string` | n/a | yes |
| <a name="input_action_group_short_name"></a> [action\_group\_short\_name](#input\_action\_group\_short\_name) | The short name of the action group. This will be used in SMS messages | `string` | n/a | yes |
| <a name="input_action_rule_suppression"></a> [action\_rule\_suppression](#input\_action\_rule\_suppression) | A list of objects which contains the suppression rules | <pre>list(object({<br>    name        = string<br>    scopes      = list(string)<br>    description = optional(string)<br>    tags        = optional(map(string))<br>    enabled     = optional(bool)<br>    condition = optional(object({<br>      alert_context = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      alert_rule_id = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      alert_rule_name = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      description = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      monitor_condition = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      monitor_service = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      signal_type = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      target_resource = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      target_resource_group = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      target_resource_type = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>    }))<br>    schedule = optional(object({<br>      effective_from  = optional(string)<br>      effective_until = optional(string)<br>      time_zone       = optional(string)<br>      recurrence = optional(object({<br>        daily = optional(object({<br>          start_time = string<br>          end_time   = string<br>        }))<br>        weekly = optional(object({<br>          days_of_week = list(string)<br>          start_time   = optional(string)<br>          end_time     = optional(string)<br>        }))<br>        monthly = optional(object({<br>          days_of_month = list(string)<br>          start_time    = optional(string)<br>          end_time      = optional(string)<br>        }))<br>      }))<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_arm_role_receiver"></a> [arm\_role\_receiver](#input\_arm\_role\_receiver) | A list of objects which contains ARM role receiver, ARM role id, boolean flag for common alert schema | `list(any)` | `[]` | no |
| <a name="input_automation_runbook_receiver"></a> [automation\_runbook\_receiver](#input\_automation\_runbook\_receiver) | A list of objects which contains name of the runbook receiver, automation account id, runbook name, webhook resource id, global runbook boolean flag, the uri for webhooks, boolean flag for common alert schema | `list(any)` | `[]` | no |
| <a name="input_azure_app_push_receiver"></a> [azure\_app\_push\_receiver](#input\_azure\_app\_push\_receiver) | A list of objects which contains The name of the app push receiver, the email address of the user signed into the mobile app who will receive push notifications from this receiver | `list(any)` | `[]` | no |
| <a name="input_azure_function_receiver"></a> [azure\_function\_receiver](#input\_azure\_function\_receiver) | A list of objects which contains the function receiver name, function app resource id, function app name, http trigger url, boolean flag for common alert schema | `list(any)` | `[]` | no |
| <a name="input_email_receiver"></a> [email\_receiver](#input\_email\_receiver) | A list of objects which contains the name of the email receiver, email address of the receiver, boolean flag for common alert schema | `list(any)` | `[]` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether this action group is enabled. If an action group is not enabled, then none of its receivers will receive communications | `bool` | `true` | no |
| <a name="input_event_hub_receiver"></a> [event\_hub\_receiver](#input\_event\_hub\_receiver) | A list of objects which contains the name of the EventHub receiver, Event Hub resource id, Tenant ID for the subscription containing the Event Hub, boolean flag for common alert schema | `list(any)` | `[]` | no |
| <a name="input_itsm_receiver"></a> [itsm\_receiver](#input\_itsm\_receiver) | A list of objects which contains ITSM receiver name, Log Analytics workspace id, unique connection identifier, a JSON blob for the configurations of the ITSM action, the workspace region | `list(any)` | `[]` | no |
| <a name="input_logic_app_receiver"></a> [logic\_app\_receiver](#input\_logic\_app\_receiver) | A list of objects which contains logic app receiver name, logic app resource id, callback url, boolean flag for common alert schema | `list(any)` | `[]` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the Resource Group | `string` | n/a | yes |
| <a name="input_rule_action_group"></a> [rule\_action\_group](#input\_rule\_action\_group) | A list of objects which contains the action group rules | <pre>list(object({<br>    name        = string<br>    scopes      = list(string)<br>    enabled     = optional(bool)<br>    description = optional(string)<br>    tags        = optional(map(string))<br>    condition = optional(object({<br>      alert_context = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      alert_rule_id = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      alert_rule_name = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      description = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      monitor_condition = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      monitor_service = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      signal_type = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      target_resource = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      target_resource_group = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>      target_resource_type = optional(object({<br>        operator = string<br>        values   = list(string)<br>      }))<br>    }))<br>    schedule = optional(object({<br>      effective_from  = optional(string)<br>      effective_until = optional(string)<br>      time_zone       = optional(string)<br>      recurrence = optional(object({<br>        daily = optional(object({<br>          start_time = string<br>          end_time   = string<br>        }))<br>        weekly = optional(object({<br>          days_of_week = list(string)<br>          start_time   = optional(string)<br>          end_time     = optional(string)<br>        }))<br>        monthly = optional(object({<br>          days_of_month = list(string)<br>          start_time    = optional(string)<br>          end_time      = optional(string)<br>        }))<br>      }))<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_sms_receiver"></a> [sms\_receiver](#input\_sms\_receiver) | A list of objects which contains the SMS receiver name, country code of the SMS receiver, phone number of the SMS receiver | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Web Application Firewall Policy | `map(string)` | `{}` | no |
| <a name="input_voice_receiver"></a> [voice\_receiver](#input\_voice\_receiver) | A list of objects which contains the voice receiver name, country code of the voice receiver, phone number of the voice receiver | `list(any)` | `[]` | no |
| <a name="input_webhook_receiver"></a> [webhook\_receiver](#input\_webhook\_receiver) | A list of objects which contains the webhook receiver name, uri for webhooks, boolean flag for common alert schema | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | The ID of the Action Group |
| <a name="output_action_group_rule_id"></a> [action\_group\_rule\_id](#output\_action\_group\_rule\_id) | The ID of the Monitor Action Rule |
| <a name="output_action_group_suppression_rule_id"></a> [action\_group\_suppression\_rule\_id](#output\_action\_group\_suppression\_rule\_id) | The ID of the Monitor Action Suppression Rule |