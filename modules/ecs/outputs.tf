output "ecs_cluster_id" {
  value = aws_ecs_cluster.data-cluster.id
}

output "app_service_name" {
  value = aws_ecs_service.app_service.name
}

output "ecs_security_group" {
  value = aws_security_group.ecs_sg.id
}