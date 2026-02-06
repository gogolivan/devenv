resource "kubernetes_manifest" "mutate_gvisor_runtime" {
  manifest = {
    apiVersion = "policies.kyverno.io/v1"
    kind       = "MutatingPolicy"
    metadata = {
      name = "gvisor-runtime"
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

  depends_on = []
}