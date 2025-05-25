include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

include "services" {
  path = find_in_parent_folders("services.hcl")
  expose = true
}

include "modules" {
  path = find_in_parent_folders("modules.hcl")
  expose = true
}

include "project_id" {
  path = find_in_parent_folders("project.hcl")
  expose = true
}

terraform {
  source = "${include.modules.locals.modules.service-accounts.source_url}?ref=${include.modules.locals.modules.service-accounts.version}"
}

inputs = {
  project_id = include.project_id.locals.gcp_project_id
  
  # Format to match the expected variable structure
  service_accounts = {
    "default" = {
      name = include.services.locals.default_service_account.name
      description = "AI Interviewer Default Service Account"
      roles = include.services.locals.default_service_account.roles
    },
    "api_gateway" = {
      name = include.services.locals.api_gateway_service_account.name
      description = "AI Interviewer API Gateway Service Account"
      roles = include.services.locals.api_gateway_service_account.roles
    }
  }
} 
