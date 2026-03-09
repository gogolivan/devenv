terraform {
  // https://github.com/opentofu/opentofu/releases
  required_version = ">= 1.11"

  
  required_providers {
    // https://registry.terraform.io/providers/hashicorp/external/latest
    external = {
      source  = "hashicorp/external" 
      version = "~> 2.3"
    }
    // https://registry.terraform.io/providers/hashicorp/kubernetes/latest
    kubernetes = {
      source  = "hashicorp/kubernetes" 
      version = "~> 2.38"
    }
    // https://registry.terraform.io/providers/hashicorp/helm/latest
    helm = {
      source  = "hashicorp/helm" 
      version = "~> 3.1.1"
    }
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Configure Helm provider
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

module "operators" {
  source = "./modules/operators"
}

module "management" {
  source = "./modules/management"
}

module "networking" {
  count = lookup(var.modules_enabled, "networking", false) ? 1 : 0

  source = "./modules/networking"
}

module "gitops" {
  depends_on = [module.networking]

  count = lookup(var.modules_enabled, "gitops", false) ? 1 : 0

  source = "./modules/gitops"
}

module "observability" {
  depends_on = [module.observability]

  count = lookup(var.modules_enabled, "observability", false) ? 1 : 0

  source = "./modules/observability"
}

module "security" {
  count = lookup(var.modules_enabled, "security", false) ? 1 : 0

  source = "./modules/security"
}

# Istio Kubernetes Gateway API
# https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/
# Traffic Flow
# External request (port 80) -> Kind Ingress (port 80) -> Kubernetes Gateway (Load Balancer port 80) -> HTTPRoute -> Service (Cluster IP application port)
resource "kubernetes_manifest" "gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "gateway"
      namespace = "default"
    }
    spec = {
      gatewayClassName = "istio"
      listeners = [
        {
          name     = "http"
          hostname = "localhost"
          port     = 80
          protocol = "HTTP"
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
    }
  }
}

resource "kubernetes_ingress_v1" "kind_ingress" {
  depends_on = [module.istio]

  metadata {
    name = "kind-ingress"
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "gateway-istio"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}