variable "cluster_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}

variable "minimum_nodes" {
  type    = number
  default = 1
}

variable "maximum_nodes" {
  type    = number
  default = 4
}

variable "service_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "dns_service_ip" {
  type    = string
  default = "10.20.0.10"
}

variable "tags" {
  type    = map(string)
  default = {}
}
