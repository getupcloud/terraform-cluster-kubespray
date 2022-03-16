locals {
  kubeconfig_filename = abspath(pathexpand(var.kubeconfig_filename))

  suffix = random_string.suffix.result
  secret = random_string.secret.result

  master_nodes = [for i, node in var.master_nodes : merge({
    node_type : "master"
    hostname : "master-${i}"
    disks : {}
    labels : var.default_master_node_labels
    taints : var.default_master_node_taints
  }, node)]

  infra_nodes = [for i, node in var.infra_nodes : merge({
    node_type : "worker"
    hostname : "infra-${i}"
    disks : {}
    labels : var.default_infra_node_labels
    taints : var.default_infra_node_taints
  }, node)]

  app_nodes = [for i, node in var.app_nodes : merge({
    node_type : "worker"
    hostname : "app-${i}"
    disks : {}
    labels : var.default_app_node_labels
    taints : var.default_app_node_taints
  }, node)]

  all_nodes = concat(local.master_nodes, local.infra_nodes, local.app_nodes)
}
