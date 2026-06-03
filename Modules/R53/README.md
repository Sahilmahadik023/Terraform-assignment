# AWS Route53 Terraform Module

This module manages Route53 DNS records and integrates with an AWS Application Load Balancer (ALB).

The module:

- Retrieves an existing Route53 Hosted Zone
- Creates an Alias A Record
- Maps a domain/subdomain to an ALB
- Supports custom application subdomains

---

## Features

- Route53 Hosted Zone Lookup
- Alias A Record Creation
- ALB Integration
- Automatic DNS Resolution
- Standardized Resource Tagging

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.0 |
| AWS Provider | >= 5.0 |

---

## Architecture

```text
Internet
    │
    ▼
app.example.com
    │
    ▼
Route53 Alias Record
    │
    ▼
Application Load Balancer
    │
    ▼
EC2 / Auto Scaling Group
```

---

## Usage

### Root Domain

```hcl
module "route53" {

  source = "../Modules/Route53"

  project_name = "saas"
  environment  = "production"

  domain_name = "example.com"
  record_name = "example.com"

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}
```

---

### Subdomain

```hcl
module "route53" {

  source = "../Modules/Route53"

  project_name = "saas"
  environment  = "production"

  domain_name = "example.com"
  record_name = "app.example.com"

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}
```

---

## Inputs

| Name | Type | Description | Required |
|--------|--------|-------------|----------|
| project_name | `string` | Project name. | Yes |
| environment | `string` | Environment name. | Yes |
| domain_name | `string` | Route53 Hosted Zone name. | Yes |
| record_name | `string` | DNS record name to create. | Yes |
| alb_dns_name | `string` | DNS name of the ALB. | Yes |
| alb_zone_id | `string` | Hosted Zone ID of the ALB. | Yes |

---

## Example

### Domain

```hcl
domain_name = "example.com"
```

### Record

```hcl
record_name = "app.example.com"
```

Result:

```text
app.example.com
        │
        ▼
Application Load Balancer
```

---

## Route53 Alias Record

The module creates:

```hcl
resource "aws_route53_record" "app" {

  type = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
```

Benefits:

- No additional DNS lookup charges
- Automatic ALB IP updates
- Native AWS integration
- Health-aware routing

---

## Outputs

| Name | Description |
|--------|-------------|
| hosted_zone_id | Route53 Hosted Zone ID |

---

## Example Outputs

```hcl
output "hosted_zone_id" {
  value = module.route53.hosted_zone_id
}
```

---

## Integration Example

### Route53 + ALB

```hcl
module "route53" {

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}
```

---

### Route53 + ACM

```hcl
module "acm" {

  domain_name = var.domain_name

  zone_id = module.route53.hosted_zone_id
}
```

---

## Resource Naming Convention

Example:

```text
Hosted Zone:
example.com

Record:
app.example.com
```

---

## DNS Flow

```text
User Request
      │
      ▼
app.example.com
      │
      ▼
Route53 Alias Record
      │
      ▼
Application Load Balancer
      │
      ▼
Application Servers
```

---

## Best Practices

- Use Alias records for AWS resources.
- Use meaningful subdomain names.
- Keep Route53 records managed by Terraform.
- Use ACM certificates for HTTPS.
- Enable ALB health checks.
- Use Route53 Alias records instead of CNAME records for AWS Load Balancers.

---

## Notes

- The Hosted Zone must already exist.
- The module does not create a Hosted Zone.
- The ALB must be created before this module runs.
- Alias records automatically track ALB IP address changes.
- `evaluate_target_health = true` allows Route53 to consider ALB health status.
- Works with both root domains and subdomains.

Examples:

```text
example.com
app.example.com
api.example.com
admin.example.com
```
