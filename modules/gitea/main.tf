locals {
  gitea_namespace = "git"
  helm_values = {
    resources = var.gitea_resources

    gitea = {
      config = {
        server = var.gitea_server_config
      }
    }
  }
}

# Gitea
# https://artifacthub.io/packages/helm/gitea/gitea
resource "helm_release" "gitea" {
  name             = "gitea"
  repository       = "https://dl.gitea.io/charts/"
  chart            = "gitea"
  namespace        = local.gitea_namespace
  version          = var.gitea_helm_version 
  create_namespace = true

  set = [
    { name = "valkey-cluster.enabled", value = "false" },
    { name = "valkey.enabled", value = "false" },
    { name = "postgresql.enabled", value = "false" },
    { name = "postgresql-ha.enabled", value = "false" },
    { name = "persistence.enabled", value = "false" },
    { name = "gitea.config.database.DB_TYPE", value = "sqlite3" },
    { name = "gitea.config.session.PROVIDER", value = "memory" },
    { name = "gitea.config.cache.ADAPTER", value = "memory" },
    { name = "gitea.config.queue.TYPE", value = "level" }
  ]

  values = [
    yamlencode(local.helm_values)
  ]

}

resource "kubernetes_manifest" "gitea_httproute" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "gitea-route"
      namespace = "git"
    }
    spec = {
      parentRefs = [
        {
          name      = "gateway"
          namespace = "default"
        }
      ]
      hostnames = ["localhost"]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/gitea"
              }
            }
          ]
          filters = [
            {
              type = "URLRewrite"
              urlRewrite = {
                path = {
                  type               = "ReplacePrefixMatch"
                  replacePrefixMatch = "/"
                }
              }
            }
          ]
          backendRefs = [
            {
              name      = "gitea-http"
              port      = 3000
              namespace = local.gitea_namespace
            }
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.gitea]
}