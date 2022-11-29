## Provider-specific modules variables
## Copy to toplevel

variable "modules_defaults" {
  description = "Configure modules to install (defaults)"
  type = object({
    cert-manager = object({
      enabled         = bool
      hosted_zone_ids = list(string)
    })
    external-dns = object({
      enabled         = bool
      private         = bool
      hosted_zone_ids = list(string)
      domain_filters  = list(string)
    })
  })

  default = {
    cert-manager = {
      enabled         = false
      hosted_zone_ids = []
    }
    external-dns = {
      enabled         = false
      private         = false
      hosted_zone_ids = []
      domain_filters  = []
    }
  }
}

locals {
  modules = merge(var.modules_defaults, var.modules, {
    cert-manager = {
      enabled         = try(var.modules.cert-manager.enabled, var.modules_defaults.cert-manager.enabled)
      hosted_zone_ids = try(var.modules.cert-manager.hosted_zone_ids, var.modules_defaults.cert-manager.hosted_zone_ids)
    }
    external-dns = {
      enabled         = try(var.modules.external-dns.enabled, var.modules_defaults.external-dns.enabled)
      private         = try(var.modules.external-dns.private, var.modules_defaults.external-dns.private)
      hosted_zone_ids = try(var.modules.external-dns.hosted_zone_ids, var.modules_defaults.external-dns.hosted_zone_ids)
      domain_filters  = try(var.modules.external-dns.domain_filters, var.modules_defaults.external-dns.domain_filters)
    }
  })

  register_modules = {}
}
