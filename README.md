# SaaS Production Infrastructure on AWS using Terraform

## Overview

This project provisions a highly available, secure, scalable, and production-ready AWS infrastructure using Terraform.

The infrastructure follows AWS best practices by deploying application workloads in private subnets behind an Application Load Balancer (ALB), with DNS management through Route53 and SSL termination using AWS Certificate Manager (ACM).

The deployment is designed for a SaaS application and spans two Availability Zones to provide high availability and fault tolerance.

---
## Application URL

https://sahil.shreesamarthfiber.in

# Architecture

## Components

### Networking

* VPC
* 2 Public Subnets (Multi-AZ)
* 2 Private Subnets (Multi-AZ)
* Internet Gateway
* NAT Gateway
* Public Route Table
* Private Route Table

### Security

* Dedicated Security Groups
* Least Privilege Access Model
* No Public Access to EC2 Instances
* Encrypted EBS Volumes
* IAM Roles (No Static Credentials)

### Application Layer

* Application Load Balancer (ALB)
* Auto Scaling Group (ASG)
* EC2 Instances in Private Subnets
* NGINX Web Server
* Health Checks Enabled

### DNS & SSL

* Route53 Hosted Zone
* ACM SSL Certificate
* HTTPS Listener on ALB

### Monitoring

* CloudWatch Log Groups
* CloudWatch Alarms
* CPU Utilization Monitoring
* Target Health Monitoring

### Terraform Backend

* S3 Remote State Storage
* DynamoDB State Locking

---

# Infrastructure Flow

```
User
  │
  ▼
Route53 DNS
  │
  ▼
Application Load Balancer (HTTPS)
  │
  ▼
Target Group
  │
  ▼
Auto Scaling Group
  │
  ▼
EC2 Instances (Private Subnets)
  │
  ▼
Internet Access via NAT Gateway
```

---

# Terraform Module Structure

```
modules/
│
├── network
│   ├── vpc
│   ├── subnets
│   ├── nat_gateway
│   ├── route_tables
│   └── internet_gateway
│
├── security
│   └── security_groups
│
├── alb
│   ├── load_balancer
│   ├── target_group
│   └── listeners
│
├── compute
│   ├── launch_template
│   ├── autoscaling_group
│   ├── iam_roles
│   └── ec2
│
├── acm
│   └── certificate
│
├── route53
│   └── records
│
└── monitoring
    ├── cloudwatch_logs
    └── cloudwatch_alarms
```

---

# Deployment Steps

## 1. Clone Repository

```
git clone <repository-url>
cd Terraform-assignment
```

## 2. Initialize Terraform

```
terraform init
```

## 3. Validate Configuration

```
terraform validate
```

## 4. Review Changes

```
terraform plan
```

## 5. Deploy Infrastructure

```
terraform apply
```

## 6. Destroy Infrastructure

```
terraform destroy
```

---

# Architecture Decisions

## Why Private Subnets for EC2?

Application servers are deployed in private subnets to reduce exposure to the internet and improve security.

## Why ALB?

Application Load Balancer provides:

* SSL Termination
* Health Checks
* Load Distribution
* High Availability

## Why Multi-AZ?

Deploying resources across two Availability Zones ensures:

* Fault Tolerance
* Higher Availability
* Improved Disaster Recovery

## Why NAT Gateway?

Private instances require outbound internet access for:

* OS Updates
* Package Downloads
* CloudWatch Agent Communication

while remaining inaccessible from the internet.

## Why Remote Backend?

Terraform state is stored in:

* S3 Bucket
* DynamoDB Lock Table

### Benefits

* Team Collaboration
* State Consistency
* State Locking
* Disaster Recovery

---

# Security Measures

## Network Security

* Security Groups enforce least privilege access.
* Only ALB accepts public traffic.
* EC2 instances are not publicly accessible.

## Data Security

* EBS volumes encrypted.
* ACM-managed SSL certificate.
* HTTPS enabled on ALB.

## Identity Security

* IAM Roles attached to EC2.
* No hardcoded credentials.
* No static access keys used.

## State Security

* Terraform state encrypted in S3.
* DynamoDB state locking enabled.

---

# Monitoring & Observability

## CloudWatch Logs

* Application Logs
* System Logs

## CloudWatch Alarms

* High CPU Utilization Alarm
* Target Health Monitoring

## Metrics

* EC2 Metrics
* ALB Metrics
* Auto Scaling Metrics

---

# Scaling Strategy

## Current Auto Scaling Configuration

| Parameter        | Value |
| ---------------- | ----- |
| Min Capacity     | 2     |
| Desired Capacity | 2     |
| Max Capacity     | 4     |

### Scaling Workflow

```text
Traffic Increase
      │
      ▼
ALB distributes load
      │
      ▼
CloudWatch monitors metrics
      │
      ▼
Auto Scaling Group launches new instances
      │
      ▼
New instances automatically register to ALB
```

### Recommended Enhancement

Implement Target Tracking Scaling Policies:

* Scale Out: CPU > 70%
* Scale In: CPU < 40%

---

# Cost Estimation

| Service                   | Estimated Monthly Cost |
| ------------------------- | ---------------------- |
| NAT Gateway               | $65.70                 |
| NAT Data Processing       | $2.25                  |
| Application Load Balancer | $22 - $24              |
| EC2 Instances             | $24 - $26              |
| EBS Storage               | $4.80 - $6.00          |
| EBS Snapshots             | $2.50                  |
| Data Transfer             | $42 - $45              |
| CloudWatch                | $3 - $8                |
| Amazon ECR                | $1                     |
| Route53                   | $0.50 - $1.50          |
| ACM                       | $0                     |

### Estimated Total Monthly Cost

**~$165 – $180 per month**

---

# Production Readiness

### Implemented

* Multi-AZ Deployment
* Private Application Tier
* HTTPS Enabled
* Route53 DNS Integration
* IAM Roles
* Encrypted Storage
* CloudWatch Monitoring
* Auto Scaling Group
* Remote Terraform Backend
* Modular Terraform Design

### Future Enhancements

* AWS WAF Integration
* Auto Scaling Policies
* ALB Access Logs
* AWS Backup Policies
* CI/CD Pipeline
* Instance Refresh Strategy

---

# Repository Deliverables

* Terraform Code (Modular)
* Architecture Diagram
* Cost Estimation
* Production Readiness Note
* README Documentation

---

# Author

**Sahil Mahadik**

* Platform: AWS
* Infrastructure as Code: Terraform
* Environment: Production-like SaaS Deployment
