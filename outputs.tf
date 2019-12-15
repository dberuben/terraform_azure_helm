output "client_key" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_key}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate}"
}

output "cluster_username" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
}

output "cluster_password" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
}

output "azurerm_resource_group" {
  value = "${azurerm_resource_group.k8s.name}"
}
output "http_url_to_repo" {
  value = "${gitlab_project.example.http_url_to_repo}"
}
output "web_url" {
  value = "${gitlab_project.example.web_url}"
}
