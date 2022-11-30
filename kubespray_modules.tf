# Must register all modules in locals.tf

resource "local_file" "debug-modules" {
  count    = var.dump_debug ? 1 : 0
  filename = ".debug-eks-modules.json"
  content  = jsonencode(local.modules)
}

module "cert-manager" {
  count  = local.modules.cert-manager.enabled ? 1 : 0
  source = "github.com/getupcloud/terraform-module-cert-manager?ref=v2.0.0-alpha2"

  cluster_name  = var.cluster_name
  customer_name = var.customer_name
  provider_name = var.cluster_provider
  provider_aws = (var.cluster_provider == "aws") ? {
    hosted_zone_ids : local.modules.cert-manager.hosted_zone_ids
  } : null
}

module "velero" {
  count  = local.modules.velero.enabled ? 1 : 0
  source = "github.com/getupcloud/terraform-module-velero?ref=v2.0.0-alpha3"

  cluster_name  = var.cluster_name
  customer_name = var.customer_name
  provider_name = var.cluster_provider
  provider_aws = (var.cluster_provider == "aws") ? {
    bucket_name = local.modules.velero.bucket_name
  } : null
}
