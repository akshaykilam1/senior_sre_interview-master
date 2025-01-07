output "service_arn" {
  value = aws_ecs_service.this.id  # Change from `arn` to `id`
}

