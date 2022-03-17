provider "kubernetes" {
  config_path = var.use_kubeconfig ? local.kubeconfig_filename : null
}

provider "kubectl" {
  apply_retry_count = 2
  load_config_file  = var.use_kubeconfig
}
