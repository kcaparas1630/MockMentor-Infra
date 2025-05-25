# remote state configuration for GCP
remote_state {
    backend = "gcs"
    generate = {
        path        = "backend.tf"
        if_exists   = "overwrite"
    }
    config = {
        project     = "mockmentor-460805"
        location    = "us-east1"
        bucket      = "tf-state-mockmentor"
        prefix      = "${path_relative_to_include()}/terraform.tfstate"
    }
}
