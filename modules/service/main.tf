# =============================================================================
# modules/service — EC2 + nginx + user-data + health wiring   (GROUP-OWNED: you build this)
#
# Stand up a Docker-backed EC2 instance running nginx in front of the app.
# nginx routes real traffic and uses /readyz for upstream health -- a
# not-ready instance receives no traffic. user-data reads DB creds from
# Secrets Manager at boot: the SECRET ARN and endpoint only, never the value.
#
# Expected inputs (variables.tf):
#   ami_id (built + tagged by CI as localstack-ec2/app:ami-<sha12>),
#   instance_type (default "t3.small"), secret_arn (from modules/data),
#   db_endpoint, db_port (from modules/data), app_container_memory (default "512m")
#
# Expected outputs (outputs.tf -- your individual root depends on these):
#   instance_id, public_ip (or the LocalStack-reachable address), nginx_port
# =============================================================================

# TODO: resource "aws_instance" "app" -- ami = var.ami_id, instance_type,
#   user_data = templatefile(...) rendering the secret ARN + db endpoint in,
#   NEVER the secret value itself.

# TODO: user-data script (separate file, e.g. user-data.sh.tpl) that:
#   - installs/starts Docker if not already on the AMI
#   - runs the app container with --memory=${app_container_memory}
#     and env vars pointing at AWS_ENDPOINT_URL, DB_SECRET_ARN (NOT password)
#   - installs/configures nginx as a reverse proxy in front of the app,
#     using /readyz as the upstream health check path

# TODO: resource "aws_security_group" "app" -- ingress for nginx's port,
#   egress open. Remember: LocalStack only applies SG rules at instance
#   creation -- modifying a running instance's SG does nothing. Note this
#   in FIDELITY.md.

# TODO (optional but graded as IaC): resource "aws_lb" "app" + listener/target
#   group -- written and scanned, but NOT used for real traffic (nginx carries
#   that). See ASSIGNMENT.md "Why nginx and not an ALB."
