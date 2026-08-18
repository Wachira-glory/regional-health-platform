variable "secret_name" {
  description = "Name of the Secrets Manager secret holding DB credentials"
  type        = string
  default     = "regional-health/db"
}

variable "db_engine" {
  description = "Database engine identifier stored in the secret envelope"
  type        = string
  default     = "mysql"
}

variable "db_host" {
  description = "Aiven MySQL host (managed outside Terraform -- Aiven isn't an AWS resource)"
  type        = string
}

variable "db_port" {
  description = "Aiven MySQL port"
  type        = number
  default     = 3306
}

variable "db_username" {
  description = "Aiven MySQL username"
  type        = string
  default     = "avnadmin"
}

variable "db_password" {
  description = "Aiven MySQL password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name inside the Aiven MySQL instance"
  type        = string
  default     = "capacity_lab"
}
