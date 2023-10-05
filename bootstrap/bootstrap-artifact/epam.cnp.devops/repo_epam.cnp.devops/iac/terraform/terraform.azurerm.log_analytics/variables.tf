variable "name" {
  description = <<EOT
  Specifies the name of the Log Analytics Workspace. Workspace name should include
  4-63 letters, digits or '-'.
  EOT 
  type        = string
}

variable "location" {
  description = <<EOT
  Specifies the supported Azure location where the resource exists.
  If the parameter is not specified in the configuration file, the location of the resource group is used.
  EOT
  type        = string
  default     = null
}

variable "rg_name" {
  description = "The name of the resource group in which the Log Analytics workspace is created."
  type        = string
}

variable "pricing_tier" {
  description = <<EOT
  Specifies the Sku of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard,
  Standalone, Unlimited, CapacityReservation, and PerGB2018 (new Sku as of 2018-04-03). Defaults to PerGB2018.
  EOT 
  type        = string
}

variable "retention_in_days" {
  description = <<EOT
  The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 
  30 and 730
  EOT 
  type        = number
  default     = null
}

variable "activity_log_subs" {
  description = <<EOT
  List of subscriptions ID for which you need to spice up the Activity log to this workspace, the user 
  running terraform needs at least Monitoring Contributor permissions on the target subscription
  EOT 
  type        = list(string)
  default     = []
}

variable "deployment_mode" {
  description = "The resource group template deployment mode"
  type        = string
  default     = "Incremental"
}

variable "la_solutions" {
  description = <<EOT
  The description of parameters for resource Log Analytics Solution.
  `la_sln_name`- Specifies the name of the solution to be deployed
  `la_sln_publisher` - The publisher of the solution. For example Microsoft. 
   Changing this forces a new resource to be created.
  `la_sln_product` - The product name of the solution. For example "OMSGallery/Containers".
   Changing this forces a new resource to be created.
   EOT
  type        = list(map(string))
  default     = []
}

variable "diagnostic_setting" {
  description = <<EOT
  The description of parameters for Diagnistic Setting:
  `diagnostic_setting_name` - specifies the name of the Diagnostic Setting;
  `log` - describes logs for Diagnistic Setting:
    `category_group` -  the name of a Diagnostic Log Category Group for this Resource;
    `enabled` -  is this Diagnostic Log enabled?;
    `retention_policy` - describes logs retention policy:
      `enabled` - is this Retention Policy enabled?
      `days` - the number of days for which this Retention Policy should apply.
  `metric` - describes metric for Diagnistic Setting:
    `category` -  the name of a Diagnostic Metric Category for this Resource;
    `enabled` -  is this Diagnostic Metric enabled?
    `retention_policy` - describes Metric retention policy:
      `enabled` - is this Retention Policy enabled?
      `days` - the number of days for which this Retention Policy should apply.
  EOT
  type        = any
  default     = null
}

variable "storage_account_id" {
  description = "The ID of the Storage Account where logs should be sent"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}