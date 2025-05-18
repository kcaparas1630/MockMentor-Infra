# AI-Interviewer-Infrastructure

Infrastructure-as-Code (IaC) for deploying and managing the AI Interviewer platform on Google Cloud, using Terragrunt and Terraform for modular, scalable, and secure cloud resource provisioning.

---

## 📁 Project Structure

| Path                                 | Description                                      |
|-------------------------------------- |--------------------------------------------------|
| `modules.hcl`                        | Module sources and versions for infrastructure   |
| `project.hcl`                        | GCP project-level variables                      |
| `terragrunt.hcl`                     | Root Terragrunt remote state config (GCS)        |
| `.gitignore`                         | VCS ignore rules for Terraform/Terragrunt        |
| `dev/`                               | Development environment configs                  |
| `dev/env.hcl`                        | Environment name/shortname                       |
| `dev/global.hcl`                     | Global variables for the dev environment         |
| `dev/us-east1/`                      | Region-specific configs (us-east1)               |
| `dev/us-east1/region.hcl`            | GCP region variable                              |
| `dev/us-east1/services.hcl`          | Service account/role definitions                 |
| `dev/us-east1/cloudrun/`             | Cloud Run deployment config                      |
| `dev/us-east1/artifact-repo/`        | Artifact Registry config                         |
| `dev/us-east1/service-accounts/`     | Service Account config                           |
| `_envcommons/`                       | Shared config for artifact registry, cloud run   |

---

## 🚀 Features

- **Modular IaC**: Uses Terragrunt to manage reusable, versioned modules.
- **GCP Native**: Provisions resources on Google Cloud (Cloud Run, Artifact Registry, IAM).
- **Environment & Region Support**: Easily extendable for multiple environments/regions.
- **Secrets Management**: Supports encrypted secrets via SOPS.
- **Service Accounts**: Fine-grained IAM roles for least-privilege access.
- **CI/CD Ready**: Designed for integration with automated pipelines.

---

## 🏗️ Infrastructure Overview

### Module Management (`modules.hcl`)
- Centralizes source URLs and versions for:
  - Artifact Registry
  - Cloud Run
  - Service Accounts

### State Management (`terragrunt.hcl`)
- Uses GCS for remote Terraform state.
- State bucket and prefix are auto-configured per environment/region.

### Environments & Regions
- `dev/` for development; add more for staging/prod.
- `us-east1/` for region-specific resources.

### Cloud Run (`dev/us-east1/cloudrun/terragrunt.hcl`)
- Deploys frontend and backend services as containers.
- Configures probes, scaling, IAM bindings, and secrets injection.

### Artifact Registry (`dev/us-east1/artifact-repo/terragrunt.hcl`)
- Creates Docker repositories for each service.

### Service Accounts (`dev/us-east1/service-accounts/terragrunt.hcl`)
- Provisions and assigns roles to service accounts for platform and API Gateway.

---

## 🗂️ Key Directories & Files

| Path                                         | Description                                  |
|-----------------------------------------------|----------------------------------------------|
| `_envcommons/artifact-registry.hcl`           | Shared Artifact Registry config              |
| `_envcommons/cloudrun.hcl`                    | Shared Cloud Run config                      |
| `dev/us-east1/cloudrun/secrets/`              | Encrypted secrets (SOPS) for services        |

---

## 🧩 Dependencies

- **Terragrunt**: Infrastructure orchestration
- **Terraform**: Resource provisioning
- **Google Cloud SDK**: For authentication and deployment
- **SOPS**: For managing encrypted secrets

---

## 🐳 Deployment & Usage

### Prerequisites

- [Terragrunt](https://terragrunt.gruntwork.io/)
- [Terraform](https://www.terraform.io/)
- [Google Cloud SDK](https://cloud.google.com/sdk)
- [SOPS](https://github.com/mozilla/sops) (for secrets)

### Quickstart

```bash
# Authenticate with GCP
gcloud auth application-default login

# Initialize and apply infrastructure (example: Cloud Run)
cd dev/us-east1/cloudrun
terragrunt init
terragrunt apply
```

### Managing Secrets

- Place SOPS-encrypted YAML files in `dev/us-east1/cloudrun/secrets/`.
- Example: `frontend.enc.yaml`, `typescript.enc.yaml`

---

## 🔄 CI/CD Integration

- Designed for use with CI/CD pipelines (e.g., GitHub Actions, Cloud Build).
- Automate `terragrunt apply` for infrastructure changes.

---

## 📝 .gitignore

- Ignores Terraform/Terragrunt state, cache, and sensitive files.

---

## 📚 Extending

- Add new environments in `dev/`
- Add new regions as subfolders (e.g., `dev/europe-west1/`)
- Add new modules in `modules.hcl` and reference in configs

---

## 🛡️ Security

- Service accounts follow least-privilege principle.
- Secrets are encrypted at rest using SOPS.

---

## ℹ️ References

- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Google Cloud Run](https://cloud.google.com/run)
- [Google Artifact Registry](https://cloud.google.com/artifact-registry)
