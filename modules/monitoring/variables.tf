variable "prometheus_image" {
  default = "ozoski/custom-prometheus:latest"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "grafana_image" {
  default = "grafana/grafana:latest"
}

variable "grafana_admin_password" {
  default = "admin"
}

variable "ecs_cluster_id" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}