module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = var.name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  cluster_security_group_additional_rules = {
    bastion_to_control_plane_https = {
      description              = "Allow bastion to access private EKS API"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = aws_security_group.bastion_sg.id
    }
  }

  eks_managed_node_groups = {
    main = {
      name           = "${var.name}-ng"
      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_min
      desired_size = var.node_desired
      max_size     = var.node_max

      subnet_ids = module.vpc.private_subnets

      # NO SSH: do not set remote_access

      # Ensure nodes register in SSM
      iam_role_additional_policies = {
        ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      tags = local.tags
    }
  }

  # Grant bastion role cluster-admin (we create bastion role in bastion.tf)
  access_entries = {
    bastion_admin = {
      principal_arn = aws_iam_role.bastion_role.arn
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  tags = local.tags

  depends_on = [
    aws_vpc_endpoint.interface,
    aws_vpc_endpoint.s3
  ]
}

