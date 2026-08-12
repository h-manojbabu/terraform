variable "vpc_id" {
    description = "create the security group"
    type = string
  
}

variable "ami" {
    description = "ami ID for ec2"
    type = string
  
}

variable "instance_type" {
    type = string
  
}

variable "subnet_id" {
    type = string
  
}