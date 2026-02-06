# terraform output kubernetes_dashboard_token
output "kubernetes_dashboard_token" {
  description = "Kubernetes Dashboard module token output"
  value       = nonsensitive(module.kubernetes_dashboard.kubernetes_dashboard_admin_user_token_base64)
}

output "kyverno" {
  description = "Kyverno module output"
  value       = module.kyverno
}

output "istio" {
  description = "Istio module output"
  value       = module.istio
}

output "cert_manager" {
  description = "Cert manager module output"
  value       = module.cert_manager
}

output "gitea" {
  description = "Gitea module output"
  value = module.gitea
}

output "argocd" {
  description = "ArgoCD module output"
  value       = module.argocd
}

output "prometheus" {
  description = "Prometheus module output"
  value = module.prometheus
}

output "grafana" {
  description = "Grafana module output"
  value = module.grafana
}