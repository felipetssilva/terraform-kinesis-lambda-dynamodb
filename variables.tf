variable "aws_region" {
  default = "us-east-1"
}
variable "environment" {
  description = "Environment name we are building"
  default     = "realtime_data"
}

variable "lambda_filename" {
  description = "Filename of the lambda code"
  default     = "realtime_data_consume"
}

variable "prometheus_domain" {
  type        = string
  description = "Domain name for Prometheus"
}

variable "grafana_domain" {
  type        = string
  description = "Domain name for Grafana"
}