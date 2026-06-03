output "nginx_access_log_group_name" {
  description = "Nginx Access Log Group"
  value       = aws_cloudwatch_log_group.nginx_access.name
}

output "nginx_error_log_group_name" {
  description = "Nginx Error Log Group"
  value       = aws_cloudwatch_log_group.nginx_error.name
}

output "cpu_alarm_name" {
  description = "CPU Alarm Name"
  value       = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "unhealthy_host_alarm_name" {
  description = "Unhealthy Host Alarm Name"
  value       = aws_cloudwatch_metric_alarm.unhealthy_hosts.alarm_name
}