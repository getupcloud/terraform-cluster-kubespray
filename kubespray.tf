resource "shell_script" "kubespray-repo" {
  lifecycle_commands {
    create = local.git_checkout
    update = local.git_checkout
    read   = local.git_state
    delete = local.git_reset
  }

  environment = {
    KUBESPRAY_GIT_REF = var.kubespray_git_ref
  }
}
