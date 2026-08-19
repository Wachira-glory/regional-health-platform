# =============================================================================
# modules/service -- EC2 + nginx + health-based routing   (GROUP-OWNED)
#
# Docker-backed EC2 instance running the app + nginx as a reverse proxy.
# nginx checks /readyz on the upstream so a DB-unreachable instance stops
# receiving traffic automatically. aws_lb below is written/scanned for IaC
# completeness but not used for real traffic -- LocalStack's ELBv2 health
# checking is undocumented/unreliable (see FIDELITY.md); nginx carries the
# actual routing decision instead.
# =============================================================================

resource "aws_security_group" "app" {
  name_prefix = "regional-health-app-"
  description = "Allow inbound HTTP to nginx"

  ingress {
    from_port   = var.nginx_port
    to_port     = var.nginx_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_egress_cidrs
  }
}

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app.id]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  user_data = templatefile("${path.module}/user-data.sh.tpl", {
    secret_arn           = var.secret_arn
    aws_endpoint_url     = "http://localhost.localstack.cloud:4566"
    app_container_memory = var.app_container_memory
    app_port             = var.app_port
    nginx_port           = var.nginx_port
  })

  tags = {
    Name = "regional-health-app"
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Written for IaC completeness / trivy scanning -- not used for live traffic.
# count toggle: LocalStack's freemium license doesn't include elbv2
# (confirmed: DescribeLoadBalancers -> 501 InternalFailure). Real AWS or a
# paid LocalStack license would create this. See FIDELITY.md.
resource "aws_lb" "app" {
  count              = var.create_lb ? 1 : 0
  name               = "regional-health-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app.id]
  subnets            = data.aws_subnets.default.ids
}
