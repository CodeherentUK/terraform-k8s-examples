output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "cluster_fqdn" {
  value = azurerm_kubernetes_cluster.k8s.fqdn
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "public_ip_address" {
  value = azurerm_public_ip.k8s-cluster-pubip.ip_address
}