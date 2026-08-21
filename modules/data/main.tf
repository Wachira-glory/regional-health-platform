terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.60"
    }
  }
}

# =============================================================================
# modules/data -- Secrets Manager envelope for Aiven MySQL credentials
#
# NOTE: originally spec'd for aws_db_instance (RDS) -- switched to Aiven
# MySQL per course update (RDS isn't on LocalStack's free Hobby tier).
# Aiven is not an AWS resource, so Terraform cannot provision the database
# itself; this module's job is purely to publish the (already-provisioned,
# externally-managed) Aiven credentials into Secrets Manager using the
# shared envelope, so the app can fetch them at boot exactly the way the
# brief describes -- no plaintext secret in git, in the image, or in any
# logged output.
# =============================================================================

resource "aws_secretsmanager_secret" "db" {
  name = var.secret_name
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    engine   = var.db_engine
    username = var.db_username
    password = var.db_password
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
  })
}
