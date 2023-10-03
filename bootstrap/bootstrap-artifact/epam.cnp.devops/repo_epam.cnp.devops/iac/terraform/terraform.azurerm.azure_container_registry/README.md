# terraform.azurerm.azurecontainerregistry

This module creates an Azure Container Registry

## Prerequisites

| Resource name     | Required  | Description   |
|-------------------|-----------|---------------|
| Resource Group    | yes       |               |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.56.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.56.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |



## Usage example

```go
module "acr" {
  source = "git::https://ORGANIZATION_NAME@dev.azure.com/ORGANIZATION_NAME/PROJECT_NAME/_git/terraform.azurerm.azure_container_registry?ref=v1.7.0"

  name                          = "uniquexamplename"
  rg_name                       = "example_rg_name"
  sku                           = "Standard"
  location                      = "westeurope"
  admin_enabled                 = false
  public_network_access_enabled = true
  zone_redundancy_enabled       = false
  export_policy_enabled         = true
  data_endpoint_enabled         = false
  network_rule_bypass_option    = "None"
  retention_policy_days         = 7
  georeplications = [
    {
      location                  = "northeurope"
      zone_redundancy_enabled   = false
      regional_endpoint_enabled = false
    }
  ]
  identity = {
    type         = "UserAssigned"
    identity_ids = ["User-Assigned-Managed-Identity-IDs1", "User-Assigned-Managed-Identity-IDs2"]
  }
  encryption {
    enabled            = true
    key_vault_key_id   = "/subscriptions/003def49-1111-0000-2222-3a2dcfcf8411/resourceGroups/test/providers/Microsoft.KeyVault/vaults/epam-kv-cm21-ne-mysql01"
    identity_client_id = "User-Assigned-Managed-Identity-IDs1"
  }
  tags = {
    environment  = ""
    businessUnit = ""
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_enabled"></a> [admin\_enabled](#input\_admin\_enabled) | Specifies whether the admin user is enabled. Defaults to false. | `bool` | `false` | no |
| <a name="input_data_endpoint_enabled"></a> [data\_endpoint\_enabled](#input\_data\_endpoint\_enabled) | Whether to enable dedicated data endpoints for this Container Registry? This is only supported on resources with the Premium SKU. | `bool` | `false` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | `enabled` - Boolean value that indicates whether encryption is enabled.<br>    `key_vault_key_id` - The ID of the Key Vault Key.<br>    `identity_client_id` - The client ID of the managed identity associated with the encryption key.<br>    NOTE<br>    The managed identity used in encryption also needs to be part of the `identity` block under `identity_ids`! | <pre>object({<br>    enabled            = optional(bool)<br>    key_vault_key_id   = string<br>    identity_client_id = string<br>  })</pre> | `null` | no |
| <a name="input_export_policy_enabled"></a> [export\_policy\_enabled](#input\_export\_policy\_enabled) | Boolean value that indicates whether export policy is enabled. Defaults to `true`. In order to set it to `false`, make<br>    sure the `public_network_access_enabled` is also set to `false`. | `bool` | `true` | no |
| <a name="input_georeplications"></a> [georeplications](#input\_georeplications) | The list of georeplication parameters.<br>    The georeplications is only supported on new resources with the Premium SKU.<br>    The georeplications list cannot contain the location where the Container Registry exists.<br>    If more than one georeplications block is specified, they are expected to follow the<br>    alphabetic order on the location property.<br>    `location` - A location where the container registry should be geo-replicated.<br>    `regional_endpoint_enabled` - Whether regional endpoint is enabled for this Container Registry?<br>    `zone_redundancy_enabled` - Whether zone redundancy is enabled for this replication location? | <pre>list(object({<br>    location                  = string<br>    zone_redundancy_enabled   = optional(bool)<br>    regional_endpoint_enabled = optional(bool)<br>  }))</pre> | `[]` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | An identity block supports the following:<br>    `type` - Specifies the type of Managed Service Identity that should be configured on this Container Registry. Possible<br>    values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both).<br>    `identity_ids` - Specifies a list of User Assigned Managed Identity IDs to be assigned to this Container Registry.<br>    NOTE:<br>    This is required when type is set to `UserAssigned` or `SystemAssigned, UserAssigned`. | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists. <br>    Changing this forces a new resource to be created. If the location is not <br>    specified, then the location will match the location of the resource group | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of the Container Registry. Only Alphanumeric characters allowed.<br>    Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_network_rule_bypass_option"></a> [network\_rule\_bypass\_option](#input\_network\_rule\_bypass\_option) | Whether to allow trusted Azure services to access a network restricted Container Registry? Possible values are `None` and `AzureServices`.<br>    Defaults to `AzureServices`. | `string` | `"AzureServices"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is allowed for the container registry. Defaults to true. | `bool` | `true` | no |
| <a name="input_retention_policy_days"></a> [retention\_policy\_days](#input\_retention\_policy\_days) | Enable a retention policy.<br>    The number of days to retain an untagged manifest after which it gets purged. Recommended default value is 7. | `number` | `null` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group in which to create the Container Registry.<br>    Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU name of the container registry. Possible values are 'Basic', 'Standard' and 'Premium'. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled) | Whether zone redundancy is enabled for this Container Registry? Changing this forces a new resource to be created.<br>    Defaults to `false`. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | The Password associated with the Container Registry Admin account - if the admin account is enabled. |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | The Username associated with the Container Registry Admin account - if the admin account is enabled. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Container Registry. |
| <a name="output_identity"></a> [identity](#output\_identity) | An identity block exports the following:<br>    principal\_id - The Principal ID associated with this Managed Service Identity.<br>    tenant\_id - The Tenant ID associated with this Managed Service Identity. |
| <a name="output_login_server"></a> [login\_server](#output\_login\_server) | The URL that can be used to log into the container registry. |