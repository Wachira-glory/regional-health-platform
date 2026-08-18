output "instance_id" {
  value = aws_instance.app.id
}
output "public_ip" {
  value = aws_instance.app.public_ip
}
output "nginx_port" {
  value = var.nginx_port
}
