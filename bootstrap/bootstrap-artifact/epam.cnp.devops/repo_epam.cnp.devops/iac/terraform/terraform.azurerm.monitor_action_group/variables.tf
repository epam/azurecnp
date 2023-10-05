variable "rg_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "action_group_name" {
  description = "The name of the Action Group"
  type        = string
}

variable "action_group_short_name" {
  description = "The short name of the action group. This will be used in SMS messages"
  type        = string
}

variable "enabled" {
  description = "Whether this action group is enabled. If an action group is not enabled, then none of its receivers will receive communications"
  type        = bool
  default     = true
}

variable "arm_role_receiver" {
  description = "A list of objects which contains ARM role receiver, ARM role id, boolean flag for common alert schema"
  type        = list(any)
  default     = []
}

variable "automation_runbook_receiver" {
  description = "A list of objects which contains name of the runbook receiver, automation account id, runbook name, webhook resource id, global runbook boolean flag, the uri for webhooks, boolean flag for common alert schema"
  type        = list(any)
  default     = []
}

variable "azure_app_push_receiver" {
  description = "A list of objects which contains The name of the app push receiver, the email address of the user signed into the mobile app who will receive push notifications from this receiver"
  type        = list(any)
  default     = []
}

variable "azure_function_receiver" {
  description = "A list of objects which contains the function receiver name, function app resource id, function app name, http trigger url, boolean flag for common alert schema"
  type        = list(any)
  default     = []
}

variable "email_receiver" {
  description = "A list of objects which contains the name of the email receiver, email address of the receiver, boolean flag for common alert schema"
  type        = list(any)
  default     = []
}

variable "event_hub_receiver" {
  description = "A list of objects which contains the name of the EventHub receiver, Event Hub resource id, Tenant ID for the subscription containing the Event Hub, boolean flag for common alert schema"
  type        = list(any)
  default     = []
}

variable "itsm_receiver" {
  description = "A list of objects which contains ITSM receiver name, Log Analytics workspace id, unique connection identifier, a JSON blob for the configurations of the ITSM action, the workspace region"
  type        = list(any)
  default     = []
}

variable "logic_app_receiver" {
  description = "A list of objects which contains logic app receiver name, logic app resource id, callback url, boolean flag for common alert schema"
  type        = list(any)
  default     = []
}

variable "sms_receiver" {
  description = "A list of objects which contains the SMS receiver name, country code of the SMS receiver, phone number of the SMS receiver"
  type        = list(any)
  default     = []
}

variable "voice_receiver" {
  description = "A list of objects which contains the voice receiver name, country code of the voice receiver, phone number of the voice receiver"
  type        = list(any)
  default     = []
}

variable "webhook_receiver" {
  description = "A list of objects which contains the webhook receiver name, uri for webhooks, boolean flag for common alert schema"
  type        = list(any)
  default     = []
}


variable "tags" {
  description = "A mapping of tags to assign to the Web Application Firewall Policy"
  type        = map(string)
  default     = {}
}

variable "rule_action_group" {
  description = "A list of objects which contains the action group rules"
  type = list(object({
    name        = string
    scopes      = list(string)
    enabled     = optional(bool)
    description = optional(string)
    tags        = optional(map(string))
    condition = optional(object({
      alert_context = optional(object({
        operator = string
        values   = list(string)
      }))
      alert_rule_id = optional(object({
        operator = string
        values   = list(string)
      }))
      alert_rule_name = optional(object({
        operator = string
        values   = list(string)
      }))
      description = optional(object({
        operator = string
        values   = list(string)
      }))
      monitor_condition = optional(object({
        operator = string
        values   = list(string)
      }))
      monitor_service = optional(object({
        operator = string
        values   = list(string)
      }))
      signal_type = optional(object({
        operator = string
        values   = list(string)
      }))
      target_resource = optional(object({
        operator = string
        values   = list(string)
      }))
      target_resource_group = optional(object({
        operator = string
        values   = list(string)
      }))
      target_resource_type = optional(object({
        operator = string
        values   = list(string)
      }))
    }))
    schedule = optional(object({
      effective_from  = optional(string)
      effective_until = optional(string)
      time_zone       = optional(string)
      recurrence = optional(object({
        daily = optional(object({
          start_time = string
          end_time   = string
        }))
        weekly = optional(object({
          days_of_week = list(string)
          start_time   = optional(string)
          end_time     = optional(string)
        }))
        monthly = optional(object({
          days_of_month = list(string)
          start_time    = optional(string)
          end_time      = optional(string)
        }))
      }))
    }))
  }))
  default = []
}

variable "action_rule_suppression" {
  description = "A list of objects which contains the suppression rules"
  type = list(object({
    name        = string
    scopes      = list(string)
    description = optional(string)
    tags        = optional(map(string))
    enabled     = optional(bool)
    condition = optional(object({
      alert_context = optional(object({
        operator = string
        values   = list(string)
      }))
      alert_rule_id = optional(object({
        operator = string
        values   = list(string)
      }))
      alert_rule_name = optional(object({
        operator = string
        values   = list(string)
      }))
      description = optional(object({
        operator = string
        values   = list(string)
      }))
      monitor_condition = optional(object({
        operator = string
        values   = list(string)
      }))
      monitor_service = optional(object({
        operator = string
        values   = list(string)
      }))
      signal_type = optional(object({
        operator = string
        values   = list(string)
      }))
      target_resource = optional(object({
        operator = string
        values   = list(string)
      }))
      target_resource_group = optional(object({
        operator = string
        values   = list(string)
      }))
      target_resource_type = optional(object({
        operator = string
        values   = list(string)
      }))
    }))
    schedule = optional(object({
      effective_from  = optional(string)
      effective_until = optional(string)
      time_zone       = optional(string)
      recurrence = optional(object({
        daily = optional(object({
          start_time = string
          end_time   = string
        }))
        weekly = optional(object({
          days_of_week = list(string)
          start_time   = optional(string)
          end_time     = optional(string)
        }))
        monthly = optional(object({
          days_of_month = list(string)
          start_time    = optional(string)
          end_time      = optional(string)
        }))
      }))
    }))
  }))
  default = []
}
