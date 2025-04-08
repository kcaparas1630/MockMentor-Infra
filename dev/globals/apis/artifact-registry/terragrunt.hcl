# include the root configuration (terragrunt.hcl) which has the common configuration across the environment.

include "root" {
    path = find_in_parent_folders()
}
include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommons/enabled_api.hcl"
    expose = true
}

# Configure the version of the module to use in this environment
terraform {
    source = "${include.envcommon.locals.base_source_url}?ref=v1.0.0"
}
inputs = {
  gcp_api_url = "artifactregistry.googleapis.com"
}
