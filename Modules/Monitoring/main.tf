
# CloudWatch Log Groups

resource "aws_cloudwatch_log_group" "nginx_access" {

  name              = "/${var.project_name}/${var.environment}/nginx/access"
  retention_in_days = var.  retention_in_days

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nginx-access"
    }
  )
}

resource "aws_cloudwatch_log_group" "nginx_error" {

  name              = "/${var.project_name}/${var.environment}/nginx/error"
  retention_in_days =  var.  retention_in_days

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nginx-error"
    }
  )
}


# High CPU Alarm


resource "aws_cloudwatch_metric_alarm" "high_cpu" {

  alarm_name          = "${var.project_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"

  period    = 300
  statistic = "Average"

  threshold = var.threshold

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_description = "Alarm when CPU exceeds 80%"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-cpu-alarm"
    }
  )
}

# Unhealthy Host Alarm


resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {

  alarm_name          = "${var.project_name}-${var.environment}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1

  metric_name = "UnHealthyHostCount"
  namespace   = "AWS/ApplicationELB"

  period    = 60
  statistic = "Average"

  threshold = 0

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_description = "Alarm when target becomes unhealthy"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-unhealthy-hosts"
    }
  )
}