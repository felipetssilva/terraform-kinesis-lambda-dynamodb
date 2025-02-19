variable "prometheus_image" {
  default = "prom/prometheus:latest"
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