variable "instance_name" {
  description = "entern the instance Name"
  type        = string
}

variable "instance_type" { 
  description = "Enter the required isntance type"
  type        = string
}

variable "ami" { 
  description = "ami id for the instance"
  type        = string
}

variable "subnet_id" {
  description = "subnet id for the instance"
  type        = string
}

variable "key_name" {
  description = "akk the pem key details "
  type        = string
}

variable "sgp_id" {
  type = list(string)
}