variable "ami_id" {
  description = "AMI for the app instance"
  type        = string
  default     = "ami-df5de72bdb3b"
}
variable "instance_type" {
  type    = string
  default = "t3.small"
}
variable "secret_arn" {
  description = "Secrets Manager ARN from modules/data"
  type        = string
}
variable "app_container_memory" {
  type    = string
  default = "512m"
}
variable "app_port" {
  type    = number
  default = 3000
}
variable "nginx_port" {
  type    = number
  default = 80
}

variable "create_lb" {
  description = "Create the ALB. Default false: LocalStack freemium license doesn't support elbv2 (see FIDELITY.md)."
  type        = bool
  default     = false
}
variable "allowed_ingress_cidrs" {
  description = "CIDR blocks allowed to reach nginx. Callers must explicitly choose the trusted network range."
  type        = list(string)

  validation {
    condition     = length(var.allowed_ingress_cidrs) > 0
    error_message = "allowed_ingress_cidrs must contain at least one CIDR block."
  }
}

variable "allowed_egress_cidrs" {
  description = "CIDR blocks the service is allowed to reach for outbound traffic."
  type        = list(string)

  validation {
    condition     = length(var.allowed_egress_cidrs) > 0
    error_message = "allowed_egress_cidrs must contain at least one CIDR block."
  }
}
