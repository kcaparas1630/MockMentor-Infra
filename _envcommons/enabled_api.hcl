locals {
    #TODO:

    #Load Environment variables
    account_vars        = read_terragrunt_config(find_in_parent_folders("project.hcl"))

    # Extract common variables for reuse
    gcp_project_id = local.account_vars.locals.gcp_project_id

    # get repo root
    repo_root = get_repo_root()

    base_source_url = "${local.repo_root}/_modules"
}

# -------------------------------------------------------------------
#   MODULE PARAMETERS
#   These are the variables needed to pass in to use the module.
# -------------------------------------------------------------------
inputs = {
    project_id = local.gcp_project_id
}
