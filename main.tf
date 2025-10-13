module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = var.vpc_cidr
  vpc_name           = "simple-prod-vpc"
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
  common_tags        = var.common_tags
}

module "ec2" {
  source         = "./modules/ec2"
  project_name   = "python-app"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_id
  ami_id         = "ami-02d26659fd82cf299"
  instance_type  = "t3.micro"
  key_name       = "my-keypair"
  app_repo_url   = "https://github.com/chetanborade/python_flask.git"
}