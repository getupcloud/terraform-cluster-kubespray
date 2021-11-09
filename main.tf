module "internet" {
  source = "github.com/getupcloud/terraform-module-internet?ref=main"
}

module "flux" {
  source = "github.com/getupcloud/terraform-module-flux?ref=main"

  git_repo       = var.flux_git_repo
  manifests_path = "./clusters/${var.name}/kubespray/manifests"
  wait           = var.flux_wait
  cluster_template_vars = {
    cronitor_id : module.cronitor.cronitor_id
  }
}

module "cronitor" {
  source = "github.com/getupcloud/terraform-module-cronitor?ref=main"

  cluster_name  = var.name
  customer_name = var.customer_name
  suffix        = "ksp"
  tags          = [var.kubespray_git_ref]
  pagerduty_key = var.cronitor_pagerduty_key
  api_key       = var.cronitor_api_key
  api_endpoint  = var.api_endpoint
}

resource "shell_script" "kubespray-repo" {
  triggers = {
    ref = var.kubespray_git_ref
  }

  lifecycle_commands {
    create = local.git_setup
    update = local.git_setup
    read   = local.git_state
    delete = local.git_reset
  }

  environment = {
    KUBESPRAY_GIT_REF = var.kubespray_git_ref
  }
}

module "provisioner" {
  source = "github.com/getupcloud/terraform-module-provisioner?ref=main"

  masters         = var.masters
  workers         = var.workers
  ssh_user        = var.ssh_user
  ssh_private_key = var.ssh_private_key
}
