variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_vpc_cidr" {
  type = string
}

variable "aws_availability_zones" {
  type = list(string)
}

variable "aws_public_subnet_cidrs" {
  type = list(string)
}

variable "aws_private_subnet_cidrs" {
  type = list(string)
}

variable "azure_subscription_id" {
  type      = string
  sensitive = true
}

variable "azure_location" {
  type = string
}

variable "azure_vnet_address_space" {
  type = list(string)
}

variable "azure_aks_subnet_prefixes" {
  type = list(string)
}
