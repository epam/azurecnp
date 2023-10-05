# terraform.azurerm.private-endpoint

This module creates Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link.

## Prerequisites

| Resource name     | Required  | Description                                                                                               |
|-------------------|-----------|-----------------------------------------------------------------------------------------------------------|
| Resource Group    | yes       |                                                                                                           |
| Azure Service     | yes       | The service could be an Azure service such as Azure Storage, SQL, etc. or your own Private Link Service.  |
| Subnet inside VNET| yes       |                                                                                                           |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.57.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |



## Usage example

```go
module "private_endpoint" {
  source = "git::https://ORGANIZATION_NAME@dev.azure.com/ORGANIZATION_NAME/PROJECT_NAME/_git/terraform.private_endpoint?ref=v3.1.0"

  name                = "example"
  resource_group_name = "example_rg"
  location            = "westeurope"
  subnet_id           = "/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/MyResourceGroup/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-subnet"
  private_service_connection = {
    is_manual_connection              = false
    private_connection_resource_id    = "/subscriptions/12345678-12234-5678-9012-123456789012/resourceGroups/example-kv-rg/providers/Microsoft.KeyVault/vaults/example-kv"
    private_connection_resource_alias = "example-kv"
    subresource_names                 = ["vault"]
    request_message                   = null
  }
  private_dns_zone_group = {
    name                 = "private-dns-zone-name"
    private_dns_zone_ids = ["/subscriptions/62a0e662-0000-0000-8a29-b7515f85f54e/resourceGroups/prcl-rg-weeu-s-svc01/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"]
  }
  ip_configuration = {
    private_ip_address = "10.1.1.1"
    subresource_name   = "example-subresource-name"
    member_name        = "example-member-name"
  }
  tags = {
    environment = "example"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ip_configuration"></a> [ip\_configuration](#input\_ip\_configuration) | An ip\_configuration block supports the following:<br>    `name` - (Required) Specifies the Name of the IP Configuration. Changing this forces a new resource to be created.<br>    `private_ip_address` - (Required) Specifies the static IP address within the private endpoint's subnet to be used.<br>    Changing this forces a new resource to be created.<br>    `subresource_name` - Specifies the subresource this IP address applies to. subresource\_names corresponds<br>    to group\_id. Changing this forces a new resource to be created.<br>    `member_name` - Specifies the member name this IP address applies to. If it is not specified, it will use<br>    the value of subresource\_name. Changing this forces a new resource to be created. | <pre>object({<br>    private_ip_address = string<br>    subresource_name   = optional(string, null)<br>    member_name        = optional(string, null)<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Specifies the Name of the Private Endpoint. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_private_dns_zone_group"></a> [private\_dns\_zone\_group](#input\_private\_dns\_zone\_group) | A private\_dns\_zone\_group block supports the following::<br>    `name` - Specifies the Name of the Private DNS Zone Group.<br>    `private_dns_zone_ids` - Specifies the list of Private DNS Zones to include within the private\_dns\_zone\_group. | <pre>object({<br>    name                 = string<br>    private_dns_zone_ids = list(string)<br>  })</pre> | `null` | no |
| <a name="input_private_service_connection"></a> [private\_service\_connection](#input\_private\_service\_connection) | A private\_service\_connection block supports the following:<br>    `is_manual_connection` - Does the Private Endpoint require Manual Approval from the remote resource owner?<br>    Changing this forces a new resource to be created.<br>    NOTE:<br>    If you are trying to connect the Private Endpoint to a remote resource without having the correct RBAC<br>    permissions on the remote resource set this value to true.<br>    `private_connection_resource_id` - (Optional) The ID of the Private Link Enabled Remote Resource which this<br>    Private Endpoint should be connected to. Changing this forces a new resource to be created. For a web app or<br>    function app slot, the parent web app should be used in this field instead of a reference to the slot itself.<br>    `private_connection_resource_alias` - (Optional) The Service Alias of the Private Link Enabled Remote Resource which<br>    this Private Endpoint should be connected to. Changing this forces a new resource to be created.<br>    `subresource_names` - (Optional) A list of subresource names which the Private Endpoint is able to connect to.<br>    subresource\_names corresponds to group\_id. Possible values are detailed in the product documentation in the Subresources<br>    column. Changing this forces a new resource to be created.<br>    `request_message` - (Optional) A message passed to the owner of the remote resource when the private endpoint attempts<br>    to establish the connection to the remote resource. The request message can be a maximum of 140 characters in length. <br>    Only valid if is\_manual\_connection is set to true. | <pre>object({<br>    is_manual_connection              = optional(bool, false)<br>    private_connection_resource_id    = optional(string, null)<br>    private_connection_resource_alias = optional(string, null)<br>    subresource_names                 = optional(list(string), null)<br>    request_message                   = optional(string, null)<br>  })</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Specifies the Name of the Resource Group within which the Private Endpoint should exist.<br>    Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The fully qualified domain name to the private\_endpoint. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Private Endpoint. |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | A list of all IP Addresses that map to the private\_endpoint fqdn. |
| <a name="output_ip_configuration"></a> [ip\_configuration](#output\_ip\_configuration) | An ip\_configuration block. |
| <a name="output_private_dns_zone_group"></a> [private\_dns\_zone\_group](#output\_private\_dns\_zone\_group) | An private\_dns\_zone\_group block. |