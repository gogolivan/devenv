variable "istio_helm_charts_version" {
    type = map(string)
    description = "Charts version for Istio"

    default = {
      "istio_base" = "1.28.0"
      "istiod" = "1.28.0",
      "kiali_server" = "2.18.0"
    }
}