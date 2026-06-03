variable "region" {
  type = string
}


variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  description = "Public subnets configuration"

  type = map(object({
    cidr       = string
    az         = string
    role       = string
    create_nat = bool



  }))
}

variable "private_subnets" {
  description = "Private subnets configuration"

  type = map(object({
    cidr = string
    az   = string
    role = string

  }))
}

variable "create_nat_gateway" {
  type    = bool
  default = true
}


variable "public_routes" {
  description = "List of additional routes for the public route table"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    vpc_peering_connection_id = optional(string)
    transit_gateway_id        = optional(string)
  }))
  default = []
}

variable "private_routes" {
  description = "List of additional routes for the private route table"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    vpc_peering_connection_id = optional(string)
    transit_gateway_id        = optional(string)
  }))
  default = []
}



variable "ingress_rules_alb" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "egress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  # sensible default — allow all outbound
  default = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
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

variable "domain_name" {
  type = string
}

variable "record_name" {
  type = string
}

variable "subject_alternative_names" {
  type    = list(string)
  default = []
}

variable "retention_in_days" {
  type = number
}

variable "threshold" {
  type = number
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

