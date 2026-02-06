variable "kubernetes_dashboard_helm_versions" {
    type = map(string)
    description = "Helm Charts version for Kubernetes Dashboard"

    default = {
      "kubernetes_dashboard" = "7.14.0"
    }
}