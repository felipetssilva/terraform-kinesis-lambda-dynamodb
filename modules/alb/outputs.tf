output "alb_dns_name" {
  value = aws_lb.monitoring.dns_name
}

output "alb_zone_id" {
  value = aws_lb.monitoring.zone_id
}