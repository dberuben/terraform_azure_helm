provider "gitlab" {
  token    = var.gitlab_token
  base_url = var.base_url
}

resource "gitlab_group" "group_project" {
  name        = var.gitlab_group_name
  path        = var.gitlab_group_path
}

resource "gitlab_project" "my_repo" {
  name                   = var.gitlab_project_name
  namespace_id           = gitlab_group.group_project.id
  visibility_level       = "private"
  pipelines_enabled      = "true"
  shared_runners_enabled = var.shared_runners_enabled
}
