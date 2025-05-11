locals {
  
  # Service configuration settings
  service_region = "us-east1"
  
  # Specific service account settings
  default_service_account = {
    name = "ai-interviewer-default-sa"
    roles = [
      "roles/run.invoker",
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter"
    ]
  }
  
  # API Gateway service account settings
  api_gateway_service_account = {
    name = "ai-interviewer-api-gateway-sa"
    roles = [
      "roles/run.invoker",
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
      "roles/apigateway.admin"
    ]
  }
}
