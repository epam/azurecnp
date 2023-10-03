variable "rg_location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
  default     = null
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group in which the CosmosDB Account is created."
}
variable "cosmosdb_account_name" {
  type        = string
  description = "Specifies the name of the CosmosDB Account."
}
variable "offer_type" {
  type        = string
  description = "Specifies the Offer Type to use for this CosmosDB Account - currently this can only be set to Standard"
  default     = "Standard"
}
variable "kind" {
  type        = string
  description = "Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB and MongoDB. Defaults to GlobalDocumentDB"
  default     = "GlobalDocumentDB"
}
variable "enable_automatic_failover" {
  type        = bool
  description = "Enable automatic fail over for this Cosmos DB account."
  default     = false
}
variable "geo_location" {
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool)
  }))
  description = <<EOF
  The ``geo_location`` block Configures the geographic locations the data is replicated to and supports the following:
  - ``location``            (Required) The name of the Azure region to host replicated data.
  - ``failover_priority``   (Required) The failover priority of the region. A failover priority of ``0`` indicates a write region. 
                            The maximum value for a failover priority = (total number of regions - ``1``). 
                            Failover priority values must be unique for each of the regions in which the database account exists. 
                            Changing this causes the location to be re-provisioned and cannot be changed for the location with failover priority ``0``.
  - ``zone_redundant``      (Optional) Should zone redundancy be enabled for this region? Defaults to ``false``.
  EOF
}
variable "ip_range_filter" {
  type        = string
  description = <<EOF
  This value specifies the set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IP's for a given database account. 
  IP addresses/ranges must be comma separated and must not contain any spaces.
  EOF
  default     = ""
}
variable "consistency_level" {
  type        = string
  description = "The Consistency Level to use for this CosmosDB Account - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix."
  default     = "Session"
}
variable "is_virtual_network_filter_enabled" {
  type        = bool
  description = "Enables virtual network filtering for this Cosmos DB account."
  default     = true
}
variable "allowed_subnets" {
  type = list(object({
    vnet_name                            = string
    vnet_rg_name                         = string
    subnet_name                          = string
    ignore_missing_vnet_service_endpoint = bool
  }))
  description = <<EOF
  This parameter is a list of objects which set allowed subnets for cosmosdb account. Require parameters below:
  - ``vnet_name``                                  The name of the vnet where server takes place
  - ``vnet_rg_name``                               The name of vnet's rg
  - ``subnet_name``                                The name of the subnet where server takes place.
  - ``ignore_missing_vnet_service_endpoint``       If set to true, the specified subnet will be added as 
                                                   a virtual network rule even if its CosmosDB service endpoint is not active.
  EOF
  default     = []
}
variable "capabilities" {
  type        = list(string)
  description = <<EOF
  List of capabilities for Cosmos DB API. - Possible values are ``AllowSelfServeUpgradeToMongo36``, ``DisableRateLimitingResponses``, 
  ``EnableAggregationPipeline``, ``EnableCassandra``, ``EnableGremlin``, ``EnableMongo``, ``EnableMongo16MBDocumentSupport``, 
  ``EnableMongoRetryableWrites``, ``EnableMongoRoleBasedAccessControl``, ``EnableServerless``, ``EnableTable``, 
  ``EnableUniqueCompoundNestedDocs``, ``MongoDBv3.4`` and ``mongoEnableDocLevelTTL``.
  EOF
  default     = []
}
variable "diagnostic_setting" {
  description = <<EOF
    The description of parameters for Diagnistic Setting:
    `diagnostic_setting_name` - specifies the name of the Diagnostic Setting;
    `log_analytics_workspace_id` - ID of the Log Analytics Workspace;
    `storage_account_id` - the ID of the Storage Account where logs should be sent;
    `log` - describes logs for Diagnistic Setting:
      `category` -  the name of a Diagnostic Log Category for this Resource. list of 
        available logs: `DataPlaneRequests`, `MongoRequests`, `MongoRequests`, `MongoRequests`, `MongoRequests`, 
        `MongoRequests`, `MongoRequests`, `MongoRequests`, `MongoRequests`;
      `enabled` -  is this Diagnostic Log enabled?;
      `retention_policy` - describes logs retention policy (needed to store data in the Storage Account):
        `enabled` - is this Retention Policy enabled?
        `days` - the number of days for which this Retention Policy should apply.
    `metric` - describes metric for Diagnistic Setting:
      `category` -  the name of a Diagnostic Metric Category for this Resource. List of
        available Metrics: `Requests`;
      `enabled` -  is this Diagnostic Metric enabled?
      `retention_policy` - describes Metric retention policy (needed to store data in the Storage Account):
        `enabled` - is this Retention Policy enabled?
        `days` - the number of days for which this Retention Policy should apply.
  EOF
  type        = any
  default     = null
}
variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}