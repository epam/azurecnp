output "id" {
  value       = azurerm_kubernetes_cluster.k8s.id
  description = "The ID of the Kubernetes Managed Cluster."
}
output "name" {
  value       = azurerm_kubernetes_cluster.k8s.name
  description = "The name of the managed Kubernetes Cluster."
}
output "username" {
  value       = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  sensitive   = true
  description = "A username used to authenticate to the Kubernetes cluster."
}
output "password" {
  value       = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  description = "A password or token used to authenticate to the Kubernetes cluster."
}
output "host" {
  value       = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  sensitive   = true
  description = "The Kubernetes cluster server host."
}
output "client_certificate" {
  value       = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster."
}
output "client_key" {
  value       = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
  sensitive   = true
  description = "Base64 encoded private key used by clients to authenticate to the Kubernetes cluster."
}
output "cluster_ca_certificate" {
  value       = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
  description = "Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster."
}
output "kube_config_raw" {
  value       = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive   = true
  description = "Base64 encoded Kubernetes configuration."
}
output "kubelet_identity" {
  value       = try(azurerm_kubernetes_cluster.k8s.kubelet_identity, null)
  sensitive   = true
  description = "The Managed Identity to be assigned to the Kubelets."
}
output "identity" {
  value       = try(azurerm_kubernetes_cluster.k8s.identity, null)
  description = <<EOF
    An identity block exports the following:
    principal_id - The Principal ID associated with this Managed Service Identity.
    tenant_id - The Tenant ID associated with this Managed Service Identity.
  EOF
}
output "node_resource_group" {
  value       = try(azurerm_kubernetes_cluster.k8s.node_resource_group, null)
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
}
output "node_resource_group_id" {
  value       = try(azurerm_kubernetes_cluster.k8s.node_resource_group_id, null)
  description = "The ID of the Resource Group containing the resources for this Managed Kubernetes Cluster."
}
output "network_profile" {
  value       = try(azurerm_kubernetes_cluster.k8s.network_profile, null)
  description = "A network_profile block as defined below."
}
output "key_vault_secrets_provider" {
  description = "The `azurerm_kubernetes_cluster`'s `key_vault_secrets_provider` block."
  value       = try(azurerm_kubernetes_cluster.k8s.key_vault_secrets_provider[0], null)
}
output "ingress_application_gateway" {
  description = "The `azurerm_kubernetes_cluster`'s `ingress_application_gateway` block."
  value       = try(azurerm_kubernetes_cluster.k8s.ingress_application_gateway[0], null)
}
output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster."
  value       = try(azurerm_kubernetes_cluster.k8s.oidc_issuer_url, null)
}
output "cluster_portal_fqdn" {
  description = "The FQDN for the Azure Portal resources when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster."
  value       = try(azurerm_kubernetes_cluster.k8s.portal_fqdn, null)
}