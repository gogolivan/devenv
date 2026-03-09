locals {
  argocd_namespace     = "argocd"
  argocd_chart_version = var.argocd_helm_version
}

# Install ArgoCD
# https://artifacthub.io/packages/helm/argo/argo-cd
# helm install argo-cd argo/argo-cd -n argocd --create-namespace
resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = local.argocd_chart_version
  namespace        = local.argocd_namespace
  create_namespace = true

  values = [
    yamlencode({
      server = {
        extraArgs = [
          "--insecure",
          "--rootpath=/argocd"
        ]
        resources = {
          limits = {
            cpu = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu = "50m"
            memory = "64Mi"
          }
        }
      }
      redis = {
        enabled = false
      }
      dex = {
        enabled = false
      }
      controller = {
        resources = {
          limits = {
            cpu = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu = "250m"
            memory = "256Mi"
          }
        }
      }
      repoServer = {
        resources = {
          limits = {
            cpu = "50m"
            memory = "128Mi"
          }
          requests = {
            cpu = "10m"
            memory = "64Mi"
          }
        }
      }
      applicationSet = {
        replicas = 0
      }
      notifications = {
        enabled = false
      }
    })
  ]
}


resource "kubernetes_manifest" "argocd_httproute" {
  depends_on = [ helm_release.argocd ]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "argocd-route"
      namespace = local.argocd_namespace
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
                value = "/argocd"
              }
            }
          ]
          backendRefs = [
            {
              name = "argo-cd-argocd-server"
              port = 80
              namespace : local.argocd_namespace
            }
          ]
        }
      ]
    }
  }
}