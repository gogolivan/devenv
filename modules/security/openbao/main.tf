# https://artifacthub.io/packages/helm/openbao/openbao
resource "helm_release" "openbao" {
  name             = "openbao"
  repository       = "https://openbao.github.io/openbao-helm"
  chart            = "openbao"
  namespace        = "openbao"
  create_namespace = true

  version = var.openbao_helm_version

  values = [
    yamlencode({
      server = {
        dev = {
          enabled = true
        }
        resources = {
          limits = {
            cpu    = "100m"
            memory = "256Mi"
          }
          requests = {
            cpu    = "20m"
            memory = "128Mi"
          }
        }
      }
      injector = {
        resources = {
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu    = "20m"
            memory = "64Mi"
          }
        }
      }
    })
  ]
}