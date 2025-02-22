resource "aws_route53_zone" "main" {
  name = "python-app.com"
}

resource "aws_route53_record" "prometheus" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.prometheus_domain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.grafana_domain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
