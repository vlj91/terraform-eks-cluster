variable "create" {
  type = bool
  description = "Optionally create all deployments"
  default = true
}

variable "labels" {
  type = map(string)
  default = {}
}

variable "kubernetes_dashboard_enabled" {
  type = bool
  default = true
  description = "Optionally deploy kubernetes-dashboard"
}

variable "metrics_server_enabled" {
  type = bool
  default = true
  description = "Optionally deploy metrics-server"
}

variable "node_problem_detector_enabled" {
  type = bool
  default = true
  description = "Optionally deploy node-problem-detector"
}

variable "weave_scope_enabled" {
  type = bool
  default = true
  description = "Optionally deploy weave-scope"
}

variable "prometheus_enabled" {
  type = bool
  default = true
  description = "Optionally deploy prometheus"
}

locals {
  # TODO: add var to allow merging default repositories with additional repositories
  helm_repository = {
    "stable" = "https://kubernetes-charts.storage.googleapis.com"
  }
}
