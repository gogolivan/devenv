variable "gitea_helm_version" {
  description = "Version of the Gitea Helm chart to deploy"
  type        = string
  default     = "12.4.0"
}

variable "gitea_server_config" {
  description = "Gitea server configuration"
  type = object({
    DOMAIN   = string
    ROOT_URL = string
  })
  default = {
    DOMAIN   = "localhost"
    ROOT_URL = "http://localhost/gitea/"
  }
}

variable "gitea_resources" {
  description = <<EOT
    Gitea container resource requests and limits.
    The environment variable GOMAXPROCS is set automatically when a CPU limit is defined.
    Required for GitDevOps systems like ArgoCD/Flux to avoid diff errors.
    EOT

  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })

  default = {
    limits = {
      cpu    = "1000m"
      memory = "512Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "512Mi"
    }
  }
}
