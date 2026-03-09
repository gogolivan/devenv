output "gitea_chart_version" {
  value = {
    version = helm_release.gitea.version
  }
}