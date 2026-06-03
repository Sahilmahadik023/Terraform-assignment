module "network" {
  source       = "../Modules/Network"
  project_name = var.project_name

  environment = var.environment

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  public_routes   = []
  private_routes  = []
}

module "alb_sg" {
  source = "../Modules/Security"

  project_name  = var.project_name
  environment   = var.environment
  name          = "alb"
  description   = "ALB Security Group"
  vpc_id        = module.network.vpc_id
  ingress_rules = var.ingress_rules_alb
  egress_rules  = var.egress_rules


}

module "app_sg" {
  source       = "../Modules/Security"
  project_name = var.project_name
  environment  = var.environment
  name         = "app"
  description  = "Application Security Group"
  vpc_id       = module.network.vpc_id

  ingress_rules = [
    {
      description     = "HTTP from ALB"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.alb_sg.sg_id]
    }
  ]

  egress_rules = var.egress_rules
  depends_on = [
    module.alb_sg
  ]
}

module "alb" {

  source       = "../Modules/ALB"
  project_name = var.project_name

  environment = var.environment

  vpc_id = module.network.vpc_id


  subnet_ids = values(module.network.public_subnet_ids)


  security_group_id = module.alb_sg.sg_id

  certificate_arn = module.acm.certificate_arn
}

module "compute" {

  source = "../Modules/Compute"

  project_name = var.project_name
  environment  = var.environment

  ami_id        = var.ami_id
  instance_type = var.instance_type

  security_group_id = module.app_sg.sg_id

  private_subnet_ids = values(module.network.private_subnet_ids)

  min_size = var.min_size

  max_size = var.max_size

  desired_capacity = var.  desired_capacity 

  target_group_arn = module.alb.target_group_arn
  
  common_tags = local.common_tags

  managed_policy_arns = var.managed_policy_arns
  custom_policies     = var.custom_policies
  service_principal   = var.service_principal



}


module "monitoring" {

  source = "../Modules/Monitoring"

  project_name = var.project_name
  environment  = var.environment

  asg_name = module.compute.asg_name

  alb_arn_suffix = module.alb.alb_arn_suffix

  target_group_arn_suffix = module.alb.target_group_arn_suffix
  retention_in_days = var.retention_in_days
  threshold = var.threshold

}


module "acm" {
  source      = "../Modules/ACM"
  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.domain_name
  zone_id      = module.r53.hosted_zone_id          # from R53 output
  subject_alternative_names = ["sahil.shreesamarthfiber.in"]
}

module "r53" {
  project_name = var.project_name
  environment = var.environment
  source       = "../Modules/R53"
  domain_name  = var.domain_name
  record_name  = var.record_name
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}