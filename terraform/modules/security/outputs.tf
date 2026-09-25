output "lb_security_group_id" {
  description = "Security group ID for the load balancer tier."
  value       = aws_security_group.lb.id
}

output "app_security_group_id" {
  description = "Security group ID for the application tier."
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Security group ID for the database tier."
  value       = aws_security_group.db.id
}
