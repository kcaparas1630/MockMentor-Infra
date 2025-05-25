locals {
  region = var.artifact_repos[0].location
  project_id = var.artifact_repos[0].project_id
}

output "repository_urls" {
  description = "URLs for the created artifact repositories"
  value = {
    frontend = "${local.region}-docker.pkg.dev/${local.project_id}/mockmentor-frontend-dev"
    typescript_server = "${local.region}-docker.pkg.dev/${local.project_id}/mockmentor-express-server-dev"
    python_server = "${local.region}-docker.pkg.dev/${local.project_id}/mockmentor-python-server-dev"
  }
} 
