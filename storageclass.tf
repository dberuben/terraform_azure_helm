resource "kubernetes_storage_class" "premiumssd" {
  metadata {
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
    labels = {
      "kubernetes.io/cluster-service" = "true"

    }
    name = "super-ssd"
  }
  storage_provisioner    = "kubernetes.io/azure-disk"
  reclaim_policy         = "Delete"
  allow_volume_expansion = "true"
  parameters = {
    cachingmode        = "ReadOnly"
    kind               = "Managed"
    storageaccounttype = "Premium_LRS"
  }
}
