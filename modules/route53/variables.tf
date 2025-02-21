
variable "route53_zone" {
    type = string
    default = "aws_route53_zone.main.name"
}

variable "route53_zone_id" {
    type = string
    default = "aws_route53_zone.main.zone_id"
}
variable "prometheus_domain" {
    type = string
    default = "aws_route53_record.prometheus.name"
}

variable "grafana_domain" {
    type = string
    default = "aws_route53_record.grafana.name"
  
}