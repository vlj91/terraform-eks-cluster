variable "create" {
  type = bool
  default = true
}

variable "cluster_version" {
  type        = string
  default     = "1.16"
  description = "https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "cluster_name" {
  type = string
}

variable "namespaces" {
  type = list(string)
  description = "A list of additional namespaces to create"
  default = []
}

variable "single_nat_gateway" {
  type = bool
  default = true
}

variable "fargate_enabled" {
  type = bool
  default = true
}

variable "fargate_enabled_namespaces" {
  type = list(string)
  default = ["kube-ingress", "kube-system"]
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}