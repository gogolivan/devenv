locals {
  grafana_namespace = "monitoring"
}

# https://artifacthub.io/packages/helm/grafana/grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = lookup(var.grafana_helm_charts_version, "grafana", null)
  namespace  = local.grafana_namespace
  create_namespace = true
}

# https://artifacthub.io/packages/helm/grafana/loki
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = lookup(var.grafana_helm_charts_version, "loki", null)
  namespace  = local.grafana_namespace

  values = [
    file("${path.root}/modules/grafana/values/loki/values.yaml")
  ]

  depends_on = [ helm_release.grafana ]
}

# https://artifacthub.io/packages/helm/grafana/tempo
resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  version    = lookup(var.grafana_helm_charts_version, "tempo", null)
  namespace  = local.grafana_namespace

  depends_on = [ helm_release.grafana ]
}