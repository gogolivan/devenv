output "prometheus_chart_version" {
  value = {
    version   = helm_release.prometheus.version
  }
}