# Multi-Cloud Kubernetes Infrastructure with Terraform

This repository provisions complete Kubernetes environments in **Microsoft Azure** and **Amazon Web Services** using reusable Terraform modules.

The project creates:

- An Azure Kubernetes Service (**AKS**) cluster
- An Amazon Elastic Kubernetes Service (**EKS**) cluster
- Azure Virtual Network and AKS subnet
- AWS VPC, public subnets and private subnets
- AWS Internet Gateway and NAT Gateway
- Managed Kubernetes worker nodes
- Required Azure identities and AWS IAM roles
- Kubernetes networking, monitoring and platform add-ons

> **Important:** This project creates chargeable Azure and AWS resources. Review the Terraform plan before applying it and destroy lab resources when they are no longer required.

## Architecture Overview

```text
                         Terraform Root Module
                                  |
                 +----------------+----------------+
                 |                                 |
             Microsoft Azure                     AWS
                 |                                 |
       +---------+----------+            +---------+----------+
       |                    |            |                    |
 Resource Group       Virtual Network    VPC             IAM Roles
                            |             |
                       AKS Subnet    +----+--------------------+
                            |        |                         |
                       AKS Cluster   Public Subnets       Private Subnets
                            |              |                   |
                    System Node Pool       |              EKS Cluster
                                           |                   |
                                      NAT Gateway       Managed Node Group
```

AKS and EKS are managed through the same repository, but their cloud resources remain separated through provider-specific modules.

## Repository Structure

```text
terraform-multicloud-kubernetes/
├── modules/
│   ├── aws-vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── aws-eks/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── azure-network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── azure-aks/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── outputs.tf
│   │   └── backend.tf
│   └── prod/
│       └── ...
├── .gitignore
└── README.md
```

## Module Summary

### `aws-vpc`

Creates the base AWS network required by EKS:

- VPC
- Public and private subnets across multiple Availability Zones
- Internet Gateway
- NAT Gateway
- Public and private route tables
- Kubernetes subnet discovery tags

### `aws-eks`

Creates the Amazon EKS environment:

- EKS control plane
- Cluster IAM role
- Worker-node IAM role
- Managed node group
- VPC CNI add-on
- CoreDNS add-on
- kube-proxy add-on
- Kubernetes control-plane logging

### `azure-network`

Creates the base Azure network required by AKS:

- Azure Virtual Network
- Dedicated AKS subnet

### `azure-aks`

Creates the Azure Kubernetes Service environment:

- AKS control plane
- System-assigned managed identity
- System node pool
- Cluster autoscaler
- Azure CNI Overlay networking
- Azure network policy
- Standard Load Balancer
- Log Analytics workspace
- Container monitoring integration

## Prerequisites

Install and configure the following tools before deploying the infrastructure:

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- An AWS account with permission to create VPC, IAM and EKS resources
- An Azure subscription with permission to create networking, monitoring and AKS resources

Confirm the local installations:

```bash
terraform version
aws --version
az version
kubectl version --client
```

## Cloud Authentication

### Authenticate to AWS

Configure an AWS CLI profile:

```bash
aws configure
```

Validate the active AWS identity:

```bash
aws sts get-caller-identity
```

For a named profile:

```bash
export AWS_PROFILE="my-aws-profile"
aws sts get-caller-identity
```

Do not store AWS access keys in Terraform files or commit them to Git.

### Authenticate to Azure

Sign in using the Azure CLI:

```bash
az login
```

Select the required subscription:

```bash
az account set --subscription "<azure-subscription-id>"
az account show
```

## Configuration

Update `environments/dev/terraform.tfvars` with values suitable for your environment.

```hcl
project_name = "multicloud-k8s"
environment  = "dev"

aws_region             = "ap-south-1"
aws_vpc_cidr           = "10.10.0.0/16"
aws_availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

aws_public_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

aws_private_subnet_cidrs = [
  "10.10.11.0/24",
  "10.10.12.0/24"
]

azure_subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_location        = "Central India"

azure_vnet_address_space = [
  "10.30.0.0/16"
]

azure_aks_subnet_prefixes = [
  "10.30.1.0/24"
]
```

