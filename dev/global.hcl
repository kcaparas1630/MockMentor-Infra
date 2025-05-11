# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Define global variables that apply across all environments
  gcp_billing_account_id = "016B97-4C5CF3-CF8BBD"
  
  # Artifact Registry configuration
  artifact_registry_region = "us-east1"
  artifact_registry_gcp_project = "terraform-practice-455719"
  
  # Reference modules configuration from modules.hcl instead of hardcoding
  modules_vars = read_terragrunt_config(find_in_parent_folders("modules.hcl"))
  
}
