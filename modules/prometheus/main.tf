locals {
  prometheus_namespace     = "monitoring"
}

# Install Prometheus
# https://artifacthub.io/packages/helm/prometheus-community/prometheus
# helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_helm_version

  set = [ 
    {
      name = "server.replicaCount"
      value = "1"
    },
    {
      name = "prometheus-node-exporter.enabled",
      value = "false"
    },
    {
      name = "alertmanager.enabled"
      value = "false"
    },
    {
      name  = "server.retention"
      value = "6h"
    },
    {
      name  = "server.global.scrape_interval"
      value = "60s"
    },
    {
      name  = "server.resources.requests.memory"
      value = "256Mi"
    },
    {
      name  = "server.resources.limits.memory"
      value = "512Mi"
    },
    {
      name  = "prometheus-pushgateway.resources.requests.memory"
      value = "64Mi"
    },
    {
      name  = "prometheus-pushgateway.resources.limits.memory"
      value = "128Mi"
    },
    {
      name  = "kube-state-metrics.resources.requests.memory"
      value = "64Mi"
    },
    {
      name  = "kube-state-metrics.resources.limits.memory"
      value = "128Mi"
    }
  ]
}


resource "kubernetes_manifest" "prometheus_httproute" {
  depends_on = [ helm_release.prometheus ]

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
}