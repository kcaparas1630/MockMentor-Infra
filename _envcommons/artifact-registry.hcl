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
  modules_vars = read_terragrunt_config(find_in_parent_folders("modules.hcl"))

  # Extract out common variables for reuse
  gcp_region = local.region_vars.locals.gcp_region
  gcp_project_id = local.account_vars.locals.gcp_project_id

  modules_map = {
    for name, modules in local.modules_vars.locals.modules : name => modules
  }
  base_source_url     = "${local.modules_map["artifact-registry"].source_url}"
  base_source_version = "${local.modules_map["artifact-registry"].version}"

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
