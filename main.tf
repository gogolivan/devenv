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

module "olm" {
  source = "./modules/olm"
}

module "headlamp" {
  source = "./modules/headlamp"
}

module "istio" {
  count = lookup(var.modules_enabled, "istio", false) ? 1 : 0

  source = "./modules/istio"
}

module "gitea" {
  depends_on = [module.istio]

  count = lookup(var.modules_enabled, "gitea", false) ? 1 : 0

  source = "./modules/gitea"
}

module "argocd" {
  depends_on = [module.istio]

  count = lookup(var.modules_enabled, "argocd", false) ? 1 : 0

  source = "./modules/argocd"
}

module "prometheus" {
  depends_on = [module.istio]

  count = lookup(var.modules_enabled, "prometheus", false) ? 1 : 0

  source = "./modules/prometheus"
}

module "grafana" {
  depends_on = [module.istio, module.prometheus]

  count = lookup(var.modules_enabled, "grafana", false) ? 1 : 0

  source = "./modules/grafana"
}

module "openbao" {
  count = lookup(var.modules_enabled, "openbao", false) ? 1 : 0

  source = "./modules/openbao"
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