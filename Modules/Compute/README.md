# AWS Compute Terraform Module

This module provisions a highly available compute layer using:

- IAM Role
- IAM Instance Profile
- EC2 Launch Template
- Auto Scaling Group (ASG)
- ALB Target Group Integration
- Encrypted EBS Root Volume

The module is designed to host application workloads in private subnets behind an Application Load Balancer.

---

## Features

- EC2 Auto Scaling Group
- Launch Template based deployment
- IAM Role & Instance Profile creation
- Support for AWS managed policies
- Support for custom IAM policies
- Encrypted EBS volumes (gp3)
- Target Group registration
- Multi-AZ deployment
- User Data bootstrap support

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.0 |
| AWS Provider | >= 5.0 |

---

## Architecture

```text
                    ALB
                     │
                     ▼
              Target Group
                     │
                     ▼
            Auto Scaling Group
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
      EC2 Instance          EC2 Instance
         │                       │
         └───────────┬───────────┘
                     ▼
              IAM Role/Profile
```

---

## Usage

```hcl
module "compute" {

  source = "../Modules/Compute"

  project_name = "saas"
  environment  = "production"

  ami_id        = "ami-xxxxxxxx"
  instance_type = "t3.medium"

  private_subnet_ids = values(module.network.private_subnet_ids)

  security_group_id = module.app_sg.sg_id

  target_group_arn = module.alb.target_group_arn

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  common_tags = {
    Project     = "saas"
    Environment = "production"
  }
}
```

---

## Inputs

| Name | Type | Description | Required |
|--------|--------|-------------|----------|
| project_name | `string` | Project name. | Yes |
| environment | `string` | Environment name. | Yes |
| ami_id | `string` | EC2 AMI ID. | Yes |
| instance_type | `string` | EC2 instance type. | Yes |
| private_subnet_ids | `list(string)` | Private subnet IDs used by ASG. | Yes |
| security_group_id | `string` | Security Group attached to EC2 instances. | Yes |
| target_group_arn | `string` | ALB Target Group ARN. | Yes |
| common_tags | `map(string)` | Common resource tags. | Yes |
| service_principal | `string` | IAM trust relationship service principal. | No |
| managed_policy_arns | `list(string)` | AWS Managed IAM Policies. | No |
| custom_policies | `map(string)` | Custom IAM policies. | No |

---

## IAM Role Example

### Managed Policies

```hcl
managed_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
]
```

---

### Custom Policy Example

```hcl
custom_policies = {

  s3-access = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "*"
      }
    ]
  })
}
```

---

## Auto Scaling Configuration

Current configuration:

| Setting | Value |
|----------|---------|
| Min Capacity | 2 |
| Desired Capacity | 2 |
| Max Capacity | 4 |
| Health Check Type | ELB |
| Grace Period | 300 Seconds |

---

## Launch Template Configuration

| Setting | Value |
|----------|---------|
| Root Volume Type | gp3 |
| Root Volume Size | 20 GB |
| Encryption | Enabled |
| Delete On Termination | Enabled |

---

## User Data

The module executes:

```text
userdata.sh
```

during instance launch.

Variables passed:

```hcl
project_name
environment
```

Example:

```bash
#!/bin/bash

yum update -y
```

---

## Outputs

| Name | Description |
|--------|-------------|
| role_name | IAM Role Name |
| role_arn | IAM Role ARN |
| asg_name | Auto Scaling Group Name |
| launch_template_id | Launch Template ID |

---

## Example Outputs

```hcl
output "asg_name" {
  value = module.compute.asg_name
}
```

---

## Integration Example

### Compute + ALB

```hcl
module "compute" {

  target_group_arn = module.alb.target_group_arn
}
```

---

### Compute + Network

```hcl
module "compute" {

  private_subnet_ids = values(
    module.network.private_subnet_ids
  )
}
```

---

### Compute + Security Group

```hcl
module "compute" {

  security_group_id = module.app_sg.sg_id
}
```

---

## Resource Naming Convention

Resources are named using:

```text
<project_name>-<environment>-role
<project_name>-<environment>-profile
<project_name>-<environment>-asg
<project_name>-<environment>-app
```

Example:

```text
saas-production-role
saas-production-profile
saas-production-asg
saas-production-app
```

---

## Best Practices

- Deploy instances in private subnets.
- Use ALB Target Groups instead of direct internet access.
- Use SSM instead of SSH access.
- Encrypt all EBS volumes.
- Attach only required IAM permissions.
- Store AMI IDs in SSM Parameter Store.
- Enable detailed monitoring and CloudWatch Agent.

---

## Notes

- Instances are automatically registered with the Target Group.
- Root EBS volume is encrypted.
- IAM Role and Instance Profile are created automatically.
- Auto Scaling Group spans multiple private subnets.
- User data script must exist in the module directory.
- ALB health checks determine instance health.
