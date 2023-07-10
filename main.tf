module "internet" {
  source = "github.com/getupcloud/terraform-module-internet?ref=v1.0"
}

module "teleport-agent" {
  source = "github.com/getupcloud/terraform-module-teleport-agent-config?ref=v0.3"

  auth_token       = var.teleport_auth_token
  cluster_name     = var.cluster_name
  customer_name    = var.customer_name
  cluster_sla      = var.cluster_sla
  cluster_provider = "kubespray"
  cluster_region   = var.region
}

module "flux" {
  source = "github.com/getupcloud/terraform-module-flux?ref=v2.3.0"
  count  = var.deploy_components ? 1 : 0

  git_repo                = var.flux_git_repo
  manifests_path          = "./clusters/${var.cluster_name}/kubespray/manifests"
  wait                    = var.flux_wait
  flux_version            = var.flux_version
  manifests_template_vars = local.manifests_template_vars
  debug                   = var.dump_debug
}

module "cronitor" {
  source = "github.com/getupcloud/terraform-module-cronitor?ref=v2.0"

  cronitor_enabled   = var.cronitor_enabled
  api_endpoint       = var.api_endpoint
  cluster_name       = var.cluster_name
  customer_name      = var.customer_name
  cluster_sla        = var.cluster_sla
  suffix             = "kspray"
  tags               = [var.kubespray_git_ref]
  pagerduty_key      = var.cronitor_pagerduty_key
  notification_lists = var.cronitor_notification_lists
}

module "opsgenie" {
  source = "github.com/getupcloud/terraform-module-opsgenie?ref=v1.2"

  opsgenie_enabled = var.opsgenie_enabled
  customer_name    = var.customer_name
  cluster_name     = var.cluster_name
  owner_team_name  = var.opsgenie_team_name
}

module "provisioner" {
  source = "github.com/getupcloud/terraform-module-provisioner?ref=v1.4.3"

  nodes                   = local.all_nodes
  ssh_user                = var.ssh_user
  ssh_password            = var.ssh_password
  ssh_private_key         = var.ssh_private_key
  ssh_bastion_host        = var.ssh_bastion_host
  ssh_bastion_user        = var.ssh_bastion_user
  ssh_bastion_password    = var.ssh_bastion_password
  ssh_bastion_private_key = var.ssh_bastion_private_key
  install_packages        = concat(var.install_packages, var.install_packages_default)
  uninstall_packages      = concat(var.uninstall_packages, var.uninstall_packages_default)
  systemctl_enable        = var.systemctl_enable
  systemctl_disable       = var.systemctl_disable
  etc_hosts               = var.etc_hosts
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
    KUBESPRAY_REPO_DIR = "${path.module}/kubespray"
    KUBESPRAY_GIT_REF  = var.kubespray_git_ref
    KUBESPRAY_DIR      = var.kubespray_dir
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
    KUBESPRAY_REPO_DIR = "${path.module}/kubespray"
    KUBESPRAY_GIT_REF  = var.kubespray_git_ref
    KUBESPRAY_DIR      = var.kubespray_dir
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
