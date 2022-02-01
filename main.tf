module "internet" {
  source = "github.com/getupcloud/terraform-module-internet?ref=v1.0"
}

module "flux" {
  source = "github.com/getupcloud/terraform-module-flux?ref=v1.0"
  count  = var.deploy_components ? 1 : 0

  git_repo       = var.flux_git_repo
  manifests_path = "./clusters/${var.cluster_name}/kubespray/manifests"
  wait           = var.flux_wait
  flux_version   = var.flux_version

  manifests_template_vars = merge({
    alertmanager_cronitor_id : module.cronitor[0].cronitor_id
  }, var.manifests_template_vars)
}

module "cronitor" {
  source = "github.com/getupcloud/terraform-module-cronitor?ref=v1.0"
  count  = var.deploy_components ? 1 : 0

  cluster_name  = var.cluster_name
  customer_name = var.customer_name
  cluster_sla   = var.cluster_sla
  suffix        = "kspray"
  tags          = [var.kubespray_git_ref]
  pagerduty_key = var.cronitor_pagerduty_key
  api_key       = var.cronitor_api_key
  api_endpoint  = var.api_endpoint
}

module "provisioner" {
  source = "github.com/getupcloud/terraform-module-provisioner?ref=v1.0"

  nodes           = local.all_nodes
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
    MASTER_NODES       = base64encode(jsonencode(local.master_nodes))
    INFRA_NODES        = base64encode(jsonencode(local.infra_nodes))
    APP_NODES          = base64encode(jsonencode(local.app_nodes))
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
    MASTER_NODES       = base64encode(jsonencode(local.master_nodes))
    INFRA_NODES        = base64encode(jsonencode(local.infra_nodes))
    APP_NODES          = base64encode(jsonencode(local.app_nodes))
  }
}

module "kubeconfig" {
  source = "github.com/getupcloud/terraform-module-kubeconfig?ref=v1.0"

  cluster_name = var.cluster_name
  command      = var.get_kubeconfig_command
  kubeconfig   = var.kubeconfig_filename
}
