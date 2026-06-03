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
    cidr = string
    az   = string
    role = string
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
  description = "Create NAT Gateway"
  type        = bool
  default     = true
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

