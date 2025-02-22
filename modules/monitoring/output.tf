output "prometheus_service_name" {
  value = aws_ecs_service.prometheus_service.name
}

output "grafana_service_name" {
  value = aws_ecs_service.grafana_service.name
}

output "aws_ecs_task_definition" {
  value = aws_ecs_task_definition.grafana.arn
  
}