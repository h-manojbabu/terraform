output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks-name.id
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks-name.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks-name.kube_config_raw
  sensitive = true
}
