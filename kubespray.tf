#resource "shell_script" "kubespray" {
#  lifecycle_commands {
#    create = local.git_clone
#    update = local.git_pull
#    read   = local.git_show_tag
#    delete = "rm -f ${path.module}/$GIT_WORK_TREE"
#  }
#
#  environment = {
#    GIT_WORK_TREE = "kubespray"
#    GIT_REPO = var.git_repo
#    GIT_BRANCH = var.git_branch
#  }
#}
