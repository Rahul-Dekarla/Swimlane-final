data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_iam_role" "bastion_role" {
  name = "${var.name}-bastion-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = local.tags
}

# Makes bastion a Managed Instance for SSM Session Manager
resource "aws_iam_role_policy_attachment" "bastion_ssm_managed_instance" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Bastion needs to talk to EKS to build kubeconfig and auth
resource "aws_iam_policy" "bastion_eks_min" {
  name        = "${var.name}-bastion-eks-min"
  description = "Minimal permissions for bastion to use aws eks update-kubeconfig and auth"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity"
        ],
        Resource = "*"
      }
    ]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "bastion_eks_min_attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.bastion_eks_min.arn
}

# Bastion needs permission to execute commands on OTHER instances via SSM (Ansible SSM transport)
resource "aws_iam_policy" "bastion_ssm_operator" {
  name        = "${var.name}-bastion-ssm-operator"
  description = "Allow bastion to run SSM commands and discover instances (for Ansible via SSM)"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMRunCommandCore",
        Effect = "Allow",
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation"
        ],
        Resource = "*"
      },
      {
        Sid    = "SSMMessagesForSessions",
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = "*"
      },
      {
        Sid    = "EC2DiscoveryForInventory",
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ],
        Resource = "*"
      }
    ]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_operator_attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.bastion_ssm_operator.arn
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.name}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.name}-bastion-sg"
  description = "Private bastion - no inbound (SSM only)"
  vpc_id      = module.vpc.vpc_id

  # no ingress rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    dnf install -y jq git python3-pip

    pip3 install --upgrade pip
    pip3 install ansible boto3 botocore
    ansible-galaxy collection install amazon.aws

    # kubectl pinned to requested version (1.34)
    curl -fsSL -o /usr/local/bin/kubectl https://dl.k8s.io/release/${var.kubectl_version}/bin/linux/amd64/kubectl
    chmod +x /usr/local/bin/kubectl

    echo 'alias k=kubectl' >> /etc/profile.d/aliases.sh
  EOF

  tags = merge(local.tags, { Name = "${var.name}-bastion" })

  depends_on = [
    module.eks,
    aws_vpc_endpoint.interface
  ]
}

