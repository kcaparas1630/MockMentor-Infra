# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment
  gcp_region = local.region_vars.locals.gcp_region
  gcp_project_id = local.account_vars.locals.gcp_project_id
  gcp_project_name = local.account_vars.locals.gcp_project_name
  gcp_billing_account_id = local.global_vars.locals.gcp_billing_account_id
  
  artifact_registry_region = local.global_vars.locals.artifact_registry_region
  artifact_registry_gcp_project = local.global_vars.locals.artifact_registry_gcp_project

  // base_source_url = "file_path" or 6 "git@github.com:factory-level/terraform_gcp_cloudrun.git" 
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  region = local.gcp_region
  billing_account_id = local.gcp_billing_account_id
  project_id = local.gcp_project_id
}
