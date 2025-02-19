output "prometheus_service_name" {
  value = aws_ecs_service.prometheus_service.name
}

output "grafana_service_name" {
  value = aws_ecs_service.grafana_service.name
}
