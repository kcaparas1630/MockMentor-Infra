locals {
    modules = {
        artifact-registry = {
            source_url = "git::https://github.com/kcaparas1630/AI-Interview-Artifact-Registry-Module.git//_module"
            version = "v1.0.1"
        }
        cloud-run = {
            source_url = "git::https://github.com/kcaparas1630/AI-Interview-Cloudrun-Module.git//_module"
            version = "v1.0.1"
        }
        service-accounts = {
            source_url = "git::https://github.com/kcaparas1630/Mock-Mentor-Service-Account.git//_module"
            version = "v1.0.1"
        }
    }
}
