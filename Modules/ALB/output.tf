output "alb_arn" {
  value = aws_lb.Production.arn
}

output "alb_dns_name" {
  value = aws_lb.Production.dns_name
}

output "alb_zone_id" {
  value = aws_lb.Production.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.Production.arn
}

output "target_group_name" {
  value = aws_lb_target_group.Production.name
}

output "listener_arn" {
  value = aws_lb_listener.https.arn
  
}


output "alb_arn_suffix" {
  value = aws_lb.Production.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.Production.arn_suffix
}