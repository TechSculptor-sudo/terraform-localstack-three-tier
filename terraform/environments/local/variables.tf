variable "project_name" {
  description = "Short name used as a prefix for every resource."
  type        = string
  default     = "three-tier"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_name))
    error_message = "project_name must be 3-21 chars: lowercase letters, digits and hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment. This root module is for LocalStack only."
  type        = string
  default     = "local"

  validation {
    condition     = var.environment == "local"
    error_message = "environments/local only supports environment = \"local\". Real AWS gets its own environment folder later."
  }
}

variable "region" {
  description = "AWS region name. LocalStack accepts any valid region; nothing is deployed there."
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "LocalStack edge endpoint. Validated so it can only be this machine."
  type        = string
  default     = "http://localhost:4566"

  validation {
    condition     = can(regex("^http://(localhost|127\\.0\\.0\\.1):4566$", var.localstack_endpoint))
    error_message = "localstack_endpoint must be http://localhost:4566 or http://127.0.0.1:4566. Refusing to use any other endpoint."
  }
}