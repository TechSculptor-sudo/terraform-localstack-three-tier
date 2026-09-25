output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs, in availability_zones order."
  value       = [for az in var.availability_zones : aws_subnet.public[az].id]
}

output "app_subnet_ids" {
  description = "Application subnet IDs, in availability_zones order."
  value       = [for az in var.availability_zones : aws_subnet.app[az].id]
}

output "db_subnet_ids" {
  description = "Database subnet IDs, in availability_zones order."
  value       = [for az in var.availability_zones : aws_subnet.db[az].id]
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway, or null when disabled."
  value       = one(aws_nat_gateway.this[*].id)
}