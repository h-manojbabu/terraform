project_name = "giveyourprojectname"
environment  = "dev/uat/prod"

aws_region             = "region"
aws_vpc_cidr           = "10.10.0.0/16"
aws_availability_zones = [
  "region-1a",
  "region-1b"
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
