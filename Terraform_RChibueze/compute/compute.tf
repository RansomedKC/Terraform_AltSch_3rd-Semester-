module "networking" {
  source             = "../modules/networking"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.2.0/24"
}

module "compute" {
  source          = "../modules/compute"
  public_key_path = "~/.ssh/kaysea_key.pub"
  public_subnet   = module.networking.public_subnet
  public_sg       = module.networking.public_sg
  user_data       = file("userdata.tpl")
  volume_size     = 30
  instance_type   = "t2.micro"
}



