# AWS ECS Two-Tier Architecture with CI/CD

![Architecture Diagram](docs/aws_architecture_diagram.png)

A production-ready, highly available containerized application deployment on AWS ECS using Terraform and automated CI/CD with GitHub Actions.

## 🏗️ Architecture Overview

**Two-tier, multi-AZ architecture** deployed in AWS eu-north-1 region:

### **Tier 1: Public Subnet (ALB Tier)**
- Application Load Balancer with SSL/TLS termination (ACM)
- NAT Gateways for outbound internet access
- Spans two Availability Zones (eu-north-1a, eu-north-1b)

### **Tier 2: Private Subnet (Application Tier)**
- ECS Fargate services running Docker containers
- No direct internet access for enhanced security
- High availability across two AZs

### **Traffic Flow**
```
User → Cloudflare → Route 53 → Internet Gateway → ALB → ECS Services
```

### **Deployment Flow**
```
Application: GitHub Actions → Docker Build → Trivy Scan → ECR → SSM Parameter → ECS Update
Infrastructure: GitHub Actions → Terraform Plan → Manual Review → Terraform Apply
```

## ✨ Key Features

### High Availability & Reliability
- Multi-AZ deployment across eu-north-1a and eu-north-1b
- Application Load Balancer with health checks
- Redundant NAT Gateways per AZ

### Security
- SSL/TLS encryption with AWS Certificate Manager
- Private subnets for application tier
- Container vulnerability scanning with Trivy
- Infrastructure compliance scanning with Checkov
- IAM roles with OIDC (no long-lived credentials)

### Infrastructure as Code
- 100% Terraform-managed infrastructure with modular design
- DRY principles using `for_each` for subnet creation
- Remote state management (S3 + DynamoDB locking)
- Versioned, encrypted state with object lock enabled

### Automation & CI/CD
- Automated builds and deployments via GitHub Actions
- Dynamic image tagging using Git SHA
- SSM Parameter Store for zero-downtime deployments
- Automated infrastructure validation and security scanning

### Monitoring & Observability
- CloudWatch Log Groups for debugging
- CloudWatch Alarms monitoring CPU utilization (80% threshold)
- SNS notifications for alarm triggers

## 🔧 Infrastructure Components

**AWS Services:** VPC, ECS (Fargate), ECR, ALB, Route 53, ACM, NAT Gateway, Internet Gateway, CloudWatch, SNS, SSM Parameter Store, S3, DynamoDB

**External Services:** Cloudflare (Domain), GitHub Actions (CI/CD), Trivy (Security Scanning), Checkov (IaC Scanning)

## 🚀 CI/CD Pipeline

### Build Pipeline
Triggered on push to `app/` or `docker/` directories:
1. Checkout code and authenticate to AWS via OIDC
2. Build Docker image tagged with Git SHA (7 characters)
3. Run Trivy vulnerability scanner (blocks on CRITICAL/HIGH)
4. Test container health
5. Push image to ECR
6. Update SSM Parameter Store with new tag

**Key Innovation:** ECS task definition dynamically pulls image tag from SSM Parameter Store, enabling zero-downtime deployments without Terraform changes.

### Terraform Plan Pipeline
Triggered on push to `infra/` directory:
1. **Static Analysis:** terraform fmt, validate, and tflint
2. **Security Scanning:** Parallel Trivy and Checkov scans
3. **Plan Generation:** Creates execution plan and uploads artifact

### Terraform Deploy Pipeline
Manual trigger after plan review - applies approved infrastructure changes.

## 📁 Project Structure

```
.
├── .github/workflows/       # CI/CD pipelines (build, plan, deploy)
├── app/                     # Application source code
├── docker/                  # Dockerfile
├── infra/                   # Terraform root module
│   ├── modules/             # Reusable modules (vpc, ecs, alb, etc.)
│   ├── backend.tf           # S3 backend configuration
│   ├── locals.tf            # Subnet mappings and local values
│   ├── main.tf              # Module composition
│   └── variables.tf         # Input variables
└── README.md
```

## 🎯 Terraform Design Patterns

### DRY Principles
Instead of repeating subnet resources, I created a map-based approach:
- Define subnets as `map(object)` variables with CIDR and AZ attributes
- Use `for_each` in VPC module to dynamically create subnets
- Pass subnet configurations via `locals.tf` in root module

### Modular Architecture
Separate modules for each AWS service enable reusability and maintainability. All values passed via `terraform.tfvars` for environment-specific customization.

### State Management
- **S3 Backend:** Versioned, encrypted, with object lock
- **DynamoDB:** State locking prevents concurrent modifications
- Enables team collaboration and disaster recovery

## 📊 Monitoring

**CloudWatch Logs:** Centralized logging for all ECS tasks

**CloudWatch Alarms:** 
- Average CPU utilization monitoring
- Triggers SNS notification at 80% threshold
- Can be extended for auto-scaling decisions

**SNS Topics:** Email/SMS notifications for infrastructure alerts

## 🔒 Security Highlights

- **Network Isolation:** Application tier in private subnets
- **Encryption:** SSL/TLS via ACM, encrypted Terraform state
- **Vulnerability Management:** Automated scanning in CI/CD
- **Compliance:** Checkov validates Terraform against AWS best practices
- **Secrets Management:** GitHub Secrets + SSM Parameter Store

## 📋 Prerequisites

- Terraform >= 1.5.0
- AWS Account with appropriate IAM roles
- Domain registered (Cloudflare)
- GitHub repository with configured secrets

## 🚀 Quick Start

1. **Setup AWS Backend:** Create S3 bucket and DynamoDB table for state management
2. **Configure Variables:** Update `terraform.tfvars` with your values
3. **Initialize Terraform:** `terraform init`
4. **Deploy Infrastructure:** Commit changes to trigger plan pipeline, then manually deploy
5. **Deploy Application:** Push to `app/` or `docker/` to trigger build pipeline

## 🔄 Future Enhancements

- Implement ECS Service auto-scaling based on CloudWatch metrics
- Add AWS WAF for additional application security
- Implement blue-green or canary deployment strategies
- Multi-region deployment for disaster recovery

---

**Note:** This is a portfolio project demonstrating AWS cloud architecture, Infrastructure as Code, and DevOps best practices.