### Supplying the Azure subscription ID securely

Instead of storing the subscription ID in `terraform.tfvars`, it can be supplied as an environment variable:

```bash
export TF_VAR_azure_subscription_id="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

For CI/CD, store credentials and sensitive variables in the secret-management capability of the pipeline platform.

## Deploy the Infrastructure

Change to the required environment directory:

```bash
cd environments/dev
```

Initialise Terraform:

```bash
terraform init
```

Format the Terraform files:

```bash
terraform fmt -recursive
```

Validate the configuration:

```bash
terraform validate
```

Review the proposed changes:

```bash
terraform plan -out=tfplan
```

Apply the reviewed plan:

```bash
terraform apply tfplan
```

Avoid using `terraform apply -auto-approve` for production deployments.

## Terraform Outputs

After deployment, display all outputs:

```bash
terraform output
```

Display individual outputs:

```bash
terraform output eks_cluster_name
terraform output aks_cluster_name
terraform output aws_vpc_id
terraform output azure_vnet_id
```

## Connect to the EKS Cluster

Update the local kubeconfig:

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name multicloud-k8s-dev-eks
```

Validate the EKS environment:

```bash
kubectl config current-context
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A
```

## Connect to the AKS Cluster

Retrieve the AKS credentials:

```bash
az aks get-credentials \
  --resource-group multicloud-k8s-dev-aks-rg \
  --name multicloud-k8s-dev-aks \
  --overwrite-existing
```

Validate the AKS environment:

```bash
kubectl config current-context
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A
```

## Switching Between Kubernetes Contexts

List all contexts:

```bash
kubectl config get-contexts
```

Select the EKS context:

```bash
kubectl config use-context <eks-context-name>
```

Select the AKS context:

```bash
kubectl config use-context <aks-context-name>
```

Always confirm the current context before applying Kubernetes manifests:

```bash
kubectl config current-context
```

## Test Deployment

Create a test namespace and NGINX deployment:

```bash
kubectl create namespace terraform-test
kubectl create deployment nginx \
  --image=nginx:stable \
  --namespace=terraform-test
kubectl expose deployment nginx \
  --port=80 \
  --type=LoadBalancer \
  --namespace=terraform-test
```

Validate the workload:

```bash
kubectl get deployment,pod,service \
  --namespace=terraform-test \
  -o wide
```

Remove the test resources:

```bash
kubectl delete namespace terraform-test
```

Run this validation separately against the AKS and EKS contexts.

## Remote State Recommendation

Do not use local Terraform state for shared or production environments.

Recommended separation:

```text
State 1: environments/dev/aks
State 2: environments/dev/eks
State 3: environments/prod/aks
State 4: environments/prod/eks
```

Separating AKS and EKS state reduces the impact of mistakes and allows each platform to be planned and deployed independently.

Recommended backends:

- Azure Storage backend for Azure infrastructure
- Amazon S3 backend with the approved locking approach for AWS infrastructure
- HCP Terraform if centrally managed remote runs and state are required

Never commit any of the following files:

```text
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
*.tfvars
```

If `.tfvars` files do not contain secrets and must be version controlled, commit an example file such as `terraform.tfvars.example` instead.

## Suggested `.gitignore`

```gitignore
# Terraform working directory
**/.terraform/*

# Terraform state
*.tfstate
*.tfstate.*

# Terraform plan files
*.tfplan

# Crash logs
crash.log
crash.*.log

# Variable files that may contain sensitive values
*.tfvars
*.tfvars.json
!*.tfvars.example

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# CLI configuration
.terraformrc
terraform.rc

# Local Kubernetes configuration
kubeconfig
*.kubeconfig

# IDE and operating-system files
.vscode/
.idea/
.DS_Store
Thumbs.db
```

## Security Considerations

Before using the project for production, consider implementing:

