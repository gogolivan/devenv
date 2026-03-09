variable "modules_enabled" {
  description = "Enable modules to be deployed into the cluster."
  type        = map(bool)
  default = {
    istio = false
    gitea  = false
    argocd = false
    prometheus = true
    grafana = false
    openbao = false
  }
}