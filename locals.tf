locals {
  kubeconfig_filename = abspath(pathexpand(var.kubeconfig_filename))

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

  modules_result = {
    for name, config in merge(var.modules, local.modules) : name => merge(config, {
      output : config.enabled ? lookup(local.register_modules, name, try(config.output, tomap({}))) : tomap({})
    })
  }

  manifests_template_vars = merge(
    var.manifests_template_vars,
    {
      cluster_provider : var.cluster_provider
      alertmanager_cronitor_id : try(module.cronitor.cronitor_id, "")
      alertmanager_opsgenie_integration_api_key : try(module.opsgenie.api_key, "")
      secret : random_string.secret.result
      suffix : random_string.suffix.result
      modules : local.modules_result
    },
    module.teleport-agent.teleport_agent_config,
    { for k, v in var.manifests_template_vars : k => v if k != "modules" }
  )
}
