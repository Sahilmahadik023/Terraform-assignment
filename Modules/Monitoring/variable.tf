variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group Name"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN Suffix"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target Group ARN Suffix"
  type        = string
}

variable "retention_in_days" {
  type = number
}

variable "threshold" {
  type = number
}