output "operators" {
  description = "Operators module output"
  value       = module.operators
}

output "management" {
  description = "Management module output"
  value       = module.management
  sensitive = true
}

output "networking" {
  description = "Networking module output"
  value = module.networking
}

output "gitops" {
  description = "GitOps module output"
  value       = module.gitops
}

output "observability" {
  description = "Observability module output"
  value = module.observability
}

output "security" {
  description = "Security module output"
  value = module.observability
}