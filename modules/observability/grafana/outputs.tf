output "grafana_chart_versions" {
  description = "Grafana components chart versions"
  value = {
    grafana_version   = helm_release.grafana.version
    loki_version = helm_release.loki.version
    tempo_version  = helm_release.tempo.version
  }
}