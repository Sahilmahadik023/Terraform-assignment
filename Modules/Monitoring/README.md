# AWS Monitoring Terraform Module

This module provisions AWS CloudWatch resources for monitoring application infrastructure.

The module creates:

- CloudWatch Log Groups for NGINX logs
- EC2 CPU Utilization Alarm
- Application Load Balancer Unhealthy Host Alarm

The module is designed to integrate with the Compute and ALB modules.

---

## Features

- NGINX Access Log Group
- NGINX Error Log Group
- EC2 High CPU Alarm
- ALB Unhealthy Target Alarm
- Configurable CloudWatch Retention
- Standardized Resource Tagging

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.0 |
| AWS Provider | >= 5.0 |

---

## Architecture

```text
                    EC2 Instances
                           │
                           ▼
                    CPU Utilization
                           │
                           ▼
                 CloudWatch CPU Alarm

ALB
 │
 ▼
Target Group
 │
 ▼
UnHealthyHostCount
 │
 ▼
CloudWatch Alarm

NGINX
 ├── access.log
 └── error.log
         │
         ▼
 CloudWatch Log Groups
```

---

## Usage

```hcl
module "monitoring" {

  source = "../Modules/Monitoring"

  project_name = "saas"
  environment  = "production"

  asg_name = module.compute.asg_name

  alb_arn_suffix = module.alb.alb_arn_suffix

  target_group_arn_suffix = module.alb.target_group_arn_suffix
}
```

---

## Inputs

| Name | Type | Description | Required |
|--------|--------|-------------|----------|
| project_name | `string` | Project name. | Yes |
| environment | `string` | Environment name. | Yes |
| asg_name | `string` | Auto Scaling Group name. | Yes |
| alb_arn_suffix | `string` | ALB ARN suffix used by CloudWatch metrics. | Yes |
| target_group_arn_suffix | `string` | Target Group ARN suffix used by CloudWatch metrics. | Yes |

---

## CloudWatch Log Groups

The module creates the following log groups:

### NGINX Access Logs

```text
/<project_name>/<environment>/nginx/access
```

Example:

```text
/saas/production/nginx/access
```

---

### NGINX Error Logs

```text
/<project_name>/<environment>/nginx/error
```

Example:

```text
/saas/production/nginx/error
```

---

## Log Retention

Default retention:

```text
7 Days
```

Configured using:

```hcl
retention_in_days = 7
```

---

## CPU Utilization Alarm

The module creates an alarm monitoring:

```text
AWS/EC2
CPUUtilization
```

Configuration:

| Setting | Value |
|----------|---------|
| Threshold | 80% |
| Statistic | Average |
| Evaluation Periods | 2 |
| Period | 300 Seconds |

Alarm triggers when:

```text
CPU > 80%
for 10 minutes
```

---

## ALB Unhealthy Host Alarm

The module creates an alarm monitoring:

```text
AWS/ApplicationELB
UnHealthyHostCount
```

Configuration:

| Setting | Value |
|----------|---------|
| Threshold | 0 |
| Evaluation Periods | 1 |
| Period | 60 Seconds |

Alarm triggers when:

```text
Any target becomes unhealthy
```

---

## Outputs

| Name | Description |
|--------|-------------|
| nginx_access_log_group_name | NGINX Access Log Group Name |
| nginx_error_log_group_name | NGINX Error Log Group Name |
| cpu_alarm_name | CPU Alarm Name |
| unhealthy_host_alarm_name | ALB Unhealthy Host Alarm Name |

---

## Example Outputs

```hcl
output "cpu_alarm" {
  value = module.monitoring.cpu_alarm_name
}
```

```hcl
output "nginx_logs" {
  value = module.monitoring.nginx_access_log_group_name
}
```

---

## Integration Example

### Monitoring + Compute

```hcl
module "monitoring" {

  asg_name = module.compute.asg_name
}
```

---

### Monitoring + ALB

```hcl
module "monitoring" {

  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
}
```

---

## Resource Naming Convention

Resources are named using:

```text
<project_name>-<environment>-high-cpu
<project_name>-<environment>-unhealthy-hosts
```

Examples:

```text
saas-production-high-cpu
saas-production-unhealthy-hosts
```

Log Groups:

```text
/saas/production/nginx/access
/saas/production/nginx/error
```

---

## Best Practices

- Configure CloudWatch Agent on EC2 instances.
- Forward application logs to CloudWatch.
- Monitor CPU trends before scaling thresholds are reached.
- Use ALB health checks to detect unhealthy instances.
- Set appropriate log retention periods based on compliance requirements.
- Add SNS notifications for alarm actions.

---

## Future Enhancements

Consider extending the module with:

- SNS Notifications
- Memory Utilization Alarms
- Disk Utilization Alarms
- ALB 5XX Error Alarms
- Target Response Time Alarms
- CloudWatch Dashboard
- Log Metric Filters
- CloudWatch Agent Configuration

---

## Notes

- The module currently creates CloudWatch alarms only.
- SNS notifications are not configured.
- CPU alarms are based on Auto Scaling Group metrics.
- ALB alarms use ALB ARN suffix and Target Group ARN suffix outputs from the ALB module.
- NGINX logs must be forwarded to CloudWatch using the CloudWatch Agent.
