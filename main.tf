module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  common_tags          = var.common_tags
}

module "eks" {
  source               = "./modules/eks"
  cluster_name         = var.cluster_name
  cluster_version      = var.cluster_version
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.public_subnet_ids
  private_subnet_ids   = module.vpc.public_subnet_ids
  managed_node_config  = var.managed_node_config
  common_tags          = var.common_tags
}