locals {

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

}

locals {
  nat_subnets = {
    for k, v in var.public_subnets :
    k => v
    if v.create_nat
  }
}