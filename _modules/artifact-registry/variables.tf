variable "artifact_repos" {
    description = "List of Artifact Repositories"
    type = list(object({
        repository_id = string
        description = string 
        format = string # DOCKER, NPM, PYPI, MAVEN
        project_id = string
        location = string # us-east1
    }))
}

variable "project_id" {
    description = "The GCP Project ID"
    type = string
}

variable "region" {
    description = "The GCP Region"
    type = string
}
