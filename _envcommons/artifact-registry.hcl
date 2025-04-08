# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))


  # Extract out common variables for reuse
  gcp_region = local.region_vars.locals.gcp_region
  gcp_project_id = local.account_vars.locals.gcp_project_id

  repo_root = get_repo_root()
  base_source_url = "${local.repo_root}/_modules"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  project_id = local.gcp_project_id
  location = local.gcp_region
}
