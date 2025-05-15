# include the root configuration (terragrunt.hcl) which has the common configuration across the environment.

include "root" {
    path = find_in_parent_folders("terragrunt.hcl")
}

include "modules" {
    path = find_in_parent_folders("modules.hcl")
    expose = true
}

# Configure the version of the module to use in this environment
terraform {
    source = "${include.modules.locals.base_source_url}?ref=${include.modules.locals.base_source_version}"
}

inputs = {
  gcp_api_url = "run.googleapis.com"
}
