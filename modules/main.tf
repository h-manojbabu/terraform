module "server-1" {
  source        = "./modules/ec2"
  ami           = var.ami_id1
  instance_type = var.instance_type1
  subnet_id     = var.subnet_id1
  sgp_id        = var.sgp_id1
  instance_name = var.instance_name1
  key_name      = var.key_name1

}

module "server-2" {
  source        = "./modules/ec2"
  ami           = var.ami_id2
  instance_type = var.instance_type2
  subnet_id     = var.subnet_id2
  sgp_id        = var.sgp_id2
  instance_name = var.instance_name2
  key_name      = var.key_name2

}