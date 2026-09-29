module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      instance_types = var.instance_types
      capacity_type  = "SPOT"
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size
      labels         = { workload = "ml-inference" }
    }
  }

  tags = var.tags
}
