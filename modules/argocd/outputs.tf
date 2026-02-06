output "argocd_chart_version" {
  value = {
    version = helm_release.argocd.version
  }
}