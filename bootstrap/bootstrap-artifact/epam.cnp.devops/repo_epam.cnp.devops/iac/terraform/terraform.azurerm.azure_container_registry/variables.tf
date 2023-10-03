variable "name" {
  description = <<EOF
    Specifies the name of the Container Registry. Only Alphanumeric characters allowed.
    Changing this forces a new resource to be created.
    EOF
  type        = string
}

variable "rg_name" {
  description = <<EOF
    The name of the resource group in which to create the Container Registry.
    Changing this forces a new resource to be created.
    EOF
  type        = string
}

variable "location" {
  description = <<EOF
    Specifies the supported Azure location where the resource exists. 
    Changing this forces a new resource to be created. If the location is not 
    specified, then the location will match the location of the resource group
    EOF
  type        = string
  default     = null
}

variable "sku" {
  description = "The SKU name of the container registry. Possible values are 'Basic', 'Standard' and 'Premium'."
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the container registry. Defaults to true."
  type        = bool
  default     = true
}

variable "zone_redundancy_enabled" {
  description = <<EOF
    Whether zone redundancy is enabled for this Container Registry? Changing this forces a new resource to be created.
    Defaults to `false`.
    EOF
  type        = bool
  default     = false
}

variable "export_policy_enabled" {
  description = <<EOF
    Boolean value that indicates whether export policy is enabled. Defaults to `true`. In order to set it to `false`, make
    sure the `public_network_access_enabled` is also set to `false`.
    EOF
  type        = bool
  default     = true
}

variable "data_endpoint_enabled" {
  description = "Whether to enable dedicated data endpoints for this Container Registry? This is only supported on resources with the Premium SKU."
  type        = bool
  default     = false
}

variable "network_rule_bypass_option" {
  description = <<EOF
    Whether to allow trusted Azure services to access a network restricted Container Registry? Possible values are `None` and `AzureServices`.
    Defaults to `AzureServices`.
    EOF
  type        = string
  default     = "AzureServices"
}

variable "retention_policy_days" {
  description = <<EOF
    Enable a retention policy.
    The number of days to retain an untagged manifest after which it gets purged. Recommended default value is 7.
    EOF
  type        = number
  default     = null
}

variable "georeplications" {
  description = <<EOF
    The list of georeplication parameters.
    The georeplications is only supported on new resources with the Premium SKU.
    The georeplications list cannot contain the location where the Container Registry exists.
    If more than one georeplications block is specified, they are expected to follow the
    alphabetic order on the location property.
    `location` - A location where the container registry should be geo-replicated.
    `regional_endpoint_enabled` - Whether regional endpoint is enabled for this Container Registry?
    `zone_redundancy_enabled` - Whether zone redundancy is enabled for this replication location?
    EOF
  type = list(object({
    location                  = string
    zone_redundancy_enabled   = optional(bool)
    regional_endpoint_enabled = optional(bool)
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  description = <<EOF
    An identity block supports the following:
    `type` - Specifies the type of Managed Service Identity that should be configured on this Container Registry. Possible
    values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both).
    `identity_ids` - Specifies a list of User Assigned Managed Identity IDs to be assigned to this Container Registry.
    NOTE:
    This is required when type is set to `UserAssigned` or `SystemAssigned, UserAssigned`.
    EOF
  default     = null
}

variable "encryption" {
  type = object({
    enabled            = optional(bool)
    key_vault_key_id   = string
    identity_client_id = string
  })
  description = <<EOF
    `enabled` - Boolean value that indicates whether encryption is enabled.
    `key_vault_key_id` - The ID of the Key Vault Key.
    `identity_client_id` - The client ID of the managed identity associated with the encryption key.
    NOTE
    The managed identity used in encryption also needs to be part of the `identity` block under `identity_ids`!
    EOF
  default     = null
}