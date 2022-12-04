## Provider-specific modules variables
## Copy to toplevel

variable "modules_defaults" {
  description = "Configure modules to install (defaults)"
  type        = object({})

  default = {}
}

locals {
  modules          = merge(var.modules_defaults, var.modules, {})
  register_modules = {}
}
