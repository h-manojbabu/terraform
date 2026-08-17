variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "endpoint_public_access" {
  type    = bool
  default = true
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "capacity_type" {
  type    = string
  default = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "desired_nodes" {
  type    = number
  default = 2
}

variable "minimum_nodes" {
  type    = number
  default = 1
}

variable "maximum_nodes" {
  type    = number
  default = 4
}

variable "tags" {
  type    = map(string)
  default = {}
}
