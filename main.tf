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

data "aws_availability_zones" "available" {}
