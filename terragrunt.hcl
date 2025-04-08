# remote state configuration for GCP
remote_state {
    backend = "gcs"
    generate = {
        path        = "backend.tf"
        if_exists   = "overwrite"
    }
    config = {
        project     = "terraform-practice-455719"
        location    = "us-east1"
        bucket      = "tf-state-ai-interviewer"
        prefix      = "${path_relative_to_include()}/terraform.tfstate"
    }
}
