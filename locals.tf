locals {
  kubeconfig_filename = abspath(pathexpand(var.kubeconfig_filename))

  master_nodes = [for i, node in var.master_nodes : {
    node_type : try(node.node_type, "master")
    hostname : try(node.hostname, "")
    address : try(node.address, "")
    disks : try(node.disks, {})
    node_labels : merge(var.default_master_node_labels, try(node.node_labels, {}))
    node_taints : toset(concat(var.default_master_node_taints, try(node.node_taints, [])))
  }]

  infra_nodes = [for i, node in var.infra_nodes : {
    node_type : try(node.node_type, "infra")
    hostname : try(node.hostname, "")
    address : try(node.address, "")
    disks : try(node.disks, {})
    node_labels : merge(var.default_infra_node_labels, try(node.node_labels, {}))
    node_taints : toset(concat(var.default_infra_node_taints, try(node.node_taints, [])))
  }]

  app_nodes = [for i, node in var.app_nodes : {
    node_type : try(node.node_type, "worker")
    hostname : try(node.hostname, "")
    address : try(node.address, "")
    disks : try(node.disks, {})
    node_labels : merge(var.default_app_node_labels, try(node.node_labels, {}))
    node_taints : toset(concat(var.default_app_node_taints, try(node.node_taints, [])))
  }]

  all_nodes = concat(local.master_nodes, local.infra_nodes, local.app_nodes)

  modules_result = {
    for name, config in merge(var.modules, local.modules) : name => merge(config, {
      output : try(config.enabled, true) ? lookup(local.register_modules, name, try(config.output, tomap({}))) : tomap({})
    })
  }

  manifests_template_vars = merge(
    {
      cluster : {
        region : var.region
      }
    },
    var.manifests_template_vars,
    {
      cluster_provider : var.cluster_provider
      alertmanager_cronitor_id : var.cronitor_id
      alertmanager_opsgenie_integration_api_key : var.opsgenie_integration_api_key
      secret : random_string.secret.result
      suffix : random_string.suffix.result
      modules : local.modules_result
    },
    module.teleport-agent.teleport_agent_config,
    { for k, v in var.manifests_template_vars : k => v if k != "modules" }
  )
}
