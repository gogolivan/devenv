output "istio_chart_versions" {
  description = "Istio components chart versions"
  value = {
    base_version   = helm_release.istio_base.version
    istiod_version = helm_release.istiod.version
    kiali_version  = helm_release.kiali_server.version
  }
}