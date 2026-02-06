locals {
  cert_manager_namespace = "cert-manager"
}

# Install Cert Manager
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = local.cert_manager_namespace
  create_namespace = true
  version          = var.cert_manager_helm_version
  
  set = [{
    name  = "crds.enabled"
    value = "true"
  }]
}