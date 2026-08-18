#!/bin/bash
set -euo pipefail

# --- Docker ---
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
fi

# --- App container ---
# Only the secret ARN is passed in -- never the secret value itself.
docker run -d --name capacity-api --restart unless-stopped \
  --memory="${app_container_memory}" \
  -e AWS_ENDPOINT_URL="${aws_endpoint_url}" \
  -e DB_SECRET_ARN="${secret_arn}" \
  -p ${app_port}:3000 \
  capacity-api:latest

# --- nginx reverse proxy ---
apt-get update -y && apt-get install -y nginx
cat > /etc/nginx/sites-available/default << NGINX
upstream app_upstream {
    server 127.0.0.1:${app_port};
}
server {
    listen ${nginx_port};

    location /readyz {
        proxy_pass http://app_upstream/readyz;
        proxy_next_upstream error timeout http_502 http_503;
    }
    location /healthz {
        proxy_pass http://app_upstream/healthz;
    }
    location / {
        proxy_pass http://app_upstream;
        # Don't route real traffic to an instance whose /readyz is failing.
        proxy_next_upstream error timeout http_503;
    }
}
NGINX
systemctl restart nginx
