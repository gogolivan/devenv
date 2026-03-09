# Create a Service Account for Headlamp admin
resource "kubernetes_service_account_v1" "headlamp_admin" {
  metadata {
    name      = "headlamp-admin"
    namespace = "kube-system"
  }
}

# Manually define a Secret to hold the token for the Service Account
resource "kubernetes_secret_v1" "headlamp_admin_token" {
  depends_on = [ kubernetes_service_account_v1.headlamp_admin ]
  
  metadata {
    name      = "headlamp-admin-token"
    namespace = "kube-system"
    annotations = {
      # Link the secret to the Headlamp Service Account 
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.headlamp_admin.metadata[0].name
    }
  }
  
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

# Bind the Service Account to the 'cluster-admin' role for full cluster access
resource "kubernetes_cluster_role_binding_v1" "headlamp_admin" {
  depends_on = [ kubernetes_service_account_v1.headlamp_admin ]

  metadata {
    name = "headlamp-admin-binding"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.headlamp_admin.metadata[0].name
    namespace = "kube-system"
  }
}

# https://artifacthub.io/packages/helm/headlamp/headlamp
resource "helm_release" "headlamp" {
  depends_on = [ kubernetes_cluster_role_binding_v1.headlamp_admin ]

  name             = "headlamp"
  repository       = "https://kubernetes-sigs.github.io/headlamp/"
  chart            = "headlamp"
  namespace        = "kube-system"
  version          = var.headlamp_helm_version

  values = [
    yamlencode({
      resources = {
        limits = {
          memory = "64Mi"
        }
        requests = {
          memory = "32Mi"
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "headlamp_httproute" {
  depends_on = [helm_release.headlamp]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "headlamp-route"
      namespace = "kube-system"
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
                value = "/headlamp"
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
              name = "headlamp"
              port = 80
              namespace = "kube-system"
            }
          ]
        }
      ]
    }
  }
}