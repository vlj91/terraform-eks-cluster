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

variable "node_group_enabled" {
  type    = bool
  default = true
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