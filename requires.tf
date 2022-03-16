terraform {
  required_providers {
    random = {
      version = "~> 2"
    }

    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }

    kubernetes = {
      version = "~> 2.3.2"
    }
  }
}
