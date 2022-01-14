module "internet" {
  source = "github.com/getupcloud/terraform-module-internet?ref=main"
}

module "flux" {
  source = "github.com/getupcloud/terraform-module-flux?ref=main"
  count  = var.deploy_components ? 1 : 0

  git_repo       = var.flux_git_repo
  manifests_path = "./clusters/${var.name}/kubespray/manifests"
  wait           = var.flux_wait
  manifests_template_vars = {
    cronitor_id : module.cronitor[0].cronitor_id
  }
}

module "cronitor" {
  source = "github.com/getupcloud/terraform-module-cronitor?ref=main"
  count  = var.deploy_components ? 1 : 0

  cluster_name  = var.name
  customer_name = var.customer
  suffix        = "kspray"
  tags          = [var.kubespray_git_ref]
  pagerduty_key = var.cronitor_pagerduty_key
  api_key       = var.cronitor_api_key
  api_endpoint  = var.api_endpoint
}

module "provisioner" {
  source = "github.com/getupcloud/terraform-module-provisioner?ref=main"

  masters         = var.masters
  workers         = var.workers
  ssh_user        = var.ssh_user
  ssh_private_key = var.ssh_private_key
  etc_hosts       = var.etc_hosts
}

resource "shell_script" "kubespray-repo" {
  triggers = {
    ref = var.kubespray_git_ref
  }

  lifecycle_commands {
    create = "${path.module}/kubespray-repo-setup.sh create"
    update = "${path.module}/kubespray-repo-setup.sh update"
    read   = "${path.module}/kubespray-repo-setup.sh read"
    delete = "${path.module}/kubespray-repo-setup.sh delete"
  }

  environment = {
    KUBESPRAY_GIT_REPO = var.kubespray_git_repo
    KUBESPRAY_GIT_REF  = var.kubespray_git_ref
    KUBESPRAY_DIR      = var.kubespray_dir
    GIT_DIR            = "${var.kubespray_dir}/.git"
    INVENTORY_FILE     = var.inventory_file
    MASTERS            = base64encode(jsonencode(var.masters))
    WORKERS            = base64encode(jsonencode(var.workers))
  }
}

resource "shell_script" "kubespray-inventory" {
  depends_on = [shell_script.kubespray-repo]

  lifecycle_commands {
    create = "${path.module}/kubespray-inventory-setup.sh create"
    update = "${path.module}/kubespray-inventory-setup.sh update"
    read   = "${path.module}/kubespray-inventory-setup.sh read"
    delete = "${path.module}/kubespray-inventory-setup.sh delete"
  }

  environment = {
    KUBESPRAY_GIT_REPO = var.kubespray_git_repo
    KUBESPRAY_GIT_REF  = var.kubespray_git_ref
    KUBESPRAY_DIR      = var.kubespray_dir
    GIT_DIR            = "${var.kubespray_dir}/.git"
    INVENTORY_FILE     = var.inventory_file
    MASTERS            = base64encode(jsonencode(var.masters))
    WORKERS            = base64encode(jsonencode(var.workers))
  }
}


