output "headlamp_chart_version" {
  value = {
    version   = helm_release.headlamp.version
  }
}