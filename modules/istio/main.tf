locals {
  istio_system_namespace = "istio-system"
}

# Install Istio Base
# https://artifacthub.io/packages/helm/istio-official/base
# helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = local.istio_system_namespace
  create_namespace = true

  version = lookup(var.istio_helm_charts_version, "istio_base", null)

  set = [{
    name  = "defaultRevision"
    value = "default"
  }]
}

# Install istiod
# https://artifacthub.io/packages/helm/istio-official/istiod
# helm install istiod istio/istiod -n istio-system --wait
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = local.istio_system_namespace
  wait       = true

  version = lookup(var.istio_helm_charts_version, "istiod", null)

  set = [{
    name  = "telemetry.enabled"
    value = "false"
  }]

  depends_on = [helm_release.istio_base]
}

# Install Kiali Server
# For production check https://kiali.io/docs/installation/installation-guide/install-with-helm/#install-with-operator
resource "helm_release" "kiali_server" {
  name       = "kiali-server"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = local.istio_system_namespace

  version = lookup(var.istio_helm_charts_version, "kiali_server", null)

  set = [{
    name  = "auth.strategy"
    value = "anonymous"
  }]

  depends_on = [helm_release.istiod]
}

resource "kubernetes_manifest" "kiali_httproute" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "kiali-route"
      namespace = local.istio_system_namespace
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
                value = "/kiali"
              }
            }
          ]
          backendRefs = [
            {
              name = "kiali"
              port = 20001
            }
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.istio_base]
}