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

resource "null_resource" "cert-manager-crds" {
  depends_on = [kubernetes_namespace.cert-manager]

   provisioner "local-exec" {
   command = "apk add --update --no-cache bash python3 libffi openssl curl ln -s /usr/bin/python3 /usr/bin/python && curl -L https://aka.ms/InstallAzureCli | bash &&  && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl"

}
  provisioner "local-exec" {
    command = "export KUBECONFIG=admin-${terraform.workspace} && kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml && sleep 60"
  }

}

resource "helm_release" "cert-manager" {
  depends_on = [null_resource.cert-manager-crds, kubernetes_namespace.cert-manager]
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
  depends_on = [helm_release.cert-manager, kubernetes_namespace.cert-manager, null_resource.cert-manager-crds]
  name       = "cluster-issuer"
  namespace  = "cert-manager"
  chart      = "cluster-issuer"
  timeout    = "300"
  wait       = "true"
}
