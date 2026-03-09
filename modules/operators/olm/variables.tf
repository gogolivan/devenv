variable "environment" {
    type = string
    description = "The target deployment environment"

    default = "local"

    validation {
      condition = contains(["local"], var.environment)
      error_message = "The environment must be one of: local"
    }
}