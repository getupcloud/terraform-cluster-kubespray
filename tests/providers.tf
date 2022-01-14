provider "shell" {
  enable_parallelism = true
  interpreter        = ["/bin/bash", "-c"]
}

provider "kubectl" {
  config_path       = var.kubeconfig_filename
  apply_retry_count = 2
}

provider "kubernetes" {
  config_path = var.kubeconfig_filename
}
