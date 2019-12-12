resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "azure-config-file" {
  metadata {
    name      = "azure-config-file"
    namespace = kubernetes_namespace.external-dns.id
  }
  data = {
    "azure.json" = <<EOF
      {
        "tenantId"        : "${var.tenant_id}",
        "subscriptionId"  : "${var.subscription_id}",
        "resourceGroup"   : "${var.resource_group_name_dns}",
        "aadClientId"     : "${var.azure_client_id}",
        "aadClientSecret" : "${var.azure_client_secret}"
      }
    EOF
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "external-dns" {
  depends_on = [kubernetes_secret.azure-config-file, kubernetes_namespace.external-dns]
  name       = "external-dns"
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "stable/external-dns"
  namespace  = kubernetes_namespace.external-dns.id
  wait       = "true"
  set {
    name  = "provider"
    value = "azure"
  }

  set {
    name  = "azure.secretName"
    value = "azure-config-file"
  }
  set {
    name  = "azure.resourceGroup"
    value = "dns"
  }
  set {
    name  = "registry"
    value = "txt"
  }
  set {
    name  = "logLevel"
    value = "debug"
  }
}
