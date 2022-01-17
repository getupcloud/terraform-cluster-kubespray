locals {
  kubeconfig = abspath(pathexpand(var.kubeconfig_filename))
  suffix     = random_string.suffix.result
  secret     = random_string.secret.result

  master_nodes = [for i, node in var.master_nodes : merge({
    node_type : "master"
    hostname : "master-${i}"
    disks : {}
    node_labels : var.default_master_node_labels
  }, node)]

  infra_nodes  = [for i, node in var.infra_nodes : merge({
    node_type : "infra"
    hostname : "infra-${i}"
    disks : {}
    node_labels : var.default_infra_node_labels
  }, node)]

  app_nodes    = [for i, node in var.app_nodes : merge({
    node_type : "app"
    hostname : "app-${i}"
    disks : {}
    node_labels : var.default_app_node_labels
  }, node)]
}
