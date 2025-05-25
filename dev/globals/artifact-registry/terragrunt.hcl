# include the root configuration (terragrunt.hcl) which has the common configuration across the environment.

include "root" {
    path = find_in_parent_folders("terragrunt.hcl")
}

# Include the envcommon configuration for the component.
include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommons/artifact-registry.hcl"
  expose = true
}

# Configure the version of the module to use in this environment
terraform {
    source = "${include.envcommon.locals.base_source_url}?ref=${include.envcommon.locals.base_source_version}"
}

# Only enable the Artifact Registry API
inputs = {
  enable_apis = ["artifactregistry.googleapis.com"]
}
