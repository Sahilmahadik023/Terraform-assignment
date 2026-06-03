variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_principal" {
  type    = string
  default = "ec2.amazonaws.com"
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "custom_policies" {
  description = "Map of custom IAM policies"
  type        = map(string)
  default     = {}
}



variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "common_tags" {
  type = map(string)

}

variable "min_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number
}

variable "cpu_target_value" {
  type    = number
  default = 70
}