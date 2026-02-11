variable "name" {
  type    = string
  default = "eks-ssm-prod"
}

variable "region" {
  type    = string
  default = "us-west-1"
}

variable "az_count" {
  description = "Force 2 AZs as requested"
  type        = number
  default     = 2
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "cluster_version" {
  type    = string
  default = "1.34"
}

variable "kubectl_version" {
  description = "kubectl installed on bastion (use same major/minor as cluster)"
  type        = string
  default     = "v1.34.0"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.large"]
}

variable "node_min" {
  type    = number
  default = 3
}

variable "node_desired" {
  type    = number
  default = 3
}

variable "node_max" {
  type    = number
  default = 8
}


