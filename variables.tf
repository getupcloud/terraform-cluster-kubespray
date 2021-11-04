variable "name" {
  description = "Cluster name"
  type        = string
}

variable "kubespray_git_ref" {
  description = "Kubespray ref name"
  type        = string
  default     = "remotes/origin/release-2.17"
}

variable "kubeconfig_filename" {
  description = "Kubeconfig path"
  default     = "~/.kube/config"
  type        = string
}

variable "get_kubeconfig_command" {
  description = "Command to create/update kubeconfig"
  default     = "true"
}

variable "flux_git_repo" {
  description = "GitRepository URL."
  type        = string
  default     = ""
}

variable "flux_wait" {
  description = "Wait for all manifests to apply"
  type        = bool
  default     = true
}

variable "manifests_path" {
  description = "Manifests dir inside GitRepository"
  type        = string
  default     = ""
}

variable "cronitor_api_key" {
  description = "Wait for all manifests to apply"
  type        = string
  default     = null
}

variable "cronitor_pagerduty_key" {
  description = "Wait for all manifests to apply"
  type        = string
  default     = null
}
