output "kyverno_chart_version" {
  value = {
    version   = helm_release.kyverno.version
  }
}