provider "gitlab" {
    token = var.gitlab_token
    base_url = var.base_url
}

resource "gitlab_group" "example" {
  name        = "damoul"
  path        = "example"
  description = "An example group"
}

// Create a project in the example group
resource "gitlab_project" "example" {
  name         = "myrepo"
  description  = "An example project"
  namespace_id = gitlab_group.example.id
  visibility_level = "private"
}
