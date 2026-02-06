variable "modules_enabled" {
  description = "Enable modules to be deployed into the cluster."
  type        = map(bool)
  default = {
    kyverno = true
    cert_manager = false
    gitea  = true
    argocd = false
    prometheus = true
    grafana = true
  }
}