# Terraform AWS Lab

![Terraform CI](https://github.com/Arjunmore88/terraform-lab/actions/workflows/terraform-ci.yml/badge.svg)

A hands-on Infrastructure-as-Code lab that provisions a small, production-style AWS environment with **reusable Terraform modules**, **secure defaults**, and **CI checks with GitHub Actions**.

## Architecture

```
                 Internet
                    │
            ┌───────▼────────┐
            │ Internet GW    │
            └───────┬────────┘
   VPC 10.0.0.0/16  │
   ┌────────────────┼──────────────────────────┐
   │  Public subnet (AZ-a)   Public subnet (AZ-b)
   │   ┌──────────────┐                        │
   │   │ EC2 (nginx)  │◄── SG: HTTP 80 only    │
   │   │ IMDSv2, SSM  │                        │
   │   └──────────────┘                        │
   │  Private subnet (AZ-a)  Private subnet (AZ-b)
   └───────────────────────────────────────────┘

   S3 bucket (versioned, encrypted, public access blocked)
```

## What this demonstrates

| Skill | Where |
|---|---|
| Reusable modules with inputs/outputs | `modules/vpc`, `modules/ec2`, `modules/s3` |
| Environment separation | `environments/dev` (add `staging`, `prod` the same way) |
| Data sources | Latest Amazon Linux 2023 AMI, available AZs |
| `count`, `merge()`, `jsonencode()`, `random_id` | VPC subnets, tags, IAM policy, bucket name |
| Security best practices | No SSH port (SSM Session Manager), IMDSv2, encrypted EBS & S3, S3 public access block |
| Consistent tagging | `default_tags` on the provider |
| Remote state (optional) | S3 backend with native locking in `versions.tf` |
| CI/CD | `terraform fmt`, `validate`, and `tflint` on every push/PR |

## Project structure

```
.
├── .github/workflows/terraform-ci.yml
├── environments/
│   └── dev/
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
│       ├── versions.tf
│       └── terraform.tfvars.example
└── modules/
    ├── ec2/   # Security group, IAM role (SSM), EC2 + nginx
    ├── s3/    # Secure S3 bucket
    └── vpc/   # VPC, IGW, public/private subnets, routes
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- AWS account and [AWS CLI](https://aws.amazon.com/cli/) configured (`aws configure`)

## Usage

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars   # edit values

terraform init
terraform plan
terraform apply

# open the web server
curl $(terraform output -raw web_url)

# connect to the instance without SSH
aws ssm start-session --target <instance-id>
```

### Clean up (avoid charges!)

```bash
terraform destroy
```

## Cost

Uses free-tier-eligible resources (`t3.micro`, no NAT Gateway). Always run `terraform destroy` when done.

## Ideas to extend

- Add `staging` / `prod` environments
- Add an Application Load Balancer + Auto Scaling Group
- Add a NAT Gateway and move the instance to a private subnet
- Add `terraform plan` on PRs using GitHub OIDC to AWS
- Add `checkov` or `tfsec` security scanning
