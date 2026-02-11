output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = var.region
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

