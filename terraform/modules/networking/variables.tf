variable "name_prefix" {
  description = "Prefix for resource Name tags, e.g. \"three-tier-local\"."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block, e.g. 10.0.0.0/16."
  }
}

variable "availability_zones" {
  description = "AZs to spread subnets across. One subnet per tier per AZ."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Use at least 2 availability zones for high availability."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnets (load balancer tier), one per AZ, same order as availability_zones."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "public_subnet_cidrs needs exactly one CIDR per availability zone."
  }
}

variable "app_subnet_cidrs" {
  description = "Private application subnets, one per AZ, same order as availability_zones."
  type        = list(string)

  validation {
    condition     = length(var.app_subnet_cidrs) == length(var.availability_zones)
    error_message = "app_subnet_cidrs needs exactly one CIDR per availability zone."
  }
}

variable "db_subnet_cidrs" {
  description = "Private database subnets, one per AZ, same order as availability_zones."
  type        = list(string)

  validation {
    condition     = length(var.db_subnet_cidrs) == length(var.availability_zones)
    error_message = "db_subnet_cidrs needs exactly one CIDR per availability zone."
  }
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway so app subnets can reach the internet outbound. Costs money on real AWS."
  type        = bool
  default     = true
}