# learn-terraform

A small hands-on Terraform project for learning AWS fundamentals: a security
group, an EC2 instance running nginx, and an Application Load Balancer in
front of it. Built incrementally, one resource at a time.

## Architecture

Internet
│
▼
[ALB] (public subnets, SG: port 80 open)
│
▼
[EC2 instance] (SG: port 80 from ALB only)
nginx serving a static page via user_data


## Files

| File | Purpose |
|---|---|
| `providers.tf` | Terraform + AWS provider config, pinned version |
| `variables.tf` | Declares all input variables (no values) |
| `main.tf` | The actual resources: security groups, instance, ALB, target group, listener |
| `values.tfvars` | Real values for this environment (VPC ID, subnet IDs) — **not loaded automatically**, must be passed with `-var-file` |

## Prerequisites

- Terraform >= 1.5 (https://developer.hashicorp.com/terraform/install)
- AWS CLI installed and configured (`aws configure`) with credentials that
  can create EC2/SG/ELB resources
- An existing VPC with:
  - At least 1 subnet for the EC2 instance
  - At least 2 subnets in different Availability Zones for the ALB (this is
    an AWS hard requirement, not a Terraform choice)

## Variables you need to supply

Edit `values.tfvars` with your own values:

```hcl
vpc_id            = "vpc-xxxxxxxx"
subnet_id         = "subnet-xxxxxxxx"
public_subnet_ids = ["subnet-xyxyxyx", "subnet-cccccc"]  # 2 different AZs
```

## Usage

```bash
terraform init
terraform plan  -var-file="values.tfvars"
terraform apply -var-file="values.tfvars"
```

Get the load balancer's address:

```bash
terraform state show aws_lb.my_first_alb | grep dns_name
```

Visit `http://<that-dns-name>` in a browser. Allow a minute or two after
apply for the target to pass its first health check.

Tear down when you're done experimenting:

```bash
terraform destroy -var-file="values.tfvars"
```

## What this project intentionally does NOT do yet

These were left out on purpose to keep each step small — noted here so
nothing is mistaken for an oversight:

- **Only one EC2 instance** — no second instance/AZ redundancy yet.
- **`user_data` bakes the page directly into the boot script.** In a real
  setup, content updates are better served from S3 (upload a file, instances
  pull it) so nothing has to be redeployed — `user_data` only runs on first
  boot by default.
- **No Auto Scaling Group.** A single `aws_instance` is fine for learning,
  but production fleets are usually managed through a Launch Template + ASG
  so instance replacement (e.g. for patching) is a rolling, zero-downtime
  operation instead of a manual `apply`.
- **HTTP only**, no ACM certificate / HTTPS listener.
- **Local state.** `terraform.tfstate` stays on this machine — fine solo,
  but a team would move to an S3+DynamoDB or Terraform Cloud backend.

## Security notes

- The EC2 instance's security group only accepts port 80 from the ALB's
  security group — not from the open internet — so the ALB is the only
  public entry point.
- No SSH port is open. For instance access, use SSM Session Manager instead
  of a key pair (needs an IAM instance profile with the
  `AmazonSSMManagedInstanceCore` policy — not yet added in this version).

## Notes on gitignoring state

If you push this to GitHub, add a `.gitignore` with at least:

.terraform/
*.tfstate
.tfstate.
crash.log
*.tfvars


`*.tfvars` is included here because `values.tfvars` holds account-specific
VPC/subnet IDs — not secret, but not something to hardcode in a public repo
either. Commit a `values.tfvars.example` with placeholder values instead so
others know what to fill in.

<img width="509" height="233" alt="image" src="https://github.com/user-attachments/assets/4fbb354f-7ca8-4c18-80a4-671a01413ec8" />



