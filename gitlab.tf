provider "gitlab" {
  token    = var.gitlab_token
  base_url = var.base_url
}

resource "gitlab_group" "group_project" {
  name        = var.gitlab_group_name
  path        = var.gitlab_group_path
}

resource "gitlab_project" "my_repo" {
  depends_on             = [gitlab_group.group_project]
  name                   = var.gitlab_project_name
  namespace_id           = gitlab_group.group_project.id
  visibility_level       = "private"
  pipelines_enabled      = true
  initialize_with_readme = true
  shared_runners_enabled = var.shared_runners_enabled
}

data "gitlab_user" "owner" {
  email = ${var.repo_owner}
}

data "gitlab_user" "maintainer" {
  email = ${var.repo_maintainer}
}

data "gitlab_user" "developer" {
  email = ${var.repo_developer}
}

data "gitlab_user" "reporter" {
  email = ${var.repo_reporter}
}

data "gitlab_user" "guest" {
  email = ${var.repo_guest}
}

resource "gitlab_group_membership" "owner" {
  group_id     = data.gitlab_group.group_project.id
  user_id      = data.gitlab_user.user.id
  access_level = "owner"
}

resource "gitlab_group_membership" "maintainer" {
  group_id     = data.gitlab_group.group_project.id
  user_id      = data.gitlab_user.user.id
  access_level = "maintainer"
}

resource "gitlab_group_membership" "developer" {
  group_id     = data.gitlab_group.group_project.id
  user_id      = data.gitlab_user.user.id
  access_level = "developer"
}

resource "gitlab_group_membership" "reporter" {
  group_id     = data.gitlab_group.group_project.id
  user_id      = data.gitlab_user.user.id
  access_level = "reporter"
}

resource "gitlab_group_membership" "guest" {
  group_id     = data.gitlab_group.group_project.id
  user_id      = data.gitlab_user.user.id
  access_level = "guest"
}

resource "gitlab_group_variable" "secret" {
   group     = gitlab_group.group_project.name
   key       = "KUBECONFIG"
   value     = "group_variable_value"
   protected = false
}

data "local_file" "gitlab_ci" {
    filename = "./gitlab-ci.yml"
}

resource "null_resource" "commit_pipeline" {
  depends_on = [gitlab_project.my_repo]
  provisioner "local-exec" {
    command = "apk add curl && curl --request POST --header 'PRIVATE-TOKEN: ${var.gitlab_token}' --header \"Content-Type: application/json\" --data '{\"branch\": \"master\", \"author_email\": \"${var.author_email}\", \"author_name\": \"${var.author_name}\", \"encoding\":\"base64\" , \"content\": \"${base64encode(data.local_file.gitlab_ci.content)}\", \"commit_message\": \"Pushing CI/CD Pipeline\"}' '${var.base_url}api/v4/projects/${gitlab_project.my_repo.id}/repository/files/.gitlab-ci.yml'"
  }
}
