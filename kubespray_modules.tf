# Must register all modules in locals.tf

resource "local_file" "debug-modules" {
  count    = var.dump_debug ? 1 : 0
  filename = ".debug-kubespray-modules.json"
  content  = jsonencode(local.modules)
}
