# Define the artifact registry repository resource
resource "google_artifact_registry_repository" "ai_interviewer_repository" {
    for_each = { for repo in var.artifact_repos : repo.repository_id => repo }
    location = each.value.location
    repository_id = each.value.repository_id
    description = each.value.description
    format = each.value.format
    project = each.value.project_id
}


# TODO: Add IAM bindings for the artifact registry repository
