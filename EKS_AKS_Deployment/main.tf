locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = "OT-Team"
  }

  name_prefix     = "${var.project_name}-${var.environment}"
  eks_cluster_name = "${local.name_prefix}-eks"
  aks_cluster_name = "${local.name_prefix}-aks"
}

resource "azurerm_resource_group" "aks" {
  name     = "${local.name_prefix}-aks-rg"
  location = var.azure_location

  tags = local.common_tags
}

module "aws_vpc" {
  source = "../../modules/aws-vpc"

  name_prefix         = local.name_prefix
  cluster_name        = local.eks_cluster_name
  vpc_cidr            = var.aws_vpc_cidr
  availability_zones  = var.aws_availability_zones
  public_subnet_cidrs = var.aws_public_subnet_cidrs
  private_subnet_cidrs = var.aws_private_subnet_cidrs
  tags                = local.common_tags
}

module "eks" {
  source = "../../modules/aws-eks"

  cluster_name           = local.eks_cluster_name
  subnet_ids             = module.aws_vpc.private_subnet_ids
  endpoint_public_access = true
  instance_types         = ["t3.medium"]
  desired_nodes          = 2
  minimum_nodes          = 1
  maximum_nodes          = 4
  tags                   = local.common_tags
}

module "azure_network" {
  source = "../../modules/azure-network"

  name_prefix          = local.name_prefix
  resource_group_name  = azurerm_resource_group.aks.name
  location             = azurerm_resource_group.aks.location
  vnet_address_space   = var.azure_vnet_address_space
  aks_subnet_prefixes  = var.azure_aks_subnet_prefixes
  tags                 = local.common_tags
}

module "aks" {
  source = "../../modules/azure-aks"

  cluster_name        = local.aks_cluster_name
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  dns_prefix          = local.aks_cluster_name
  subnet_id           = module.azure_network.aks_subnet_id
  vm_size             = "Standard_D2s_v5"
  minimum_nodes       = 1
  maximum_nodes       = 4
  service_cidr        = "10.20.0.0/16"
  dns_service_ip      = "10.20.0.10"
  tags                = local.common_tags
}
