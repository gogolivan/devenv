terraform {
  required_version = ">= 1.14" // https://github.com/hashicorp/terraform/releases

  required_providers {
    external = {
      source  = "hashicorp/external" // https://registry.terraform.io/providers/hashicorp/external/latest
      version = "~> 2.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes" // https://registry.terraform.io/providers/hashicorp/kubernetes/latest
      version = "~> 2.38"
    }
    helm = {
      source  = "hashicorp/helm" // https://registry.terraform.io/providers/hashicorp/helm/latest
      version = "~> 3.1.1"
    }
  }
}