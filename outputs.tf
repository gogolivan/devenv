output "kyverno" {
  description = "Kyverno module output"
  value       = module.kyverno
}

output "headlamp" {
  description = "Kubernetes UI"
  value       = module.headlamp
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