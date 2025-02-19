output "route53_zone" {
    value = aws_route53_zone.main.name
}

output "route53_zone_id" {
    value = aws_route53_zone.main.zone_id
}
output "prometheus_domain" {
    value = aws_route53_record.prometheus.name  
}

output "grafana_domain" {
    value = aws_route53_record.grafana.name
  
}