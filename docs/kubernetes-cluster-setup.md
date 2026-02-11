# Kubernetes Cluster Setup (EKS) – Secure, No-SSH, SSM-only

This environment provisions an Amazon EKS cluster in `us-west-1` (2 AZs available) with:
- Private EKS API endpoint (no public access)
- Private worker nodes
- A private “bastion/admin” instance
- No SSH (port 22) anywhere
- Access and operations performed via AWS Systems Manager (SSM)

# Why SSM instead of SSH
SSH-based administration introduces common production risks:
- Managing private keys (rotation, leakage, distribution)
- Opening port 22 / bastion ingress rules
- Host key verification drift and manual access patterns

Instead, we use SSM Session Manager and SSM RunCommand which provides:
- No inbound ports required on instances
- IAM-based access control (least privilege)
- Auditable sessions and command execution
- Works in private subnets via VPC endpoints (no public internet required)

## Network design
- VPC with public + private subnets across 2 AZs in us-west-1
- NAT gateway(s) for controlled outbound access
- VPC endpoints for private SSM/ECR/STS/Logs access

# VPC Endpoints
Interface endpoints:
- ssm, ssmmessages, ec2messages
`
- sts, logs, ec2 (as needed)

Gateway endpoint:
- s3 (for artifacts/transfers)
## Bastion (Admin Instance)

A private EC2 instance used for:
- Running kubectl against the EKS cluster
- Running operational checks against worker nodes (via SSM RunCommand)

#How we access the bastion
We do NOT SSH.
We start an interactive session using SSM:

#TO LOGIN TO BASTION HOST
aws ssm start-session --region us-west-1 --target <BASTION_INSTANCE_ID>

