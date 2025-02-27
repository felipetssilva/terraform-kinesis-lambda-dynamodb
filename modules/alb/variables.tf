variable "prometheus_domain" {
  type = string
  default = "prometheus.python-app.com"
}

variable "grafana_domain" {
  type = string
  default = "grafana.python-app.com"
}

variable "vpc_id" {
  type = string
}
variable "subnets" {
  type = list(string)
}