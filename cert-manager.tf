data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }
    name = "cert-manager"
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}


resource "helm_release" "cert-manager-crds" {
  depends_on = [kubernetes_namespace.cert-manager]
  name       = "cert-manager-crd"
  namespace  = kubernetes_namespace.cert-manager.metadata.0.name
  chart      = "cert-manager-crd"
  version    = "0.10.0"
}


resource "helm_release" "cert-manager" {
  depends_on = [helm_release.cert-manager-crds, kubernetes_namespace.cert-manager]
  name       = "cert-manager"
  repository = data.helm_repository.jetstack.metadata.0.name
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert-manager.metadata.0.name
  version    = "v0.10.0"
  timeout    = "300"
  wait       = "true"

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-prod"
  }

  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }
}

resource "helm_release" "cluster_issuer" {
  depends_on = [helm_release.cert-manager, kubernetes_namespace.cert-manager, helm_release.cert-manager-crds]
  name       = "cluster-issuer"
  namespace  = kubernetes_namespace.cert-manager.metadata.0.name
  chart      = "cluster-issuer"
  timeout    = "300"
  wait       = "true"
}
