packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3.large"
}

variable "ssh_username" {
  type    = string
  default = "ec2-user" # for Amazon Linux 2; ubuntu for Ubuntu
}

# Pick a base AMI (example uses Amazon Linux 2)
data "amazon-ami" "al2" {
  region      = var.region
  owners      = ["amazon"]
  most_recent = true

  filters = {
    name                = "amzn2-ami-hvm-*-x86_64-gp2"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
}

source "amazon-ebs" "worker" {
  region        = var.region
  instance_type = var.instance_type
  source_ami    = data.amazon-ami.al2.id
  ssh_username  = var.ssh_username

  ami_name      = "worker-ansible-{{timestamp}}"
  ami_description = "Worker node image built with Packer + Ansible"

  # Optional tags
  tags = {
    Name = "worker-ansible"
  }
}

build {
  name    = "worker-image"
  sources = ["source.amazon-ebs.worker"]

  # (Optional) install baseline deps your playbook expects
  provisioner "shell" {
    inline = [
      "sudo yum -y update || true",
      "sudo yum -y install python3 || true",
      "python3 --version || true"
    ]
  }

  # Run your Ansible playbook during build
  provisioner "ansible" {
    playbook_file   = "./ansible/worker.yml"
    user            = var.ssh_username
    use_proxy       = false

    # Extra vars if you need
    extra_arguments = [
      "--extra-vars", "packer_build=true"
    ]
  }

  # Clean up (optional)
  provisioner "shell" {
    inline = [
      "sudo yum clean all || true",
      "sudo rm -rf /tmp/* || true"
    ]
  }
}

