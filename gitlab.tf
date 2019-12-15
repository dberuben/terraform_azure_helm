provider "gitlab" {
  token    = var.gitlab_token
  base_url = var.base_url
}

resource "gitlab_group" "example" {
  name        = "damoul"
  path        = "example"
  description = "An example group"
}

resource "gitlab_project" "example" {
  name                   = "myrepo"
  description            = "An example project"
  namespace_id           = gitlab_group.example.id
  visibility_level       = "private"
  pipelines_enabled      = "true"
  shared_runners_enabled = var.shared_runners_enabled
}
