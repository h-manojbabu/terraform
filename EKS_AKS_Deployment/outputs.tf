output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "aws_vpc_id" {
  value = module.aws_vpc.vpc_id
}

output "azure_vnet_id" {
  value = module.azure_network.vnet_id
}