- Private AKS and EKS API endpoints
- Restricted authorised IP ranges when public API access is necessary
- Microsoft Entra ID integration for AKS
- Disabled AKS local accounts
- EKS access entries with least-privilege access policies
- AKS Workload Identity
- EKS Pod Identity or IAM Roles for Service Accounts
- Customer-managed encryption keys where required
- Azure Firewall or an approved egress design
- AWS VPC endpoints for private access to supported AWS services
- Centralised secrets management
- Network policies
- Kubernetes admission policies
- Image scanning and trusted registries
- Terraform security and policy scanning
- Centralised audit, platform and workload logs

## Production Improvements

The current code provides a reusable starting point. A production implementation should also consider:

- Separate system and user node pools
- Node pools distributed across Availability Zones
- Multiple NAT Gateways for AWS high availability
- Azure NAT Gateway or firewall-controlled egress
- Private DNS design
- Azure Container Registry and Amazon ECR
- Application Gateway, NGINX or another approved AKS ingress solution
- AWS Load Balancer Controller or another approved EKS ingress solution
- TLS certificate management
- External DNS integration
- Azure Monitor, CloudWatch and managed Prometheus
- Backup and disaster-recovery requirements
- Kubernetes version and node-image upgrade strategy
- Resource quotas and limit ranges
- Azure Policy and AWS governance controls
- CI/CD approval gates

## CI Validation Example

The following checks can be included in a pull-request workflow:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Additional tools such as `tflint`, Checkov or another organisation-approved scanner can be added to the pipeline.

## Cost Considerations

This project may create billable resources, including:

- AKS or EKS cluster infrastructure
- Virtual machines or managed worker nodes
- AWS NAT Gateway and associated data processing
- Azure and AWS load balancers
- Public IP addresses
- Log Analytics and CloudWatch ingestion
- Network traffic

For a lab environment:

- Use small supported worker-node sizes
- Keep minimum and maximum node counts low
- Use one NAT Gateway only when the availability trade-off is acceptable
- Remove test LoadBalancer services
- Destroy the environment after validation

## Destroy the Infrastructure

Change to the environment directory:

```bash
cd environments/dev
```

Create and review a destroy plan:

```bash
terraform plan -destroy -out=destroy.tfplan
```

Apply the destroy plan:

```bash
terraform apply destroy.tfplan
```

Confirm that no expected resources remain in the Azure and AWS portals after destruction.

## Troubleshooting

### Terraform cannot authenticate to AWS

```bash
aws sts get-caller-identity
```

Check the selected profile and region:

```bash
echo "$AWS_PROFILE"
echo "$AWS_REGION"
```

### Terraform cannot authenticate to Azure

```bash
az account show
az account list --output table
```

Select the correct subscription again if required:

```bash
az account set --subscription "<azure-subscription-id>"
```

### Terraform configuration error

```bash
terraform fmt -recursive
terraform validate
```

### Kubernetes nodes are not ready

```bash
kubectl get nodes -o wide
kubectl describe node <node-name>
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

### Wrong Kubernetes cluster selected

```bash
kubectl config get-contexts
kubectl config current-context
kubectl config use-context <required-context>
```

## Naming Convention

Resources use the following naming pattern:

```text
<project-name>-<environment>-<resource-type>
```

Examples:

```text
multicloud-k8s-dev-aks
multicloud-k8s-dev-eks
multicloud-k8s-dev-vpc
multicloud-k8s-dev-aks-rg
```

## Contribution Workflow

1. Create a feature branch.
2. Update the required module or environment.
3. Run `terraform fmt -recursive`.
4. Run `terraform validate`.
5. Generate and review a Terraform plan.
6. Submit a pull request.
7. Obtain the required technical and security approvals.
8. Merge only after all checks pass.

## Disclaimer

This repository is a reference implementation and must be reviewed against the organisation's networking, identity, security, naming, tagging, logging, backup, compliance and cost-management standards before production use.

## Licence

Add the licence approved for your project, for example an internal-use notice or an open-source licence such as MIT.
