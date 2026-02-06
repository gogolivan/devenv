locals {
  kubernetes_dashboard_namespace = "kubernetes-dashboard"
}

# https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard
resource "helm_release" "kubernetes_dashboard" {
  name             = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  version          = lookup(var.kubernetes_dashboard_helm_versions, "kubernetes_dashboard", null)
  namespace        = local.kubernetes_dashboard_namespace
  create_namespace = true

  # Expose dashboard to HTTP
  set = [
    {
      name  = "app.ingress.enabled"
      value = "false"
    },
    {
      name  = "kong.proxy.http.enabled"
      value = "true"
    }
  ]

  set_list = [ {
    name = "api.containers.args"
    value = ["--disable-csrf-protection=true"]
  } ]
}

resource "kubernetes_service_account" "kubernetes_dashboard_admin_user" {
  metadata {
    name      = "admin-user"
    namespace = local.kubernetes_dashboard_namespace
  }

  depends_on = [helm_release.kubernetes_dashboard]
}

resource "kubernetes_cluster_role_binding" "kubernetes_dashboard_admin_user" {
  metadata {
    name = "admin-user"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "admin-user"
    namespace = local.kubernetes_dashboard_namespace
  }

  depends_on = [helm_release.kubernetes_dashboard]
}

resource "kubernetes_secret" "kubernetes_dashboard_admin_user_token" {
  metadata {
    name      = "admin-user"
    namespace = local.kubernetes_dashboard_namespace
    annotations = {
      "kubernetes.io/service-account.name" = "admin-user"
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [helm_release.kubernetes_dashboard]
}

resource "kubernetes_manifest" "kubernetes_dashboard_httproute" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "kubernetes-dashboard-route"
      namespace = local.kubernetes_dashboard_namespace
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
                value = "/kubernetes-dashboard"
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
              name = "kubernetes-dashboard-kong-proxy"
              port = 80
              namespace : local.kubernetes_dashboard_namespace
            }
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.kubernetes_dashboard]
}