include "root" {
    path = find_in_parent_folders()
}

include "envcommon" {
    path    = "${dirname(find_in_parent_folders())}/_envcommons/artifact-registry.hcl"
    expose  = true
}

terraform {
    source = "${include.envcommon.locals.base_source_url}?ref=${include.envcommon.locals.base_source_version}"
}

inputs = {
    artifact_repos = [
        {
            repository_id   = "mockmentor-frontend-dev"
            location        = include.envcommon.locals.gcp_region
            description     = "Repository for frontend"
            format          = "DOCKER"
            project_id      = include.envcommon.locals.gcp_project_id
        },
        {
            repository_id   = "mockmentor-express-server-dev"
            location        = include.envcommon.locals.gcp_region
            description     = "Express Server Repository"
            format          = "DOCKER"
            project_id      = include.envcommon.locals.gcp_project_id
        },
        {
            repository_id   = "mockmentor-python-server-dev"
            location        = include.envcommon.locals.gcp_region
            description     = "Python Server Repository"
            format          = "DOCKER"
            project_id      = include.envcommon.locals.gcp_project_id
        }
    ]
}
