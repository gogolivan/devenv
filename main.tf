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

module "kyverno" {
  source = "./modules/kyverno"
}

module "kubernetes_dashboard" {
  source = "./modules/kubernetes-dashboard"

  depends_on = [module.kyverno]
}

module "istio" {
  source = "./modules/istio"

  depends_on = [module.kyverno]
}

module "cert_manager" {
  count  = lookup(var.modules_enabled, "cert_manager", false) ? 1 : 0

  source = "./modules/cert-manager"

  depends_on = [module.kyverno]
}

module "gitea" {
  count = lookup(var.modules_enabled, "gitea", false) ? 1 : 0

  source = "./modules/gitea"

  depends_on = [module.kyverno, module.istio]
}

module "argocd" {
  count = lookup(var.modules_enabled, "argocd", false) ? 1 : 0

  source = "./modules/argocd"

  depends_on = [module.kyverno, module.istio]
}

module "prometheus" {
  count = lookup(var.modules_enabled, "prometheus", false) ? 1 : 0

  source = "./modules/prometheus"

  depends_on = [module.kyverno, module.istio]
}

module "grafana" {
  count = lookup(var.modules_enabled, "grafana", false) ? 1 : 0

  source = "./modules/grafana"

  depends_on = [module.kyverno]
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

  depends_on = [module.kyverno, module.istio]
}