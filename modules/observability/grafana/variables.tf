variable "grafana_helm_charts_version" {
    type = map(string)
    description = "Charts version for Grafana"

    default = {
      "grafana" = "10.4.0"
      "loki" = "6.49.0",
      "tempo" = "1.24.1"
    }
}