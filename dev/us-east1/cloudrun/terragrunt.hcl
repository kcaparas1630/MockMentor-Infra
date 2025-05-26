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

dependency "service_accounts" {
  config_path = "../service-accounts"
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
  python_secrets = fileexists("${local.secrets_dir}/python.enc.yaml") ? yamldecode(sops_decrypt_file("${local.secrets_dir}/python.enc.yaml")) : {}
  
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
      service_name       = "mockmentor-frontend-dev"
      container_port     = 80
      service_account    = local.platform_service_account_email
      
      containers = [
        {
          name  = "frontend-container"
          image = "${dependency.artifact_registry_repository.outputs.repository_urls.frontend}/mockmentor-frontend-dev"
          tag   = local.image_tag
          env_vars = concat(
            [
              { name = "GOOGLE_CLOUD_PROJECT", value = local.gcp_project_id },
              { name = "NODE_ENV", value= "production" }
            ],
            [for key, value in local.frontend_secrets.env_vars : { name = key, value = value }]
          )
          resources = {
            limits = {
              memory = "512Mi"
              cpu    = "1"
            }
          }
          startup_probe = {
            http_get = {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 0
            period_seconds        = 5
            timeout_seconds       = 2
            failure_threshold     = 30
            success_threshold     = 1
          }
          liveness_probe = {
            http_get = {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 3
            success_threshold     = 1
          }
        }
      ]
      
      min_instance_count = 0
      max_instance_count = 2
      
      labels = {
        "app"   = "mockmentor"
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
      service_name       = "mockmentor-express-server-dev"
      container_port     = 3000
      service_account    = local.platform_service_account_email
      
      containers = [
        {
          name  = "typescript-container"
          image = "${dependency.artifact_registry_repository.outputs.repository_urls.typescript_server}/mockmentor-express-server-dev"
          tag   = local.image_tag
          env_vars = [
            { name = "GOOGLE_CLOUD_PROJECT", value = local.gcp_project_id },
            { name = "NODE_ENV", value = "production" },
            { name = "FIREBASE_TYPE", value = local.typescript_secrets.FIREBASE_TYPE },
            { name = "FIREBASE_PROJECT_ID", value = local.typescript_secrets.FIREBASE_PROJECT_ID },
            { name = "FIREBASE_PRIVATE_KEY_ID", value = local.typescript_secrets.FIREBASE_PRIVATE_KEY_ID },
            { name = "FIREBASE_PRIVATE_KEY", value = local.typescript_secrets.FIREBASE_PRIVATE_KEY },
            { name = "FIREBASE_CLIENT_EMAIL", value = local.typescript_secrets.FIREBASE_CLIENT_EMAIL },
            { name = "FIREBASE_CLIENT_ID", value = local.typescript_secrets.FIREBASE_CLIENT_ID },
            { name = "FIREBASE_AUTH_URI", value = local.typescript_secrets.FIREBASE_AUTH_URI },
            { name = "FIREBASE_TOKEN_URI", value = local.typescript_secrets.FIREBASE_TOKEN_URI },
            { name = "FIREBASE_AUTH_PROVIDER_X509_CERT_URL", value = local.typescript_secrets.FIREBASE_AUTH_PROVIDER_X509_CERT_URL },
            { name = "FIREBASE_CLIENT_X509_CERT_URL", value = local.typescript_secrets.FIREBASE_CLIENT_X509_CERT_URL },
            { name = "FIREBASE_UNIVERSE_DOMAIN", value = local.typescript_secrets.FIREBASE_UNIVERSE_DOMAIN }
          ],
          resources = {
            limits = {
              memory = "512Mi"
              cpu    = "1"
            }
          }
          startup_probe = {
            http_get = {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 0
            period_seconds        = 5
            timeout_seconds       = 2
            failure_threshold     = 30
            success_threshold     = 1
          }
          liveness_probe = {
            http_get = {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 3
            success_threshold     = 1
          }
        }
      ]
      
      min_instance_count = 0
      max_instance_count = 2
      timeout_seconds    = 600
      
      labels = {
        "app"   = "mockmentor"
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
    {
      service_name       = "mockmentor-ai-service-dev"
      container_port     = 8000
      service_account    = local.platform_service_account_email
       
      containers = [
        {
          name  = "python-container"
          image = "${dependency.artifact_registry_repository.outputs.repository_urls.python_server}/mockmentor-python-server-dev"
          tag   = local.image_tag
          env_vars = concat(
            [
              { name = "GOOGLE_CLOUD_PROJECT", value = local.gcp_project_id },
              { name = "NODE_ENV",          value = "production" },
            ],
            [for key, value in local.python_secrets.env_vars : { name = key, value = value }]
          )
          resources = {
            limits = {
              memory = "512Mi"
              cpu    = "1"
            }
          }
        
          min_instance_count = 0
          max_instance_count = 1
          timeout_seconds    = 600
          
          labels = {
            "app"   = "mockmentor"
            "layer" = "ai"
            "tech"  = "python"
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
        }
      ]
    }
  ]
}
