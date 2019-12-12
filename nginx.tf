data "helm_repository" "nginx_repo" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "nginx_ingress" {
  depends_on = [kubernetes_namespace.nginx_ingress]
  name       = "nginx-ingress"
  repository = data.helm_repository.nginx_repo.metadata.0.name
  chart      = "nginx-ingress"
  version    = "1.26.1"
  wait       = true
  timeout    = "600"
  namespace  = kubernetes_namespace.nginx_ingress.metadata.0.name

  values = [<<-EOF
    controller:
        # global nginx settings for all ingress rules
        config:
            ssl-redirect: "false"
            http2: "true"
            # hsts config
            hsts: "true"
            hsts-include-subdomains: "true"
            hsts-max-age: "0"
            hsts-preload: "true"

            enable-owasp-modsecurity-crs: "true"
            server-tokens: "false"
            variables-hash-bucket-size: "256"

            proxy-body-size: "5m" # default is 1m

        service:
          externalTrafficPolicy: "Local" 
        publishService:
          enabled: true
          pathOverride: "${kubernetes_namespace.nginx_ingress.metadata.0.name}/nginx-ingress-controller"
  EOF
  ]

  set {
    name  = "updateStrategy.type"
    value = "RollingUpdate"
  }
}

