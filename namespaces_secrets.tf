resource "kubernetes_namespace" "namespace_name" {
  metadata {
    name = var.namespace_name 
  }
}

resource "kubernetes_secret" "secret_namespace" {
  metadata {
    name      = "docker-config"
    namespace = kubernetes_namespace.namespace_name.id
  }
  data = {
    ".dockerconfigjson" = "{\"auths\":{\"var.base_url\": {\"username\": \"var.gitlab_deploy_login\", \"password\": \"var.gitlab_deploy_token\",\"auth\": \"${base64encode("${var.gitlab_deploy_login}:${var.gitlab_deploy_token}")}\"}}}"
  }
  type = "kubernetes.io/dockerconfigjson"
}

