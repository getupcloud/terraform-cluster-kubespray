terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }

    kubernetes = {
      version = "~> 2.8"
    }

    kustomization = {
      source  = "kbst/kustomization"
      version = "< 1"
    }

    random = {
      version = "~> 2"
    }

    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1"
    }
  }
}

provider "kustomization" {
  kubeconfig_raw = ""
}

module "cluster" {
  source = "../"

  cluster_name = "cluster_name"
  customer_name = "customer_name"

  kubernetes_version = "v0.0.0"
  ssh_user = "root"
}
