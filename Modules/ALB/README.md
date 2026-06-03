# ALB Module

## Overview

This Terraform module provisions an AWS Application Load Balancer (ALB) and related resources required to distribute application traffic across EC2 instances running in private subnets.

The ALB acts as the public entry point for the application and provides high availability, health checks, SSL termination, and traffic routing.

---

## Resources Created

* Application Load Balancer (ALB)
* Target Group
* HTTP Listener
* HTTPS Listener
* Listener Rules (if configured)
* Security Group Associations

---

## Features

* Internet-facing Application Load Balancer
* HTTPS support using ACM certificates
* Target Group health checks
* Multi-AZ deployment
* Integration with Auto Scaling Group
* Route53 DNS support
* Security Group based access control

---

## Architecture Flow

```text
User
 │
 ▼
Route53 DNS
 │
 ▼
Application Load Balancer
 │
 ▼
Target Group
 │
 ▼
EC2 Instances (Private Subnets)
```

---

## Inputs

| Variable          | Description               |
| ----------------- | ------------------------- |
| project_name      | Project name              |
| environment       | Environment name          |
| public_subnet_ids | Public subnet IDs for ALB |
| vpc_id            | VPC ID                    |
| certificate_arn   | ACM certificate ARN       |
| security_group_id | ALB security group ID     |

---

## Outputs

| Output           | Description             |
| ---------------- | ----------------------- |
| alb_arn          | ARN of the ALB          |
| alb_dns_name     | DNS name of the ALB     |
| target_group_arn | ARN of the target group |

---

## Dependencies

This module depends on:

* Network Module
* Security Module
* ACM Module

---

## Production Considerations

* HTTPS enabled using ACM certificate
* Health checks configured for application availability
* Multi-AZ deployment for high availability
* Compatible with Auto Scaling Group integration
* Supports Route53 DNS mapping

---

## Example Usage

```hcl
module "alb" {
  source = "./Modules/ALB"

  project_name      = "saas"
  environment       = "prod"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  certificate_arn   = module.acm.certificate_arn
  security_group_id = module.security.alb_sg_id
}
```
