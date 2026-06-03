# AWS Security Group Terraform Module

This module creates reusable AWS Security Groups with configurable ingress and egress rules.

The module supports:

- CIDR-based access rules
- Security Group based access rules
- Dynamic ingress and egress rules
- Standardized resource tagging
- Reusable across ALB, EC2, RDS, EKS, and other workloads

---

## Features

- Create a single Security Group.
- Support multiple ingress rules.
- Support multiple egress rules.
- Allow traffic from CIDR blocks.
- Allow traffic from other Security Groups.
- Default outbound access to the internet.
- Consistent tagging strategy.

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.0 |
| AWS Provider | >= 5.0 |

---

## Usage

### ALB Security Group

```hcl
module "alb_sg" {
  source = "../Modules/Security"

  project_name = "saas"
  environment  = "production"

  name        = "alb"
  description = "ALB Security Group"

  vpc_id = module.network.vpc_id

  ingress_rules = [
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

---

### Application Security Group

```hcl
module "app_sg" {
  source = "../Modules/Security"

  project_name = "saas"
  environment  = "production"

  name        = "app"
  description = "Application Security Group"

  vpc_id = module.network.vpc_id

  ingress_rules = [
    {
      description     = "HTTP from ALB"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.alb_sg.sg_id]
    }
  ]
}
```

---

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| project_name | `string` | Project name. | Yes |
| environment | `string` | Environment name. | Yes |
| name | `string` | Security Group identifier (alb, app, rds, bastion, etc.). | Yes |
| vpc_id | `string` | VPC ID where the Security Group will be created. | Yes |
| description | `string` | Security Group description. | No |
| ingress_rules | `list(object)` | List of ingress rules. | No |
| egress_rules | `list(object)` | List of egress rules. | No |
| common_tags | `map(string)` | Additional tags to apply. | No |

---

## ingress_rules Structure

```hcl
list(object({
  description     = string
  from_port       = number
  to_port         = number
  protocol        = string
  cidr_blocks     = optional(list(string))
  security_groups = optional(list(string))
}))
```

### Example

```hcl
ingress_rules = [
  {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
```

---

## Security Group Reference Example

```hcl
ingress_rules = [
  {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb_sg.sg_id]
  }
]
```

---

## Default Egress Rule

If no egress rules are specified, the module creates:

```hcl
[
  {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
```

This allows outbound traffic to any destination.

---

## Outputs

| Name | Description |
|------|-------------|
| sg_id | Security Group ID |
| sg_name | Security Group Name |

### Example

```hcl
output "alb_sg_id" {
  value = module.alb_sg.sg_id
}
```

---

## Resource Naming Convention

Resources are named using:

```text
<project_name>-<environment>-<name>-sg
```

Example:

```text
saas-production-alb-sg
saas-production-app-sg
saas-production-rds-sg
```

---

## Best Practices

- Restrict inbound access to only required ports.
- Use Security Group references instead of CIDR blocks for internal communication.
- Avoid opening SSH (22) to the internet.
- Apply the principle of least privilege.
- Use separate Security Groups for ALB, EC2, RDS, and other services.
- Keep outbound rules restricted where possible.

---

## Example Architecture

```text
Internet
    |
    ▼
ALB Security Group
    |
    ▼
Application Security Group

```
