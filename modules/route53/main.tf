resource "aws_route53_zone" "main" {
  name = "python-app.com"
}

resource "aws_route53_record" "prometheus" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "prometheus.python-app.com"
  type    = "A"

  alias {
    name                   = var.prometheus_domain
    zone_id                = aws_route53_zone.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "grafana.python-app.com"
  type    = "A"

  alias {
    name                   = var.grafana_domain
    zone_id                = aws_route53_zone.main.zone_id
    evaluate_target_health = true
  }
}
