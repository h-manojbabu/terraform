# Terraform AWS EC2 Module

This project demonstrates how to create reusable Terraform modules to provision AWS EC2 instances.

The root module invokes a custom EC2 module to deploy multiple EC2 instances with configurable parameters such as AMI, instance type, subnet, key pair, and security groups.

## Architecture

```text
terraform.tfvars
      │
      ▼
variables.tf
      │
      ▼
main.tf
      │
      ▼
modules/ec2
      │
      ▼
AWS EC2 Instances
```

## Project Structure

```text
.
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
└── modules
    └── ec2
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Prerequisites

- Terraform >= 1.x
- AWS Account
- AWS CLI configured
- Appropriate IAM permissions

## Module Usage

### Root Module

```hcl
module "server1" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  sgp_id        = var.sgp_id1
  key_name      = var.key_name
  instance_name = "web-server-01"
}

module "server2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  sgp_id        = var.sgp_id2
  key_name      = var.key_name
  instance_name = "web-server-02"
}
```

## Module Variables

| Variable | Description | Type |
|-----------|-------------|------|
| ami_id | EC2 AMI ID | string |
| instance_type | EC2 instance type | string |
| subnet_id | Subnet ID | string |
| sgp_id | Security Group ID | string |
| key_name | EC2 Key Pair | string |
| instance_name | Instance Name Tag | string |

## Example terraform.tfvars

```hcl
ami_id        = "ami-xxxxxxxx"
instance_type = "t2.micro"
subnet_id     = "subnet-xxxxxxxx"
key_name      = "my-key"

sgp_id1 = "sg-xxxxxxxx"
sgp_id2 = "sg-yyyyyyyy"
```

## Outputs

| Output | Description |
|----------|-------------|
| instance_id | EC2 Instance ID |
| private_ip | Private IP Address |
| public_ip | Public IP Address |

## Terraform Commands

Initialise Terraform:

```bash
terraform init
```

Validate configuration:

```bash
terraform validate
```

Preview changes:

```bash
terraform plan
```

Deploy resources:

```bash
terraform apply
```

Destroy resources:

```bash
terraform destroy
```

## Features

- Reusable Terraform module
- Infrastructure as Code (IaC)
- Multiple EC2 instances from a single module
- Parameterised configuration
- Consistent resource deployment
- Easy to extend for additional AWS resources

## Future Enhancements

- VPC Module
- Security Group Module
- Auto Scaling Group
- Application Load 
