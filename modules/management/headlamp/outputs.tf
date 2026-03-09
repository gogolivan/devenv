output "headlamp_chart_version" {
  value = {
    version   = helm_release.headlamp.version
  }
}

output "headlamp_token" {
  value     = kubernetes_secret_v1.headlamp_admin_token.data["token"]
  sensitive = true
}