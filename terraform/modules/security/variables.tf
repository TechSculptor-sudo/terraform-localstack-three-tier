variable "name_prefix" {
  description = "Prefix for resource Name tags, e.g. \"three-tier-local\"."
  type        = string
}

variable "vpc_id" {
  description = "VPC the security groups belong to (from the networking module)."
  type        = string
}

variable "load_balancer_port" {
  description = "Port the load balancer listens on for client traffic."
  type        = number
  default     = 80
}

variable "load_balancer_allowed_cidrs" {
  description = "Client IP ranges allowed to reach the load balancer. 0.0.0.0/0 = the whole internet."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for c in var.load_balancer_allowed_cidrs : can(cidrhost(c, 0))])
    error_message = "Every entry in load_balancer_allowed_cidrs must be a valid IPv4 CIDR block."
  }
}

variable "application_port" {
  description = "Port the application listens on."
  type        = number

  validation {
    condition     = var.application_port >= 1024 && var.application_port <= 65535
    error_message = "application_port must be between 1024 and 65535 (non-privileged)."
  }
}

variable "database_port" {
  description = "Port the database listens on."
  type        = number

  validation {
    condition     = var.database_port >= 1024 && var.database_port <= 65535
    error_message = "database_port must be between 1024 and 65535."
  }
}