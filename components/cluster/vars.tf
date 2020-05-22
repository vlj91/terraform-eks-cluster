variable "name" {
  type = string
}

variable "create" {
  type = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "log_enabled_types" {
  type    = list(string)
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_period" {
  type    = number
  default = 30
}

variable "endpoint_private_access" {
  type    = bool
  default = false
}

variable "endpoint_public_access" {
  type    = bool
  default = true
}

variable "endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "private_subnet_ids" {
  type = list(string)
  default = []
}

output "cluster_security_group_id" {
  value = join("", aws_security_group.cluster.*.id)
}

output "id" {
  value = join("", aws_eks_cluster.this.*.id)
}

output "labels" {
  value = {
    "kubernetes.io/cluster" = join("", aws_eks_cluster.this.*.id)
  }
}

locals {
  cluster_identity = aws_eks_cluster.this.*.identity
}
