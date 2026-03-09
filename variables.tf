variable "modules_enabled" {
  description = "Enable modules to be deployed into the cluster."
  type        = map(bool)
  default = {
    networking = false
    gitops  = false
    observability = false
    security = true
  }
}