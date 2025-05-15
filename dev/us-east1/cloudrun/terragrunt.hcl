include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommons/cloudrun.hcl"
  expose = true
}

include "modules" {
  path = find_in_parent_folders("modules.hcl")
  expose = true
}

dependency "artifact_registry_repository" {
  config_path = "../artifact-repo"
}

dependencies {
  paths = ["../service-accounts"]
}

locals {
  # Read project ID from parent configuration
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  gcp_project_id = local.project_vars.locals.gcp_project_id
  
  # Hardcode service account emails
  platform_service_account_email = "ai-interviewer-default-sa@${local.gcp_project_id}.iam.gserviceaccount.com"
  api_gateway_service_account_email = "ai-interviewer-api-gateway-sa@${local.gcp_project_id}.iam.gserviceaccount.com"
  
  artifact_registry_region = include.envcommon.locals.gcp_region
  
  # Load secrets with SOPS (if used)
  secrets_dir = "${get_terragrunt_dir()}/secrets"
  frontend_secrets = fileexists("${local.secrets_dir}/frontend.enc.yaml") ? yamldecode(sops_decrypt_file("${local.secrets_dir}/frontend.enc.yaml")) : {}
  typescript_secrets = fileexists("${local.secrets_dir}/typescript.enc.yaml") ? yamldecode(sops_decrypt_file("${local.secrets_dir}/typescript.enc.yaml")) : {}
  # python_secrets = fileexists("${local.secrets_dir}/python.enc.yaml") ? yamldecode(sops_decrypt_file("${local.secrets_dir}/python.enc.yaml")) : {}
  
  # Get the image tag from an environment variable, defaulting to "latest"
  image_tag = get_env("DEPLOY_IMAGE_TAG", "latest")
  image_repo = "ai-interview-frontend"
  image_name = "ai-interview-frontend"
}

terraform {
  source = "${include.modules.locals.modules.cloud-run.source_url}?ref=${include.modules.locals.modules.cloud-run.version}"
}

inputs = {
  # Project and region
  project_id = local.gcp_project_id
  region = include.envcommon.locals.gcp_region
  
  # These variables are required by the module but we're using cloud_run_services instead
  service_name = ""
  containers = []
  
  # List of Cloud Run services to create
  cloud_run_services = [
    # Frontend Service
    {
      service_name       = "ai-interview-frontend"
      container_port     = 80
      service_account    = local.platform_service_account_email
      
      containers = [
        {
          name  = "frontend-container"
          image = "${dependency.artifact_registry_repository.outputs.repository_urls.frontend}/ai-interview-frontend"
          tag   = local.image_tag
          env_vars = [
            {
              name  = "GOOGLE_CLOUD_PROJECT"
              value = local.gcp_project_id
            },
            {
              name  = "NODE_ENV"
              value = "production"
            },
            {
              name  = "API_URL"
              value = "https://ai-interview-typescript-server-xxxxx-uc.a.run.app"
            }
          ]
          resources = {
            limits = {
              memory = "512Mi"
              cpu    = "1"
            }
          }
        }
      ]
      
      min_instance_count = 0
      max_instance_count = 2
      
      labels = {
        "app"   = "ai-interview"
        "layer" = "frontend"
      }
      
      iam_bindings = [
        {
          role    = "roles/run.invoker"
          members = ["allUsers"]  # Public access for frontend
        }
      ]
      # Force HTTPS for security
      https_only = true

      # allow unauthenticated users to access the service
      allow_unauthenticated = true
    },
    
    # TypeScript Backend Service
    {
      service_name       = "ai-interview-typescript-server"
      container_port     = 3000
      service_account    = local.platform_service_account_email
      
      containers = [
        {
          name  = "typescript-container"
          image = "${dependency.artifact_registry_repository.outputs.repository_urls.typescript_server}/ai-interview-typescript-server"
          tag   = local.image_tag
          env_vars = [
            {
              name  = "GOOGLE_CLOUD_PROJECT"
              value = local.gcp_project_id
            },
            {
              name  = "NODE_ENV"
              value = "production"
            },
            {
              name  = "SERVICE_NAME"
              value = "typescript-backend"
            },
            #{
            # name  = "AI_SERVICE_URL"
            # value = "https://ai-interview-python-server-xxxxx-uc.a.run.app"
            #},
            # Add database credentials from secrets
            {
              name  = "DATABASE_URL"
              value = try(local.typescript_secrets.env_vars.DATABASE_URL, "")
            }
          ]
          resources = {
            limits = {
              memory = "512Mi"
              cpu    = "1"
            }
          }
         # volume_mounts = [
         #   {
         #     name       = "api-creds"
         #     mount_path = "/secrets/api"
         #   }
         # ]
        }
      ]
      
      #volumes = [
      #  {
      #    name = "api-creds"
      #    secret = {
      #      secret_name = "typescript-api-credentials"
      #      items = [
      #        {
      #          path    = "credentials.json"
      #          version = "latest"
      #        }
      #      ]
      #    }
      #  }
      #]
      
      min_instance_count = 0
      max_instance_count = 2
      timeout_seconds    = 300
      
      labels = {
        "app"   = "ai-interview"
        "layer" = "backend"
        "tech"  = "typescript"
      }
      
      iam_bindings = [
        {
          role    = "roles/run.invoker"
          members = [
            "serviceAccount:${local.platform_service_account_email}",
            "serviceAccount:${local.api_gateway_service_account_email}"
          ]
        }
      ]
    },
    
    # Python AI Service
    # {
    #   service_name       = "ai-interview-python-server"
    #   container_port     = 8000
    #   service_account    = local.platform_service_account_email
       
    #   containers = [
    #     {
    #       name  = "python-container"
    #       image = "${dependency.artifact_registry_repository.outputs.repository_urls.python_server}/ai-interview-python-server"
    #       tag   = local.image_tag
    #       env_vars = [
    #         {
    #           name  = "GOOGLE_CLOUD_PROJECT"
    #           value = local.gcp_project_id
    #         },
    #         {
    #           name  = "ENVIRONMENT"
    #           value = "production"
    #         },
    #         {
    #           name  = "SERVICE_NAME"
    #           value = "python-ai"
    #         },
    #         {
    #           name  = "WORKERS"
    #           value = "1"
    #         },
    #         {
    #           name  = "LOG_LEVEL"
    #           value = "INFO"
    #         }
    #         ]
    #       resources = {
    #         limits = {
    #           memory = "512Mi"
    #           cpu    = "1"
    #         }
    #       }
    #       volume_mounts = [
    #         {
    #           name       = "ml-models"
    #           mount_path = "/models"
    #         }
    #       ]
    #     }
    #   ]
      
    #   volumes = [
    #     {
    #       name = "ml-models"
    #       secret = {
    #         secret_name = "python-ai-model-configs"
    #         items = [
    #           {
    #             path    = "config.json"
    #             version = "latest"
    #           }
    #         ]
    #       }
    #     }
    #   ]
        
    #   min_instance_count = 0
    #   max_instance_count = 1
    #   timeout_seconds    = 600
      
    #   labels = {
    #     "app"   = "ai-interview"
    #     "layer" = "ai"
    #     "tech"  = "python"
    #   }
      
    #   iam_bindings = [
    #     {
    #       role    = "roles/run.invoker"
    #       members = [
    #         "serviceAccount:${local.platform_service_account_email}",
    #         "serviceAccount:${local.api_gateway_service_account_email}"
    #       ]
    #     }
    #   ]
    # }
  ]
}
