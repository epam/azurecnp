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

variable "location" {
  description = <<EOT
  Specifies the supported Azure location where the resource exists.
  If the parameter is not specified in the configuration file, the location of the resource group is used.
  EOT
  type        = string
  default     = null
}

variable "workspace_id" {
  description = "Specifies the id of a log analytics workspace resource."
  type        = string
  default     = null
}

variable "application_type" {
  description = <<EOF
  Specifies the type of Application Insights to create. Possible values `ios`, `java`, `MobileCenter`,
  `Node.JS`, `phone`, `store`, `web`, `other`
  EOF
  type        = string
}

variable "retention_in_days" {
  description = <<EOF
  Specifies the retention period in days. Possible values are `30`, `60`, `90`, `120`, `180`, `270`, 
  `365`, `550` or `730`.
  EOF
  type        = number
  default     = 90
}

variable "sampling_percentage" {
  description = <<EOF
  Specifies the percentage of the data produced by the monitored application that is sampled for
  Application Insights telemetry.
  EOF
  type        = number
  default     = null
}

variable "disable_ip_masking" {
  description = <<EOF
  By default the real client ip is masked as `0.0.0.0` in the logs. Use this argument to disable masking
  and log the real client ip.
  EOF
  type        = bool
  default     = false
}

variable "internet_ingestion_enabled" {
  description = "Should the Application Insights component support ingestion over the Public Internet?"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Should the Application Insights component support querying over the Public Internet?"
  type        = bool
  default     = true
}
variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
