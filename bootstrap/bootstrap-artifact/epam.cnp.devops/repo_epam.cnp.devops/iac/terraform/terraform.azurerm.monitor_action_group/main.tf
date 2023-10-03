# Create monitor action group
resource "azurerm_monitor_action_group" "monitor_ag" {
  name                = var.action_group_name
  resource_group_name = var.rg_name
  short_name          = var.action_group_short_name
  enabled             = var.enabled
  tags                = var.tags

  dynamic "arm_role_receiver" {
    for_each = var.arm_role_receiver
    content {
      name                    = arm_role_receiver.value.name
      role_id                 = arm_role_receiver.value.role_id
      use_common_alert_schema = try(arm_role_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "automation_runbook_receiver" {
    for_each = var.automation_runbook_receiver
    content {
      name                    = automation_runbook_receiver.value.name
      automation_account_id   = automation_runbook_receiver.value.automation_account_id
      runbook_name            = automation_runbook_receiver.value.runbook_name
      webhook_resource_id     = automation_runbook_receiver.value.webhook_resource_id
      is_global_runbook       = automation_runbook_receiver.value.is_global_runbook
      service_uri             = automation_runbook_receiver.value.service_uri
      use_common_alert_schema = try(automation_runbook_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "azure_app_push_receiver" {
    for_each = var.azure_app_push_receiver
    content {
      name          = azure_app_push_receiver.value.name
      email_address = azure_app_push_receiver.value.email_address
    }
  }

  dynamic "azure_function_receiver" {
    for_each = var.azure_function_receiver
    content {
      name                     = azure_function_receiver.value.name
      function_app_resource_id = azure_function_receiver.value.function_app_resource_id
      function_name            = azure_function_receiver.value.function_name
      http_trigger_url         = azure_function_receiver.value.http_trigger_url
      use_common_alert_schema  = try(azure_function_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "email_receiver" {
    for_each = var.email_receiver
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = try(email_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "event_hub_receiver" {
    for_each = var.event_hub_receiver
    content {
      name                    = event_hub_receiver.value.name
      event_hub_id            = event_hub_receiver.value.event_hub_id
      tenant_id               = try(event_hub_receiver.value.tenant_id, null)
      use_common_alert_schema = try(event_hub_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "itsm_receiver" {
    for_each = var.itsm_receiver
    content {
      name                 = itsm_receiver.value.name
      workspace_id         = itsm_receiver.value.workspace_id
      connection_id        = itsm_receiver.value.connection_id
      ticket_configuration = itsm_receiver.value.ticket_configuration
      region               = itsm_receiver.value.region
    }
  }

  dynamic "logic_app_receiver" {
    for_each = var.logic_app_receiver
    content {
      name                    = logic_app_receiver.value.name
      resource_id             = logic_app_receiver.value.resource_id
      callback_url            = logic_app_receiver.value.callback_url
      use_common_alert_schema = try(logic_app_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "sms_receiver" {
    for_each = var.sms_receiver
    content {
      name         = sms_receiver.value.name
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  dynamic "voice_receiver" {
    for_each = var.voice_receiver
    content {
      name         = voice_receiver.value.name
      country_code = voice_receiver.value.country_code
      phone_number = voice_receiver.value.phone_number
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.webhook_receiver
    content {
      name                    = webhook_receiver.value.name
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = try(webhook_receiver.value.use_common_alert_schema, true)

      dynamic "aad_auth" {
        for_each = try(webhook_receiver.value.aad_auth, null) != null ? [webhook_receiver.value.aad_auth] : []
        content {
          object_id      = aad_auth.value.object_id
          identifier_uri = try(aad_auth.value.identifier_uri, null)
          tenant_id      = try(aad_auth.value.tenant_id, null)
        }
      }
    }
  }
}

#############################################################
#   Create Monitor Action Rule which type is action group   #
#############################################################
resource "azurerm_monitor_alert_processing_rule_action_group" "rule_ag" {
  for_each             = { for rule in var.rule_action_group : rule.name => rule }
  name                 = each.value.name
  resource_group_name  = var.rg_name
  scopes               = each.value.scopes
  enabled              = try(each.value.enabled, null)
  add_action_group_ids = [azurerm_monitor_action_group.monitor_ag.id]
  description          = try(each.value.description, null)
  tags                 = var.tags
  dynamic "condition" {
    for_each = try(each.value.condition, null) != null ? [each.value.condition] : []
    content {

      dynamic "alert_context" {
        for_each = try(each.value.condition["alert_context"], null) != null ? [each.value.condition["alert_context"]] : []
        content {
          operator = alert_context.value.operator
          values   = alert_context.value.values
        }
      }

      dynamic "alert_rule_id" {
        for_each = try(each.value.condition["alert_rule_id"], null) != null ? [each.value.condition["alert_rule_id"]] : []
        content {
          operator = alert_rule_id.value.operator
          values   = alert_rule_id.value.values
        }
      }

      dynamic "alert_rule_name" {
        for_each = try(each.value.condition["alert_rule_name"], null) != null ? [each.value.condition["alert_rule_name"]] : []
        content {
          operator = alert_rule_name.value.operator
          values   = alert_rule_name.value.values
        }
      }

      dynamic "description" {
        for_each = try(each.value.condition["description"], null) != null ? [each.value.condition["description"]] : []
        content {
          operator = description.value.operator
          values   = description.value.values
        }
      }

      dynamic "monitor_condition" {
        for_each = try(each.value.condition["monitor_condition"], null) != null ? [each.value.condition["monitor_condition"]] : []
        content {
          operator = monitor_condition.value.operator
          values   = monitor_condition.value.values
        }
      }

      dynamic "monitor_service" {
        for_each = try(each.value.condition["monitor_service"], null) != null ? [each.value.condition["monitor_service"]] : []
        content {
          operator = monitor_service.value.operator
          values   = monitor_service.value.values
        }
      }

      dynamic "severity" {
        for_each = try(each.value.condition["severity"], null) != null ? [each.value.condition["severity"]] : []
        content {
          operator = severity.value.operator
          values   = severity.value.values
        }
      }

      dynamic "signal_type" {
        for_each = try(each.value.condition["signal_type"], null) != null ? [each.value.condition["signal_type"]] : []
        content {
          operator = signal_type.value.operator
          values   = signal_type.value.values
        }
      }

      dynamic "target_resource" {
        for_each = try(each.value.condition["target_resource"], null) != null ? [each.value.condition["target_resource"]] : []
        content {
          operator = target_resource.value.operator
          values   = target_resource.value.values
        }
      }

      dynamic "target_resource_group" {
        for_each = try(each.value.condition["target_resource_group"], null) != null ? [each.value.condition["target_resource_group"]] : []
        content {
          operator = target_resource_group.value.operator
          values   = target_resource_group.value.values
        }
      }

      dynamic "target_resource_type" {
        for_each = try(each.value.condition["target_resource_type"], null) != null ? [each.value.condition["target_resource_type"]] : []
        content {
          operator = target_resource_type.value.operator
          values   = target_resource_type.value.values
        }
      }
    }
  }

  dynamic "schedule" {
    for_each = try(each.value.schedule, null) != null ? [each.value.schedule] : []
    content {
      effective_from  = schedule.value.effective_from
      effective_until = schedule.value.effective_until
      time_zone       = schedule.value.time_zone
      recurrence {
        daily {
          start_time = schedule.value.recurrence.daily.start_time
          end_time   = schedule.value.recurrence.daily.end_time
        }
        weekly {
          days_of_week = schedule.value.recurrence.weekly.days_of_week
        }
      }
    }
  }
}

#############################################################
#   Create Monitor Action Rule which type is suppression    #
#############################################################
resource "azurerm_monitor_alert_processing_rule_suppression" "rule_suppression" {
  for_each            = { for rule_suppression in var.action_rule_suppression : rule_suppression.name => rule_suppression }
  name                = each.value.name
  resource_group_name = var.rg_name
  scopes              = each.value.scopes
  enabled             = try(each.value.enabled, null)
  description         = try(each.value.description, null)
  tags                = var.tags

  dynamic "condition" {
    for_each = try(each.value.condition, null) != null ? [each.value.condition] : []
    content {

      dynamic "alert_context" {
        for_each = try(each.value.condition["alert_context"], null) != null ? [each.value.condition["alert_context"]] : []
        content {
          operator = alert_context.value.operator
          values   = alert_context.value.values
        }
      }

      dynamic "alert_rule_id" {
        for_each = try(each.value.condition["alert_rule_id"], null) != null ? [each.value.condition["alert_rule_id"]] : []
        content {
          operator = alert_rule_id.value.operator
          values   = alert_rule_id.value.values
        }
      }

      dynamic "alert_rule_name" {
        for_each = try(each.value.condition["alert_rule_name"], null) != null ? [each.value.condition["alert_rule_name"]] : []
        content {
          operator = alert_rule_name.value.operator
          values   = alert_rule_name.value.values
        }
      }

      dynamic "description" {
        for_each = try(each.value.condition["description"], null) != null ? [each.value.condition["description"]] : []
        content {
          operator = description.value.operator
          values   = description.value.values
        }
      }

      dynamic "monitor_condition" {
        for_each = try(each.value.condition["monitor_condition"], null) != null ? [each.value.condition["monitor_condition"]] : []
        content {
          operator = monitor_condition.value.operator
          values   = monitor_condition.value.values
        }
      }

      dynamic "monitor_service" {
        for_each = try(each.value.condition["monitor_service"], null) != null ? [each.value.condition["monitor_service"]] : []
        content {
          operator = monitor_service.value.operator
          values   = monitor_service.value.values
        }
      }

      dynamic "severity" {
        for_each = try(each.value.condition["severity"], null) != null ? [each.value.condition["severity"]] : []
        content {
          operator = severity.value.operator
          values   = severity.value.values
        }
      }

      dynamic "signal_type" {
        for_each = try(each.value.condition["signal_type"], null) != null ? [each.value.condition["signal_type"]] : []
        content {
          operator = signal_type.value.operator
          values   = signal_type.value.values
        }
      }

      dynamic "target_resource" {
        for_each = try(each.value.condition["target_resource"], null) != null ? [each.value.condition["target_resource"]] : []
        content {
          operator = target_resource.value.operator
          values   = target_resource.value.values
        }
      }

      dynamic "target_resource_group" {
        for_each = try(each.value.condition["target_resource_group"], null) != null ? [each.value.condition["target_resource_group"]] : []
        content {
          operator = target_resource_group.value.operator
          values   = target_resource_group.value.values
        }
      }

      dynamic "target_resource_type" {
        for_each = try(each.value.condition["target_resource_type"], null) != null ? [each.value.condition["target_resource_type"]] : []
        content {
          operator = target_resource_type.value.operator
          values   = target_resource_type.value.values
        }
      }
    }
  }

  dynamic "schedule" {
    for_each = try(each.value.schedule, null) != null ? [each.value.schedule] : []
    content {
      effective_from  = schedule.value.effective_from
      effective_until = schedule.value.effective_until
      time_zone       = schedule.value.time_zone
      recurrence {
        daily {
          start_time = schedule.value.recurrence.daily.start_time
          end_time   = schedule.value.recurrence.daily.end_time
        }
        weekly {
          days_of_week = schedule.value.recurrence.weekly.days_of_week
        }
      }
    }
  }
}
