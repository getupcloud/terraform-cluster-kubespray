module "internet" {
  source = "github.com/getupcloud/terraform-module-internet?ref=main"
}

#module "flux" {
#  source = "github.com/getupcloud/terraform-module-flux?ref=main"
#
#  git_repo       = var.flux_git_repo
#  manifests_path = "./clusters/${var.name}/kubespray/manifests"
#  wait           = var.flux_wait
#}

resource "shell_script" "kubespray-repo" {
  triggers = {
    ref = var.kubespray_git_ref
  }

  lifecycle_commands {
    create = local.git_setup
    update = local.git_checkout
    read   = local.git_state
    delete = local.git_reset
  }

  environment = {
    KUBESPRAY_GIT_REF = var.kubespray_git_ref
  }
}
