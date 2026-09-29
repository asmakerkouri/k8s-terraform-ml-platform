locals {
  name = "ml-platform-${var.environment}"
  tags = {
    Project     = "ml-platform"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "network" {
  source = "../../modules/network"
  name   = local.name
  tags   = local.tags
}

module "eks" {
  source       = "../../modules/eks"
  cluster_name = local.name
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnets
  tags         = local.tags
}

module "ecr" {
  source = "../../modules/ecr"
  name   = "mlops-yolo-fastapi"
  tags   = local.tags
}
