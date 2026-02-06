resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  namespace        = "kyverno"
  create_namespace = true
  version          = var.kyverno_helm_version
}

resource "kubernetes_manifest" "mutate_gvisor_runtime" {
  manifest = {
    apiVersion = "policies.kyverno.io/v1"
    kind       = "MutatingPolicy"
    metadata = {
      name = "add-gvisor-runtime"
    }
    spec = {
      matchConstraints = {
        resourceRules = [
          {
            apiGroups   = [""]
            apiVersions = ["v1"]
            operations  = ["CREATE", "UPDATE"]
            resources   = ["pods"]
          }
        ]
      }
      mutations = [
        {
          patchType = "ApplyConfiguration"
          applyConfiguration = {
            expression = <<-EOT
              Object{
                spec: Object.spec{
                  runtimeClassName: "gvisor"
                }
              }
            EOT
          }
        }
      ]
    }
  }

  depends_on = [helm_release.kyverno]
}