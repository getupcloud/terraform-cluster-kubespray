## Provider-specific modules variables
## Copy to toplevel

variable "modules_defaults" {
  description = "Configure modules to install (defaults)"
  type = object({
    metallb = object({
      enabled   = bool
      addresses = list(string)
    })
  })

  default = {
    metallb = {
      enabled   = false
      addresses = []
    }
  }
}

locals {
  register_modules = {}
}
