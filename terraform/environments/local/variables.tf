# ---- General (Phase 3) ------------------------------------------------------

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

# ---- Networking (Phase 4) ---------------------------------------------------

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block, e.g. 10.0.0.0/16."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnets (load balancer tier), one per AZ."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "Private application subnets, one per AZ."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "db_subnet_cidrs" {
  description = "Private database subnets, one per AZ."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

# ---- Security (Phase 5) -----------------------------------------------------

variable "application_port" {
  description = "Port the Flask application listens on."
  type        = number
  default     = 8000

  validation {
    condition     = var.application_port >= 1024 && var.application_port <= 65535
    error_message = "application_port must be between 1024 and 65535 (non-privileged, so the app can run as non-root)."
  }
}

variable "database_port" {
  description = "Port PostgreSQL listens on."
  type        = number
  default     = 5432

  validation {
    condition     = var.database_port >= 1024 && var.database_port <= 65535
    error_message = "database_port must be between 1024 and 65535."
  }
}
