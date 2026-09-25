output "account_id" {
  description = "Account Terraform is talking to. Must be 000000000000 (LocalStack)."
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "Region the provider is configured for."
  value       = data.aws_region.current.region
}

output "availability_zones" {
  description = "Availability zones reported by LocalStack."
  value       = data.aws_availability_zones.available.names
}

output "name_prefix" {
  description = "Prefix used for resource names."
  value       = local.name_prefix
}
# ---- Networking (Phase 4) ---------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.networking.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs per tier."
  value = {
    public = module.networking.public_subnet_ids
    app    = module.networking.app_subnet_ids
    db     = module.networking.db_subnet_ids
  }
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway."
  value       = module.networking.nat_gateway_id
}
