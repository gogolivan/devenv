locals {
  prometheus_namespace     = "monitoring"
}

# Install Prometheus
# https://artifacthub.io/packages/helm/prometheus-community/prometheus
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_helm_version
}


resource "kubernetes_manifest" "prometheus_httproute" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "prometheus-route"
      namespace = local.prometheus_namespace
    }
    spec = {
      parentRefs = [
        {
          name      = "gateway"
          namespace = "default"
        }
      ]
      hostnames = ["localhost"]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/prometheus"
              }
            }
          ]
          backendRefs = [
            {
              name = "prometheus-server"
              port = 80
              namespace : local.prometheus_namespace
            }
          ]
        }
      ]
    }
  }

  depends_on = [ helm_release.prometheus ]
}