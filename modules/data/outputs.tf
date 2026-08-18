output "db_endpoint" {
  description = "Aiven MySQL host"
  value       = var.db_host
}

output "db_port" {
  description = "Aiven MySQL port"
  value       = var.db_port
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret holding DB credentials"
  value       = aws_secretsmanager_secret.db.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db.name
}
