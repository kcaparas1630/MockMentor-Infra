locals {
  region = var.artifact_repos[0].location
  project_id = var.artifact_repos[0].project_id
}

output "repository_urls" {
  description = "URLs for the created artifact repositories"
  value = {
    frontend = "${local.region}-docker.pkg.dev/${local.project_id}/ai-interview-frontend"
    typescript_server = "${local.region}-docker.pkg.dev/${local.project_id}/ai-interview-typescript-server"
    python_server = "${local.region}-docker.pkg.dev/${local.project_id}/ai-interview-python-server"
  }
} 
