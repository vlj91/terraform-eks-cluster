variable "create" {
  type        = bool
  description = "Optionally create all resources"
  default     = true
}

variable "create_workers" {
  type        = bool
  description = "Create worker pool"
  default     = true
}

variable "cluster_version" {
  type        = string
  default     = "1.16"
  description = "https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html"
}

variable "namespaces" {
  type        = list(string)
  description = "A list of additional namespaces to create"
  default     = []
}

variable "fargate_namespaces" {
  type        = list(string)
  description = "Fargate enabled namespaces"
  default     = []
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "fargate_enabled" {
  type    = bool
  default = true
}

variable "fargate_enabled_namespaces" {
  type    = list(string)
  default = ["kube-ingress", "kube-system"]
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

variable "kubernetes_dashboard_enabled" {
  type        = bool
  default     = true
  description = "Optionally deploy kubernetes-dashboard"
}

variable "metrics_server_enabled" {
  type        = bool
  default     = true
  description = "Optionally deploy metrics-server"
}

variable "node_problem_detector_enabled" {
  type        = bool
  default     = true
  description = "Optionally deploy node-problem-detector"
}

variable "weave_scope_enabled" {
  type        = bool
  default     = true
  description = "Optionally deploy weave-scope"
}

variable "prometheus_enabled" {
  type        = bool
  default     = true
  description = "Optionally deploy prometheus"
}

variable "grafana_enabled" {
  type = bool
  default = true
  description = "Optionally deploy grafana"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "tags" {
  type        = map(string)
  description = "A list of tags"
  default     = {}
}

variable "workers_desired_size" {
  type    = number
  default = 1
}

variable "workers_min_size" {
  type    = number
  default = 1
}

variable "workers_max_size" {
  type    = number
  default = 1
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

output "cluster_arn" {
  value = join("", aws_eks_cluster.this.*.arn)
}

output "cluster_endpoint" {
  value = join("", aws_eks_cluster.this.*.endpoint)
}

output "cluster_version" {
  value = join("", aws_eks_cluster.this.*.platform_version)
}
