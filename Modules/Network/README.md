# AWS Network Terraform Module

This module provisions the core AWS networking infrastructure required for deploying applications in a highly available environment.

## Resources Created

- VPC
- Public Subnets
- Private Subnets
- Internet Gateway
- NAT Gateway(s)
- Elastic IP(s)
- Public Route Table
- Private Route Table
- Route Table Associations

---

## Architecture

```text
                    Internet
                        |
                Internet Gateway
                        |
        --------------------------------
        |                              |
  Public Subnet-A               Public Subnet-B
        |
    NAT Gateway
        |
  Private Route Table
        |
 ----------------------------
 |                          |
Private Subnet-A      Private Subnet-B
```

---

## Features

- Creates a VPC with DNS support enabled.
- Creates multiple public and private subnets using `for_each`.
- Supports creation of NAT Gateway per public subnet using `create_nat = true`.
- Automatically creates and associates route tables.
- Supports custom public and private routes.
- Exposes subnet IDs, VPC ID, and NAT Gateway IDs through outputs.

---

## Module Usage

```hcl
module "network" {
  source = "../Modules/Network"

  project_name = "saas"
  environment  = "production"

  vpc_cidr = "10.0.0.0/16"

  public_subnets = {
    public-1 = {
      cidr       = "10.0.0.0/24"
      az         = "us-east-1a"
      role       = "alb"
      create_nat = true
    }

    public-2 = {
      cidr       = "10.0.1.0/24"
      az         = "us-east-1b"
      role       = "alb"
      create_nat = false
    }
  }

  private_subnets = {
    private-1 = {
      cidr = "10.0.3.0/24"
      az   = "us-east-1a"
      role = "application"
    }

    private-2 = {
      cidr = "10.0.4.0/24"
      az   = "us-east-1b"
      role = "application"
    }
  }

  public_routes  = []
  private_routes = []
}
```

---

## Inputs

### Required Inputs

| Name | Type | Description |
|--------|------|-------------|
| project_name | string | Project name |
| environment | string | Environment name |
| vpc_cidr | string | CIDR block for VPC |
| public_subnets | map(object) | Public subnet configuration |
| private_subnets | map(object) | Private subnet configuration |

### Public Subnet Object

```hcl
public_subnets = {
  subnet_name = {
    cidr       = string
    az         = string
    role       = string
    create_nat = bool
  }
}
```

### Private Subnet Object

```hcl
private_subnets = {
  subnet_name = {
    cidr = string
    az   = string
    role = string
  }
}
```

### Optional Inputs

| Name | Type | Default | Description |
|--------|------|---------|-------------|
| public_routes | list(object) | [] | Additional routes for public route table |
| private_routes | list(object) | [] | Additional routes for private route table |
| create_nat_gateway | bool | true | Reserved for future use |

---

## Custom Route Example

### Transit Gateway Route

```hcl
private_routes = [
  {
    cidr_block         = "172.16.0.0/16"
    transit_gateway_id = "tgw-xxxxxxxx"
  }
]
```

### VPC Peering Route

```hcl
private_routes = [
  {
    cidr_block                = "192.168.0.0/16"
    vpc_peering_connection_id = "pcx-xxxxxxxx"
  }
]
```

---

## Outputs

| Name | Description |
|--------|-------------|
| vpc_id | VPC ID |
| public_subnet_ids | Map of Public Subnet IDs |
| private_subnet_ids | Map of Private Subnet IDs |
| nat_gateway_ids | Map of NAT Gateway IDs |

### Example

```hcl
output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}
```

---

## Tags Applied

All resources are tagged with:

```hcl
{
  Project     = var.project_name
  Environment = var.environment
  ManagedBy   = "Terraform"
}
```

---

## Example tfvars

```hcl
project_name = "saas"

environment = "production"

vpc_cidr = "10.0.0.0/16"

public_subnets = {
  public-1 = {
    cidr       = "10.0.0.0/24"
    az         = "us-east-1a"
    role       = "alb"
    create_nat = true
  }

  public-2 = {
    cidr       = "10.0.1.0/24"
    az         = "us-east-1b"
    role       = "alb"
    create_nat = false
  }
}

private_subnets = {
  private-1 = {
    cidr = "10.0.3.0/24"
    az   = "us-east-1a"
    role = "application"
  }

  private-2 = {
    cidr = "10.0.4.0/24"
    az   = "us-east-1b"
    role = "application"
  }
}
```

---

## Notes

- NAT Gateway is created only for public subnets where `create_nat = true`.
- Public route table automatically contains a route to the Internet Gateway.
- Private route table automatically contains a route to the NAT Gateway.
- Route table associations are handled automatically.
- Outputs can be consumed by other modules such as ALB, Compute, EKS, RDS, etc.
- Child modules cannot directly reference outputs from other child modules; outputs must be passed through the root module.
