output "headlamp" {
  description = "Kubernetes UI"
  value       = module.headlamp
  sensitive = true
}

output "istio" {
  description = "Istio module output"
  value       = module.istio
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